from decimal import Decimal
from rest_framework import serializers
from .models import Deal, DealStage


class DealSerializer(serializers.ModelSerializer):
    """
    Comprehensive serializer for CRM Deal / Opportunity entity.
    """
    owner_name = serializers.SerializerMethodField(read_only=True)
    company_name = serializers.SerializerMethodField(read_only=True)
    contact_name = serializers.SerializerMethodField(read_only=True)
    stage_display = serializers.CharField(
        source='get_stage_display',
        read_only=True
    )
    expected_revenue = serializers.DecimalField(
        max_digits=14,
        decimal_places=2,
        read_only=True
    )

    class Meta:
        model = Deal
        fields = [
            'id',
            'title',
            'value',
            'stage',
            'stage_display',
            'probability',
            'expected_revenue',
            'close_date',
            'company',
            'company_name',
            'contact',
            'contact_name',
            'lead',
            'notes',
            'owner',
            'owner_name',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'owner_name',
            'company_name',
            'contact_name',
            'stage_display',
            'expected_revenue',
            'created_at',
            'updated_at',
        ]

    def get_owner_name(self, obj):
        if obj.owner:
            full_name = obj.owner.get_full_name()
            return full_name if full_name else obj.owner.username
        return None

    def get_company_name(self, obj):
        return obj.company.name if obj.company else None

    def get_contact_name(self, obj):
        return obj.contact.full_name if obj.contact else None

    def validate_title(self, value):
        clean = value.strip()
        if not clean:
            raise serializers.ValidationError("Deal title cannot be blank.")
        return clean

    def validate_value(self, value):
        if value < Decimal('0.00'):
            raise serializers.ValidationError("Deal value cannot be negative.")
        return value

    def validate_probability(self, value):
        if value < 0 or value > 100:
            raise serializers.ValidationError("Probability must be an integer between 0 and 100.")
        return value
