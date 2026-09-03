from rest_framework import serializers
from .models import Contact, ContactLifecycleStage


class ContactSerializer(serializers.ModelSerializer):
    """
    Comprehensive serializer for CRM Contact model.
    """
    full_name = serializers.ReadOnlyField()
    owner_name = serializers.SerializerMethodField(read_only=True)
    lifecycle_stage_display = serializers.CharField(
        source='get_lifecycle_stage_display',
        read_only=True
    )

    class Meta:
        model = Contact
        fields = [
            'id',
            'first_name',
            'last_name',
            'full_name',
            'email',
            'phone',
            'mobile',
            'job_title',
            'department',
            'company_name',
            'lifecycle_stage',
            'lifecycle_stage_display',
            'address',
            'city',
            'state',
            'postal_code',
            'country',
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
            'lifecycle_stage_display',
            'created_at',
            'updated_at',
        ]

    def get_owner_name(self, obj):
        if obj.owner:
            full_name = obj.owner.get_full_name()
            return full_name if full_name else obj.owner.username
        return None

    def validate_email(self, value):
        normalized = value.lower().strip()
        qs = Contact.objects.filter(email__iexact=normalized)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("A contact with this email address already exists.")
        return normalized

    def validate_first_name(self, value):
        clean_val = value.strip()
        if not clean_val:
            raise serializers.ValidationError("First name cannot be blank.")
        return clean_val

    def validate_last_name(self, value):
        clean_val = value.strip()
        if not clean_val:
            raise serializers.ValidationError("Last name cannot be blank.")
        return clean_val
