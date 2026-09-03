from django.db.models import Q
from rest_framework import viewsets
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated

from .models import Lead
from .serializers import LeadSerializer


class LeadPagination(PageNumberPagination):
    """
    Standard pagination for Leads endpoints.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class LeadViewSet(viewsets.ModelViewSet):
    """
    CRUD API ViewSet for CRM Leads.
    Supports full-text search, status and source filtering, ownership assignment, and pagination.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = LeadSerializer
    pagination_class = LeadPagination

    def get_queryset(self):
        queryset = Lead.objects.select_related('owner').all()

        # Text search
        search_query = self.request.query_params.get('search') or self.request.query_params.get('q')
        if search_query:
            query = search_query.strip()
            queryset = queryset.filter(
                Q(first_name__icontains=query) |
                Q(last_name__icontains=query) |
                Q(email__icontains=query) |
                Q(phone__icontains=query) |
                Q(company_name__icontains=query) |
                Q(job_title__icontains=query)
            )

        # Filter by status
        status_param = self.request.query_params.get('status')
        if status_param:
            queryset = queryset.filter(status=status_param.lower().strip())

        # Filter by source
        source_param = self.request.query_params.get('source')
        if source_param:
            queryset = queryset.filter(source=source_param.lower().strip())

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
            'estimated_value', '-estimated_value',
            'status', '-status',
            'last_name', '-last_name',
            'first_name', '-first_name',
            'company_name', '-company_name',
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
