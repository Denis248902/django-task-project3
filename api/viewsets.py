from rest_framework import viewsets
from emp_app.models import EmployeeProfile
from emp_app.serializers import EmployeeProfileSerializer
from .permissions import IsAdminOrEditorOrReadOnly  # <-- новый пермишн

class EmployeeProfileViewSet(viewsets.ModelViewSet):
    queryset = EmployeeProfile.objects.all()
    serializer_class = EmployeeProfileSerializer
    permission_classes = [IsAdminOrEditorOrReadOnly]
