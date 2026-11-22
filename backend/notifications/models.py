
from django.db import models
from django.conf import settings


class Notification(models.Model):

    NOTIFICATION_TYPES = [
        ('hearing', 'Hearing'),
        ('task', 'Task'),
        ('case', 'Case'),
        ('document', 'Document'),
        ('general', 'General'),
    ]

    lawyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )

    title = models.CharField(max_length=200)

    message = models.TextField()

    notification_type = models.CharField(
        max_length=20,
        choices=NOTIFICATION_TYPES,
        default='general'
    )

    is_read = models.BooleanField(default=False)

    deduplication_key = models.CharField(
    max_length=255,
    unique=True,
    null=True,
    blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title
