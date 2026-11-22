
from django.db import models
from django.conf import settings


class Document(models.Model):

    DOCUMENT_TYPES = [
        ('contract', 'Contract'),
        ('evidence', 'Evidence'),
        ('court_order', 'Court Order'),
        ('petition', 'Petition'),
        ('agreement', 'Agreement'),
        ('other', 'Other'),
    ]

    lawyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='documents'
    )

    case = models.ForeignKey(
        'cases.Case',
        on_delete=models.CASCADE,
        related_name='documents',
        null=True,
        blank=True
    )

    title = models.CharField(max_length=200)

    document_type = models.CharField(
        max_length=30,
        choices=DOCUMENT_TYPES,
        default='other'
    )

    file = models.FileField(upload_to='legal_documents/')

    description = models.TextField(blank=True)

    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
