
from django.db import models
from django.conf import settings


class Task(models.Model):

    TASK_STATUS = [
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    TASK_PRIORITY = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]

    lawyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='tasks'
    )

    case = models.ForeignKey(
        'cases.Case',
        on_delete=models.CASCADE,
        related_name='tasks',
        null=True,
        blank=True
    )

    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)

    due_date = models.DateField(null=True, blank=True)

    priority = models.CharField(
        max_length=20,
        choices=TASK_PRIORITY,
        default='medium'
    )

    status = models.CharField(
        max_length=20,
        choices=TASK_STATUS,
        default='pending'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['due_date', '-created_at']

    def __str__(self):
        return self.title
