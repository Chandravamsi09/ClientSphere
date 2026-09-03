from django.contrib import admin
from .models import Pipeline, PipelineStage


class PipelineStageInline(admin.TabularInline):
    model = PipelineStage
    extra = 1
    fields = ['name', 'order', 'probability', 'is_won', 'is_lost']


@admin.register(Pipeline)
class PipelineAdmin(admin.ModelAdmin):
    list_display = ['name', 'is_default', 'is_active', 'stages_count', 'owner', 'created_at']
    list_filter = ['is_default', 'is_active', 'created_at']
    search_fields = ['name', 'description']
    inlines = [PipelineStageInline]

    def stages_count(self, obj):
        return obj.stages.count()
    stages_count.short_description = 'Stages'


@admin.register(PipelineStage)
class PipelineStageAdmin(admin.ModelAdmin):
    list_display = ['name', 'pipeline', 'order', 'probability', 'is_won', 'is_lost', 'created_at']
    list_filter = ['pipeline', 'is_won', 'is_lost']
    search_fields = ['name', 'pipeline__name']
