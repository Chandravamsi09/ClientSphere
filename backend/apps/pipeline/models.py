from decimal import Decimal
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Pipeline(models.Model):
    """
    Sales Pipeline entity representing a structured multi-stage sales process.
    """
    name = models.CharField(max_length=150, unique=True, db_index=True)
    description = models.TextField(blank=True, default='')
    is_default = models.BooleanField(default=False, db_index=True)
    is_active = models.BooleanField(default=True, db_index=True)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='pipelines',
        help_text='Pipeline administrator or creator'
    )
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-is_default', 'name']
        verbose_name = 'Sales Pipeline'
        verbose_name_plural = 'Sales Pipelines'

    def save(self, *args, **kwargs):
        # If this pipeline is set as default, clear default on other pipelines
        if self.is_default:
            Pipeline.objects.filter(is_default=True).exclude(pk=self.pk).update(is_default=False)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class PipelineStage(models.Model):
    """
    Represents an individual phase/step within a Sales Pipeline.
    """
    pipeline = models.ForeignKey(
        Pipeline,
        on_delete=models.CASCADE,
        related_name='stages'
    )
    name = models.CharField(max_length=100, db_index=True)
    order = models.PositiveIntegerField(default=1, db_index=True)
    probability = models.PositiveIntegerField(
        default=10,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Default win probability percentage (0-100) for this stage'
    )
    is_won = models.BooleanField(default=False, help_text='Marks closing stage as won')
    is_lost = models.BooleanField(default=False, help_text='Marks closing stage as lost')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['pipeline', 'order']
        verbose_name = 'Pipeline Stage'
        verbose_name_plural = 'Pipeline Stages'
        constraints = [
            models.UniqueConstraint(
                fields=['pipeline', 'name'],
                name='unique_stage_name_per_pipeline'
            ),
        ]

    def __str__(self):
        return f"{self.pipeline.name} - {self.name} (#{self.order})"
