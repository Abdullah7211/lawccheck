
from django.db import models
from django.conf import settings


class Case(models.Model):

    CASE_STATUS = [
        ('pending', 'Pending'),
        ('ongoing', 'Ongoing'),
        ('completed', 'Completed'),
        ('dismissed', 'Dismissed'),
    ]

    lawyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='legal_cases'
    )

    client = models.ForeignKey(
        'clients.Client',
        on_delete=models.CASCADE,
        related_name='cases'
    )

    case_number = models.CharField(max_length=100, blank=True)

    title = models.CharField(max_length=200)

    case_type = models.CharField(max_length=100, blank=True)

    court_name = models.CharField(max_length=200, blank=True)

    status = models.CharField(
        max_length=20,
        choices=CASE_STATUS,
        default='pending'
    )

    filing_date = models.DateField(null=True, blank=True)

    next_hearing_date = models.DateField(null=True, blank=True)

    description = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title
