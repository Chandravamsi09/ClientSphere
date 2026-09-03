from django.contrib import admin
from .models import Contact


@admin.register(Contact)
class ContactAdmin(admin.ModelAdmin):
    list_display = [
        'full_name',
        'email',
        'phone',
        'company_name',
        'job_title',
        'lifecycle_stage',
        'owner',
        'created_at',
    ]
    list_filter = ['lifecycle_stage', 'created_at', 'owner']
    search_fields = ['first_name', 'last_name', 'email', 'phone', 'company_name', 'job_title']
    readonly_fields = ['created_at', 'updated_at']
