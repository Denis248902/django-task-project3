from rest_framework import viewsets
from .models import EmployeeProfile
from .serializers import EmployeeProfileSerializer
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
