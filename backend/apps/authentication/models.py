from django.contrib.auth.models import AbstractUser
from django.db import models


class UserRole(models.TextChoices):
    ADMIN = 'admin', 'Administrator'
    MANAGER = 'manager', 'Sales Manager'
    SALES_REP = 'sales_rep', 'Sales Representative'
    SUPPORT = 'support', 'Support Specialist'


class User(AbstractUser):
    """
    Custom user model for ClientSphere CRM.
    Supports email authentication, role-based CRM permissions, and sales quotas.
    """
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=32, blank=True, default='')
    role = models.CharField(
        max_length=32,
        choices=UserRole.choices,
        default=UserRole.SALES_REP
    )
    quota = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0.00,
        help_text='Assigned sales quota amount'
    )
    achieved = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0.00,
        help_text='Achieved sales revenue to date'
    )

    REQUIRED_FIELDS = ['email']

    class Meta:
        ordering = ['id']
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f"{self.username} ({self.get_full_name() or self.email})"
