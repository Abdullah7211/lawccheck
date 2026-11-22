
from rest_framework import viewsets, permissions
from rest_framework.exceptions import PermissionDenied

from .models import Hearing
from .serializers import HearingSerializer


class HearingViewSet(viewsets.ModelViewSet):

    serializer_class = HearingSerializer

    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Hearing.objects.filter(
            case__lawyer=self.request.user
        )

    def perform_create(self, serializer):
        case = serializer.validated_data['case']

        if case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot schedule a hearing for another lawyer's case."
            )

        serializer.save()

    def perform_update(self, serializer):
        case = serializer.validated_data.get(
            'case',
            serializer.instance.case
        )

        if case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot move a hearing to another lawyer's case."
            )

        serializer.save()
