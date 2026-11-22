
from django.http import FileResponse
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied

from .models import Document
from .serializers import DocumentSerializer


class DocumentViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Document.objects.filter(lawyer=self.request.user)

    def perform_create(self, serializer):
        case = serializer.validated_data.get('case')
        if case and case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot upload documents to another lawyer's case."
            )
        serializer.save(lawyer=self.request.user)

    def perform_update(self, serializer):
        case = serializer.validated_data.get(
            'case',
            serializer.instance.case
        )
        if case and case.lawyer != self.request.user:
            raise PermissionDenied(
                "You cannot move a document to another lawyer's case."
            )
        serializer.save()

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        document = self.get_object()

        if not document.file:
            from rest_framework.exceptions import NotFound
            raise NotFound("Document file not found.")

        return FileResponse(
            document.file.open('rb'),
            as_attachment=True,
            filename=document.file.name.split('/')[-1]
        )
