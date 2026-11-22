from rest_framework import viewsets, permissions
from .models import Notification
from .serializers import NotificationSerializer
from rest_framework.decorators import action
from rest_framework.response import Response


class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = Notification.objects.filter(lawyer=self.request.user)

        is_read = self.request.query_params.get('is_read')

        if is_read is not None:
            if is_read.lower() == 'true':
                queryset = queryset.filter(is_read=True)
            elif is_read.lower() == 'false':
                queryset = queryset.filter(is_read=False)

        return queryset

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        count = self.get_queryset().filter(is_read=False).count()

        return Response({
            'unread_count': count
        })

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        updated_count = self.get_queryset().filter(
            is_read=False
        ).update(is_read=True)

        return Response({
            'message': 'All notifications marked as read.',
            'updated_count': updated_count
        })

    def perform_create(self, serializer):
        serializer.save(lawyer=self.request.user)