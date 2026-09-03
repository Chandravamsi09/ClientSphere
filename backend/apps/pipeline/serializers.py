from decimal import Decimal
from rest_framework import serializers
from .models import Pipeline, PipelineStage


class PipelineStageSerializer(serializers.ModelSerializer):
    """
    Serializer for individual pipeline stages.
    """
    class Meta:
        model = PipelineStage
        fields = [
            'id',
            'pipeline',
            'name',
            'order',
            'probability',
            'is_won',
            'is_lost',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_name(self, value):
        clean = value.strip()
        if not clean:
            raise serializers.ValidationError("Stage name cannot be blank.")
        return clean

    def validate_probability(self, value):
        if value < 0 or value > 100:
            raise serializers.ValidationError("Probability must be an integer between 0 and 100.")
        return value


class PipelineSerializer(serializers.ModelSerializer):
    """
    Serializer for Pipeline entity with nested stages and aggregate metrics.
    """
    stages = PipelineStageSerializer(many=True, read_only=True)
    stages_count = serializers.IntegerField(source='stages.count', read_only=True)
    owner_name = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Pipeline
        fields = [
            'id',
            'name',
            'description',
            'is_default',
            'is_active',
            'stages_count',
            'stages',
            'owner',
            'owner_name',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'stages_count', 'stages', 'owner_name', 'created_at', 'updated_at']

    def get_owner_name(self, obj):
        if obj.owner:
            full_name = obj.owner.get_full_name()
            return full_name if full_name else obj.owner.username
        return None

    def validate_name(self, value):
        clean = value.strip()
        if not clean:
            raise serializers.ValidationError("Pipeline name cannot be blank.")
        qs = Pipeline.objects.filter(name__iexact=clean)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("A pipeline with this name already exists.")
        return clean
