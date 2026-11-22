
from rest_framework import viewsets, permissions
from .models import Case
from .serializers import CaseSerializer
from rest_framework.exceptions import PermissionDenied


class CaseViewSet(viewsets.ModelViewSet):

    serializer_class = CaseSerializer

    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Case.objects.filter(lawyer=self.request.user)

    def perform_create(self, serializer):
        client = serializer.validated_data['client']

        if client.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot create a case for another lawyer's client."
            )

        serializer.save(lawyer=self.request.user)

    def perform_update(self, serializer):
        client = serializer.validated_data.get(
            'client',
            serializer.instance.client
        )

        if client.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot assign another lawyer's client to your case."
            )

        serializer.save()
