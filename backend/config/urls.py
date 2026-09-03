"""
URL configuration for ClientSphere CRM backend project.
"""

from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.core.urls')),
    path('api/auth/', include('apps.authentication.urls')),
    path('api/contacts/', include('apps.contacts.urls')),
    path('api/companies/', include('apps.companies.urls')),
    path('api/leads/', include('apps.leads.urls')),
    path('api/deals/', include('apps.deals.urls')),
]
