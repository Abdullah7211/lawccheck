
from django.db import models


class Hearing(models.Model):

    case = models.ForeignKey(
        'cases.Case',
        on_delete=models.CASCADE,
        related_name='hearings'
    )

    hearing_date = models.DateField()

    hearing_time = models.TimeField(null=True, blank=True)

    court_name = models.CharField(max_length=200, blank=True)

    judge_name = models.CharField(max_length=150, blank=True)

    status = models.CharField(
        max_length=20,
        choices=[
            ('scheduled', 'Scheduled'),
            ('completed', 'Completed'),
            ('postponed', 'Postponed'),
            ('cancelled', 'Cancelled'),
        ],
        default='scheduled'
    )

    outcome = models.TextField(blank=True)

    notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['hearing_date', 'hearing_time']

    def __str__(self):
        return f"Hearing for {self.case.title} on {self.hearing_date}"
