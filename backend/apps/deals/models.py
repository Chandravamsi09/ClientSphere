from decimal import Decimal
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class DealStage(models.TextChoices):
    PROSPECTING = 'prospecting', 'Prospecting'
    QUALIFICATION = 'qualification', 'Qualification'
    PROPOSAL = 'proposal', 'Proposal / Pitch'
    NEGOTIATION = 'negotiation', 'Negotiation / Review'
    WON = 'won', 'Closed Won'
    LOST = 'lost', 'Closed Lost'


class Deal(models.Model):
    """
    ClientSphere CRM Deal / Opportunity entity.
    Tracks deal stages, values, probabilities, and account relationships.
    """
    title = models.CharField(max_length=200, db_index=True)
    value = models.DecimalField(
        max_digits=14,
        decimal_places=2,
        default=Decimal('0.00'),
        validators=[MinValueValidator(Decimal('0.00'))],
        help_text='Total contractual or deal financial value'
    )
    stage = models.CharField(
        max_length=32,
        choices=DealStage.choices,
        default=DealStage.PROSPECTING,
        db_index=True
    )
    probability = models.PositiveIntegerField(
        default=10,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Estimated win probability percentage (0 - 100)'
    )
    close_date = models.DateField(
        null=True,
        blank=True,
        db_index=True,
        help_text='Expected or actual closing date'
    )
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='deals',
        help_text='Associated business account'
    )
    contact = models.ForeignKey(
        'contacts.Contact',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='deals',
        help_text='Primary customer contact'
    )
    lead = models.ForeignKey(
        'leads.Lead',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='deals',
        help_text='Originating lead record if converted'
    )
    notes = models.TextField(blank=True, default='')
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='deals',
        help_text='Assigned account executive or sales representative'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Deal'
        verbose_name_plural = 'Deals'
        indexes = [
            models.Index(fields=['stage', 'created_at']),
            models.Index(fields=['close_date']),
            models.Index(fields=['value']),
        ]

    @property
    def expected_revenue(self) -> Decimal:
        """
        Weighted pipeline revenue based on deal probability.
        """
        if self.value and self.probability is not None:
            return round(self.value * Decimal(self.probability) / Decimal(100), 2)
        return Decimal('0.00')

    def __str__(self):
        return f"{self.title} (${self.value:,.2f})"
