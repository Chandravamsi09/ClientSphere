from rest_framework import serializers
from .models import Company, CompanyLifecycleStage, CompanySize


class CompanySerializer(serializers.ModelSerializer):
    """
    Comprehensive serializer for CRM Company model.
    """
    owner_name = serializers.SerializerMethodField(read_only=True)
    company_size_display = serializers.CharField(
        source='get_company_size_display',
        read_only=True
    )
    lifecycle_stage_display = serializers.CharField(
        source='get_lifecycle_stage_display',
        read_only=True
    )

    class Meta:
        model = Company
        fields = [
            'id',
            'name',
            'website',
            'industry',
            'company_size',
            'company_size_display',
            'annual_revenue',
            'phone',
            'email',
            'address',
            'city',
            'state',
            'postal_code',
            'country',
            'lifecycle_stage',
            'lifecycle_stage_display',
            'notes',
            'owner',
            'owner_name',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'owner_name',
            'company_size_display',
            'lifecycle_stage_display',
            'created_at',
            'updated_at',
        ]

    def get_owner_name(self, obj):
        if obj.owner:
            full_name = obj.owner.get_full_name()
            return full_name if full_name else obj.owner.username
        return None

    def validate_name(self, value):
        clean_name = value.strip()
        if not clean_name:
            raise serializers.ValidationError("Company name cannot be blank.")
        qs = Company.objects.filter(name__iexact=clean_name)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("A company with this name already exists.")
        return clean_name
