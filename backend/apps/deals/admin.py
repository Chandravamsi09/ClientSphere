from django.contrib import admin
from .models import Deal


@admin.register(Deal)
class DealAdmin(admin.ModelAdmin):
    list_display = [
        'title',
        'value',
        'stage',
        'probability',
        'expected_revenue',
        'close_date',
        'company',
        'contact',
        'owner',
        'created_at',
    ]
    list_filter = ['stage', 'close_date', 'owner', 'created_at']
    search_fields = ['title', 'company__name', 'contact__first_name', 'contact__last_name']
    readonly_fields = ['created_at', 'updated_at', 'expected_revenue']
