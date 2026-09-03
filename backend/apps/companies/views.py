from django.db.models import Q
from rest_framework import viewsets
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated

from .models import Company
from .serializers import CompanySerializer


class CompanyPagination(PageNumberPagination):
    """
    Standard pagination for Company endpoints.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class CompanyViewSet(viewsets.ModelViewSet):
    """
    CRUD API ViewSet for CRM Companies/Accounts.
    Supports full-text search, filtering by lifecycle stage, industry, size, and ownership.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CompanySerializer
    pagination_class = CompanyPagination

    def get_queryset(self):
        queryset = Company.objects.select_related('owner').all()

        # Search parameter
        search_query = self.request.query_params.get('search') or self.request.query_params.get('q')
        if search_query:
            query = search_query.strip()
            queryset = queryset.filter(
                Q(name__icontains=query) |
                Q(industry__icontains=query) |
                Q(city__icontains=query) |
                Q(country__icontains=query) |
                Q(email__icontains=query) |
                Q(phone__icontains=query) |
                Q(website__icontains=query)
            )

        # Filter by lifecycle stage
        lifecycle_stage = (
            self.request.query_params.get('lifecycle_stage') or
            self.request.query_params.get('stage')
        )
        if lifecycle_stage:
            queryset = queryset.filter(lifecycle_stage=lifecycle_stage.lower().strip())

        # Filter by industry
        industry = self.request.query_params.get('industry')
        if industry:
            queryset = queryset.filter(industry__iexact=industry.strip())

        # Filter by company size
        company_size = (
            self.request.query_params.get('company_size') or
            self.request.query_params.get('size')
        )
        if company_size:
            queryset = queryset.filter(company_size=company_size.strip())

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
            'name', '-name',
            'industry', '-industry',
            'annual_revenue', '-annual_revenue',
            'lifecycle_stage', '-lifecycle_stage',
        ]
        if ordering in valid_orderings:
            queryset = queryset.order_by(ordering)
        else:
            queryset = queryset.order_by('-created_at')

        return queryset

    def perform_create(self, serializer):
        """
        Assign owner to currently authenticated user if omitted.
        """
        if 'owner' not in serializer.validated_data or serializer.validated_data['owner'] is None:
            serializer.save(owner=self.request.user)
        else:
            serializer.save()
