from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'email', 'first_name', 'last_name', 'role', 'quota', 'achieved', 'is_staff']
    list_filter = ['role', 'is_staff', 'is_superuser', 'is_active']
    fieldsets = BaseUserAdmin.fieldsets + (
        ('CRM Attributes', {'fields': ('role', 'phone', 'quota', 'achieved')}),
    )
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('CRM Attributes', {'fields': ('email', 'role', 'phone', 'quota', 'achieved')}),
    )
