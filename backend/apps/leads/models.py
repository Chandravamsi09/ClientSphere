from django.conf import settings
from django.db import models


class LeadStatus(models.TextChoices):
    NEW = 'new', 'New'
    CONTACTED = 'contacted', 'Contacted'
    QUALIFIED = 'qualified', 'Qualified'
    UNQUALIFIED = 'unqualified', 'Unqualified'
    CONVERTED = 'converted', 'Converted'


class LeadSource(models.TextChoices):
    WEBSITE = 'website', 'Website'
    REFERRAL = 'referral', 'Referral'
    COLD_OUTREACH = 'cold_outreach', 'Cold Outreach'
    EVENT = 'event', 'Event / Conference'
    ADVERTISEMENT = 'advertisement', 'Advertisement'
    PARTNER = 'partner', 'Partner'
    OTHER = 'other', 'Other'


class Lead(models.Model):
    """
    ClientSphere CRM Lead entity.
    Represents an inbound or outbound sales prospect before conversion.
    """
    first_name = models.CharField(max_length=120, db_index=True)
    last_name = models.CharField(max_length=120, db_index=True)
    email = models.EmailField(unique=True, db_index=True)
    phone = models.CharField(max_length=32, blank=True, default='')
    company_name = models.CharField(max_length=180, blank=True, default='', db_index=True)
    job_title = models.CharField(max_length=120, blank=True, default='')
    status = models.CharField(
        max_length=32,
        choices=LeadStatus.choices,
        default=LeadStatus.NEW,
        db_index=True
    )
    source = models.CharField(
        max_length=50,
        choices=LeadSource.choices,
        default=LeadSource.WEBSITE,
        db_index=True
    )
    estimated_value = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        null=True,
        blank=True,
        help_text='Potential pipeline or contract value if qualified'
    )
    notes = models.TextField(blank=True, default='')
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='leads',
        help_text='Assigned sales representative or SDR'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Lead'
        verbose_name_plural = 'Leads'
        indexes = [
            models.Index(fields=['last_name', 'first_name']),
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['source', 'created_at']),
        ]

    @property
    def full_name(self) -> str:
        name = f"{self.first_name} {self.last_name}".strip()
        return name if name else self.email

    def __str__(self):
        return f"{self.full_name} ({self.company_name or self.email})"
