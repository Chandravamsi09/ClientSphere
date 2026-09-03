from django.conf import settings
from django.db import models


class CompanySize(models.TextChoices):
    SIZE_1_10 = '1-10', '1-10 Employees'
    SIZE_11_50 = '11-50', '11-50 Employees'
    SIZE_51_200 = '51-200', '51-200 Employees'
    SIZE_201_500 = '201-500', '201-500 Employees'
    SIZE_501_1000 = '501-1000', '501-1000 Employees'
    SIZE_1000_PLUS = '1000+', '1000+ Employees'


class CompanyLifecycleStage(models.TextChoices):
    LEAD = 'lead', 'Lead'
    PROSPECT = 'prospect', 'Prospect'
    CUSTOMER = 'customer', 'Customer'
    CHURNED = 'churned', 'Churned'
    PARTNER = 'partner', 'Partner'


class Company(models.Model):
    """
    ClientSphere CRM Company / Account entity.
    Represents an organization, enterprise client, or partner account.
    """
    name = models.CharField(max_length=200, unique=True, db_index=True)
    website = models.URLField(max_length=255, blank=True, default='')
    industry = models.CharField(max_length=100, blank=True, default='', db_index=True)
    company_size = models.CharField(
        max_length=50,
        choices=CompanySize.choices,
        default=CompanySize.SIZE_11_50,
        db_index=True
    )
    annual_revenue = models.DecimalField(
        max_digits=14,
        decimal_places=2,
        null=True,
        blank=True,
        help_text='Estimated annual revenue in account currency'
    )
    phone = models.CharField(max_length=32, blank=True, default='')
    email = models.EmailField(blank=True, default='')
    address = models.CharField(max_length=255, blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='', db_index=True)
    state = models.CharField(max_length=100, blank=True, default='')
    postal_code = models.CharField(max_length=20, blank=True, default='')
    country = models.CharField(max_length=100, blank=True, default='', db_index=True)
    lifecycle_stage = models.CharField(
        max_length=32,
        choices=CompanyLifecycleStage.choices,
        default=CompanyLifecycleStage.PROSPECT,
        db_index=True
    )
    notes = models.TextField(blank=True, default='')
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='companies',
        help_text='Assigned account manager or sales owner'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Company'
        verbose_name_plural = 'Companies'
        indexes = [
            models.Index(fields=['industry', 'lifecycle_stage']),
            models.Index(fields=['city', 'country']),
        ]

    def __str__(self):
        return self.name
