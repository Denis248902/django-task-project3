from rest_framework import viewsets
from emp_app.models import EmployeeProfile
from emp_app.serializers import EmployeeProfileSerializer
from .permissions import IsAdminOrReadOnly

class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    permission_classes = [IsAdminOrReadOnly]
