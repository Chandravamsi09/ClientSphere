from django.urls import include, path
from rest_framework.routers import DefaultRouter
from .views import PipelineStageViewSet, PipelineViewSet

app_name = 'pipeline'

router = DefaultRouter()
router.register(r'stages', PipelineStageViewSet, basename='pipeline-stage')
router.register(r'', PipelineViewSet, basename='pipeline')

urlpatterns = [
    path('', include(router.urls)),
]
