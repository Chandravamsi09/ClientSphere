from django.db.models import Q
from rest_framework import status, viewsets
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Contact
from .serializers import ContactSerializer


class ContactPagination(PageNumberPagination):
    """
    Standard pagination for Contact list endpoints.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class ContactViewSet(viewsets.ModelViewSet):
    """
    CRUD API ViewSet for CRM Contacts.
    Supports filtering by lifecycle stage, ownership, text search, and pagination.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ContactSerializer
    pagination_class = ContactPagination

    def get_queryset(self):
        queryset = Contact.objects.select_related('owner').all()

        # Search parameter across text fields
        search_query = self.request.query_params.get('search') or self.request.query_params.get('q')
        if search_query:
            query = search_query.strip()
            queryset = queryset.filter(
                Q(first_name__icontains=query) |
                Q(last_name__icontains=query) |
                Q(email__icontains=query) |
                Q(phone__icontains=query) |
                Q(mobile__icontains=query) |
                Q(job_title__icontains=query) |
                Q(company_name__icontains=query)
            )

        # Filter by lifecycle stage
        lifecycle_stage = (
            self.request.query_params.get('lifecycle_stage') or
            self.request.query_params.get('stage')
        )
        if lifecycle_stage:
            queryset = queryset.filter(lifecycle_stage=lifecycle_stage.lower().strip())

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
            'last_name', '-last_name',
            'first_name', '-first_name',
            'company_name', '-company_name',
            'lifecycle_stage', '-lifecycle_stage',
        ]
        if ordering in valid_orderings:
            queryset = queryset.order_by(ordering)
        else:
            queryset = queryset.order_by('-created_at')

        return queryset

    def perform_create(self, serializer):
        """
        Default owner to currently authenticated user if not explicitly supplied.
        """
        if 'owner' not in serializer.validated_data or serializer.validated_data['owner'] is None:
            serializer.save(owner=self.request.user)
        else:
            serializer.save()
