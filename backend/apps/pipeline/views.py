from decimal import Decimal
from django.db.models import Avg, Count, Q, Sum
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.deals.models import Deal, DealStage
from .models import Pipeline, PipelineStage
from .serializers import PipelineSerializer, PipelineStageSerializer


class PipelinePagination(PageNumberPagination):
    """
    Pagination for Pipeline list endpoints.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class PipelineViewSet(viewsets.ModelViewSet):
    """
    CRUD ViewSet for Sales Pipelines.
    Includes Kanban board aggregation, stage analytics, and default pipeline bootstrap.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = PipelineSerializer
    pagination_class = PipelinePagination

    def get_queryset(self):
        queryset = Pipeline.objects.prefetch_related('stages').select_related('owner').all()

        # Text search
        search_query = self.request.query_params.get('search') or self.request.query_params.get('q')
        if search_query:
            query = search_query.strip()
            queryset = queryset.filter(
                Q(name__icontains=query) | Q(description__icontains=query)
            )

        # Filter by is_active
        is_active = self.request.query_params.get('is_active')
        if is_active is not None:
            active_bool = is_active.lower() in ('true', '1', 'yes')
            queryset = queryset.filter(is_active=active_bool)

        # Filter by is_default
        is_default = self.request.query_params.get('is_default')
        if is_default is not None:
            default_bool = is_default.lower() in ('true', '1', 'yes')
            queryset = queryset.filter(is_default=default_bool)

        return queryset

    def perform_create(self, serializer):
        if 'owner' not in serializer.validated_data or serializer.validated_data['owner'] is None:
            serializer.save(owner=self.request.user)
        else:
            serializer.save()

    @action(detail=False, methods=['get'])
    def default(self, request):
        """
        Retrieves the default pipeline or bootstraps the Standard Sales Pipeline if none exists.
        """
        pipeline = Pipeline.objects.filter(is_default=True).first()
        if not pipeline:
            pipeline = Pipeline.objects.filter(name="Standard Sales Pipeline").first()

        if not pipeline:
            pipeline = Pipeline.objects.create(
                name="Standard Sales Pipeline",
                description="Default 6-stage sales pipeline for ClientSphere CRM.",
                is_default=True,
                is_active=True,
                owner=request.user,
            )
            stages_data = [
                ("Prospecting", 1, 10, False, False),
                ("Qualification", 2, 25, False, False),
                ("Proposal", 3, 50, False, False),
                ("Negotiation", 4, 75, False, False),
                ("Closed Won", 5, 100, True, False),
                ("Closed Lost", 6, 0, False, True),
            ]
            for name, order, prob, is_won, is_lost in stages_data:
                PipelineStage.objects.create(
                    pipeline=pipeline,
                    name=name,
                    order=order,
                    probability=prob,
                    is_won=is_won,
                    is_lost=is_lost,
                )

        serializer = self.get_serializer(pipeline)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def board(self, request):
        """
        Kanban Board view: Returns stages with live deal metrics and summary KPIs.
        """
        # Get active or default pipeline
        pipeline_id = request.query_params.get('pipeline')
        if pipeline_id:
            pipeline = Pipeline.objects.filter(pk=pipeline_id).prefetch_related('stages').first()
        else:
            pipeline = Pipeline.objects.filter(is_default=True).prefetch_related('stages').first()
            if not pipeline:
                pipeline = Pipeline.objects.prefetch_related('stages').first()

        # If no pipeline exists yet, bootstrap default
        if not pipeline:
            self.default(request)
            pipeline = Pipeline.objects.filter(is_default=True).prefetch_related('stages').first()

        stages = pipeline.stages.all().order_by('order') if pipeline else []

        # Map Deal stages to metrics
        deals_qs = Deal.objects.select_related('company', 'contact', 'owner').all()

        # Filter by owner if requested
        mine = request.query_params.get('mine')
        if mine and mine.lower() in ('true', '1', 'yes'):
            deals_qs = deals_qs.filter(owner=request.user)

        total_pipeline_value = Decimal('0.00')
        total_weighted_value = Decimal('0.00')
        total_deals_count = deals_qs.count()

        stage_columns = []
        for stage in stages:
            # Map by normalized stage name/slug to DealStage
            stage_slug = stage.name.lower().replace(" ", "_").replace("closed_", "")
            stage_deals = deals_qs.filter(stage__icontains=stage_slug[:4])

            stage_value = stage_deals.aggregate(total=Sum('value'))['total'] or Decimal('0.00')
            total_pipeline_value += stage_value

            deal_items = []
            for d in stage_deals[:50]:  # Cap at 50 per column for board responsiveness
                total_weighted_value += d.expected_revenue
                deal_items.append({
                    "id": d.id,
                    "title": d.title,
                    "value": str(d.value),
                    "expected_revenue": str(d.expected_revenue),
                    "probability": d.probability,
                    "company_name": d.company.name if d.company else None,
                    "contact_name": d.contact.full_name if d.contact else None,
                    "close_date": d.close_date.isoformat() if d.close_date else None,
                    "owner_name": d.owner.get_full_name() if d.owner else None,
                })

            stage_columns.append({
                "id": stage.id,
                "name": stage.name,
                "order": stage.order,
                "probability": stage.probability,
                "is_won": stage.is_won,
                "is_lost": stage.is_lost,
                "deals_count": stage_deals.count(),
                "total_value": str(stage_value),
                "deals": deal_items,
            })

        won_deals = deals_qs.filter(stage=DealStage.WON)
        won_value = won_deals.aggregate(total=Sum('value'))['total'] or Decimal('0.00')
        win_rate = (won_deals.count() / total_deals_count * 100) if total_deals_count > 0 else 0.0

        return Response({
            "pipeline": {
                "id": pipeline.id if pipeline else None,
                "name": pipeline.name if pipeline else "Standard Pipeline",
            },
            "metrics": {
                "total_deals": total_deals_count,
                "total_value": str(total_pipeline_value),
                "weighted_value": str(total_weighted_value),
                "won_value": str(won_value),
                "win_rate_percentage": round(win_rate, 1),
            },
            "stages": stage_columns,
        }, status=status.HTTP_200_OK)

    @action(detail=True, methods=['get'])
    def summary(self, request, pk=None):
        """
        Aggregate analytical summary for a specific pipeline.
        """
        pipeline = self.get_object()
        stages = pipeline.stages.all().order_by('order')

        stage_breakdowns = []
        for stage in stages:
            stage_slug = stage.name.lower().replace(" ", "_").replace("closed_", "")
            stage_deals = Deal.objects.filter(stage__icontains=stage_slug[:4])
            val = stage_deals.aggregate(total=Sum('value'))['total'] or Decimal('0.00')
            stage_breakdowns.append({
                "stage_id": stage.id,
                "stage_name": stage.name,
                "order": stage.order,
                "probability": stage.probability,
                "deal_count": stage_deals.count(),
                "deal_value": str(val),
            })

        total_deals = Deal.objects.count()
        total_val = Deal.objects.aggregate(total=Sum('value'))['total'] or Decimal('0.00')

        return Response({
            "pipeline_id": pipeline.id,
            "pipeline_name": pipeline.name,
            "total_stages": stages.count(),
            "total_deals": total_deals,
            "total_value": str(total_val),
            "stages": stage_breakdowns,
        }, status=status.HTTP_200_OK)


class PipelineStageViewSet(viewsets.ModelViewSet):
    """
    CRUD ViewSet for managing individual pipeline stages.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = PipelineStageSerializer
    pagination_class = None  # Stages list is typically small and fixed per pipeline

    def get_queryset(self):
        queryset = PipelineStage.objects.select_related('pipeline').all()
        pipeline_id = self.request.query_params.get('pipeline')
        if pipeline_id:
            queryset = queryset.filter(pipeline_id=pipeline_id)
        return queryset.order_by('pipeline', 'order')

    @action(detail=True, methods=['post'])
    def reorder(self, request, pk=None):
        """
        Update the sequence order of a pipeline stage.
        """
        stage = self.get_object()
        new_order = request.data.get('order')
        if new_order is None or not isinstance(new_order, int) or new_order < 1:
            return Response(
                {"error": "A positive integer 'order' is required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        stage.order = new_order
        stage.save(update_fields=['order', 'updated_at'])
        return Response(self.get_serializer(stage).data, status=status.HTTP_200_OK)
