from django.contrib import admin
from .models import Company


@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = [
        'name',
        'industry',
        'company_size',
        'lifecycle_stage',
        'city',
        'country',
        'annual_revenue',
        'owner',
        'created_at',
    ]
    list_filter = ['industry', 'company_size', 'lifecycle_stage', 'created_at', 'owner']
    search_fields = ['name', 'industry', 'city', 'country', 'email', 'website']
    readonly_fields = ['created_at', 'updated_at']
