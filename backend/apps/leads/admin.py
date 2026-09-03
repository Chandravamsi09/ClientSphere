from django.contrib import admin
from .models import Lead


@admin.register(Lead)
class LeadAdmin(admin.ModelAdmin):
    list_display = [
        'full_name',
        'email',
        'phone',
        'company_name',
        'status',
        'source',
        'estimated_value',
        'owner',
        'created_at',
    ]
    list_filter = ['status', 'source', 'created_at', 'owner']
    search_fields = ['first_name', 'last_name', 'email', 'phone', 'company_name', 'job_title']
    readonly_fields = ['created_at', 'updated_at']
