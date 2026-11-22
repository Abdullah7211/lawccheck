from rest_framework import viewsets, permissions, filters
from .models import Client
from .serializers import ClientSerializer


class ClientViewSet(viewsets.ModelViewSet):

    serializer_class = ClientSerializer

    permission_classes = [permissions.IsAuthenticated]

    filter_backends = [filters.SearchFilter]

    search_fields = ['full_name', 'phone_number']

    def get_queryset(self):
        return Client.objects.filter(lawyer=self.request.user)

    def perform_create(self, serializer):
        serializer.save(lawyer=self.request.user)