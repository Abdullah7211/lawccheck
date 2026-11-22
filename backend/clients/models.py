from django.db import models
from django.conf import settings


class Client(models.Model):

    lawyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='clients'
    )

    full_name = models.CharField(max_length=150)

    phone_number = models.CharField(max_length=20, blank=True)

    email = models.EmailField(blank=True)

    address = models.TextField(blank=True)

    notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.full_name