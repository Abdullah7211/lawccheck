
from rest_framework import viewsets, permissions
from rest_framework.exceptions import PermissionDenied

from .models import Task
from .serializers import TaskSerializer


class TaskViewSet(viewsets.ModelViewSet):

    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Task.objects.filter(
            lawyer=self.request.user
        )

    def perform_create(self, serializer):
        case = serializer.validated_data.get('case')

        if case and case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot create a task for another lawyer's case."
            )

        serializer.save(lawyer=self.request.user)

    def perform_update(self, serializer):
        case = serializer.validated_data.get(
            'case',
            serializer.instance.case
        )

        if case and case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot assign a task to another lawyer's case."
            )

        serializer.save()
