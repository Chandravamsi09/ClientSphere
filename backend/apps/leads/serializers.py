from rest_framework import serializers
from .models import Lead, LeadSource, LeadStatus


class LeadSerializer(serializers.ModelSerializer):
    """
    Comprehensive serializer for CRM Lead model.
    """
    full_name = serializers.ReadOnlyField()
    owner_name = serializers.SerializerMethodField(read_only=True)
    status_display = serializers.CharField(
        source='get_status_display',
        read_only=True
    )
    source_display = serializers.CharField(
        source='get_source_display',
        read_only=True
    )

    class Meta:
        model = Lead
        fields = [
            'id',
            'first_name',
            'last_name',
            'full_name',
            'email',
            'phone',
            'company_name',
            'job_title',
            'status',
            'status_display',
            'source',
            'source_display',
            'estimated_value',
            'notes',
            'owner',
            'owner_name',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'full_name',
            'owner_name',
            'status_display',
            'source_display',
            'created_at',
            'updated_at',
        ]

    def get_owner_name(self, obj):
        if obj.owner:
            full_name = obj.owner.get_full_name()
            return full_name if full_name else obj.owner.username
        return None

    def validate_first_name(self, value):
        clean = value.strip()
        if not clean:
            raise serializers.ValidationError("First name cannot be blank.")
        return clean

    def validate_last_name(self, value):
        clean = value.strip()
        if not clean:
            raise serializers.ValidationError("Last name cannot be blank.")
        return clean

    def validate_email(self, value):
        normalized = value.lower().strip()
        qs = Lead.objects.filter(email__iexact=normalized)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("A lead with this email address already exists.")
        return normalized
