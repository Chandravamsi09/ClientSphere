from django.conf import settings
from django.db import models


class ContactLifecycleStage(models.TextChoices):
    LEAD = 'lead', 'Lead'
    PROSPECT = 'prospect', 'Prospect'
    OPPORTUNITY = 'opportunity', 'Opportunity'
    CUSTOMER = 'customer', 'Customer'
    CHURNED = 'churned', 'Churned'
    PARTNER = 'partner', 'Partner'


class Contact(models.Model):
    """
    ClientSphere CRM Contact entity.
    Represents an individual person / business contact.
    """
    first_name = models.CharField(max_length=120, db_index=True)
    last_name = models.CharField(max_length=120, db_index=True)
    email = models.EmailField(unique=True, db_index=True)
    phone = models.CharField(max_length=32, blank=True, default='')
    mobile = models.CharField(max_length=32, blank=True, default='')
    job_title = models.CharField(max_length=120, blank=True, default='')
    department = models.CharField(max_length=120, blank=True, default='')
    company_name = models.CharField(
        max_length=180,
        blank=True,
        default='',
        help_text='Associated company or organization name'
    )
    lifecycle_stage = models.CharField(
        max_length=32,
        choices=ContactLifecycleStage.choices,
        default=ContactLifecycleStage.LEAD,
        db_index=True
    )
    address = models.CharField(max_length=255, blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='')
    state = models.CharField(max_length=100, blank=True, default='')
    postal_code = models.CharField(max_length=20, blank=True, default='')
    country = models.CharField(max_length=100, blank=True, default='')
    notes = models.TextField(blank=True, default='')
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='contacts',
        help_text='Assigned CRM user responsible for this contact'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Contact'
        verbose_name_plural = 'Contacts'
        indexes = [
            models.Index(fields=['last_name', 'first_name']),
            models.Index(fields=['lifecycle_stage', 'created_at']),
        ]

    @property
    def full_name(self) -> str:
        name = f"{self.first_name} {self.last_name}".strip()
        return name if name else self.email

    def __str__(self):
        return f"{self.full_name} ({self.email})"
