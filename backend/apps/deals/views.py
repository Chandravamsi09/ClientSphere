from django.db.models import Q
from rest_framework import viewsets
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated

from .models import Deal
from .serializers import DealSerializer


class DealPagination(PageNumberPagination):
    """
    Standard pagination for Deals endpoints.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class DealViewSet(viewsets.ModelViewSet):
    """
    CRUD API ViewSet for CRM Deals / Opportunities.
    Supports full-text search, stage and account filtering, ownership assignment, and pagination.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = DealSerializer
    pagination_class = DealPagination

    def get_queryset(self):
        queryset = Deal.objects.select_related('owner', 'company', 'contact', 'lead').all()

        # Text search across title, company name, contact names, notes
        search_query = self.request.query_params.get('search') or self.request.query_params.get('q')
        if search_query:
            query = search_query.strip()
            queryset = queryset.filter(
                Q(title__icontains=query) |
                Q(company__name__icontains=query) |
                Q(contact__first_name__icontains=query) |
                Q(contact__last_name__icontains=query) |
                Q(notes__icontains=query)
            )

        # Filter by stage
        stage = self.request.query_params.get('stage')
        if stage:
            queryset = queryset.filter(stage=stage.lower().strip())

        # Filter by company ID
        company_id = self.request.query_params.get('company')
        if company_id:
            queryset = queryset.filter(company_id=company_id)

        # Filter by contact ID
        contact_id = self.request.query_params.get('contact')
        if contact_id:
            queryset = queryset.filter(contact_id=contact_id)

        # Filter by lead ID
        lead_id = self.request.query_params.get('lead')
        if lead_id:
            queryset = queryset.filter(lead_id=lead_id)

        # Filter by ownership
        mine = self.request.query_params.get('mine')
        if mine and mine.lower() in ('true', '1', 'yes'):
            queryset = queryset.filter(owner=self.request.user)
        else:
            owner_id = self.request.query_params.get('owner')
            if owner_id:
                queryset = queryset.filter(owner_id=owner_id)

        # Ordering
        ordering = self.request.query_params.get('ordering')
        valid_orderings = [
            'created_at', '-created_at',
            'updated_at', '-updated_at',
            'value', '-value',
            'close_date', '-close_date',
            'probability', '-probability',
            'title', '-title',
            'stage', '-stage',
        ]
        if ordering in valid_orderings:
            queryset = queryset.order_by(ordering)
        else:
            queryset = queryset.order_by('-created_at')

        return queryset

    def perform_create(self, serializer):
        """
        Default owner to currently authenticated user if omitted.
        """
        if 'owner' not in serializer.validated_data or serializer.validated_data['owner'] is None:
            serializer.save(owner=self.request.user)
        else:
            serializer.save()
