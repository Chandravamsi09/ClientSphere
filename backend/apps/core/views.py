from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class HealthCheckView(APIView):
    """
    Health check endpoint returning the status of the ClientSphere Django API service.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(
            {
                "status": "ok",
                "service": "ClientSphere Backend API",
                "framework": "Django + Django REST Framework",
                "version": "1.0.0",
            },
            status=status.HTTP_200_OK,
        )


class ApiRootView(APIView):
    """
    API Root endpoint welcoming clients and listing registered services.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(
            {
                "name": "ClientSphere CRM API",
                "version": "1.0.0",
                "architecture": "Django + DRF + PostgreSQL",
                "endpoints": {
                    "health": request.build_absolute_uri("health/"),
                    "auth": request.build_absolute_uri("/api/auth/"),
                    "contacts": request.build_absolute_uri("/api/contacts/"),
                    "companies": request.build_absolute_uri("/api/companies/"),
                    "leads": request.build_absolute_uri("/api/leads/"),
                    "deals": request.build_absolute_uri("/api/deals/"),
                    "admin": request.build_absolute_uri("/admin/"),
                },
                "status": "Foundation Ready",
            },
            status=status.HTTP_200_OK,
        )
