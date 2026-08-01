from rest_framework import viewsets
from .models import Collect
from .serializers import CollectSerializer
from .permissions import IsAuthorOrAdmin


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    permission_classes = [IsAuthorOrAdmin]
