from rest_framework.routers import DefaultRouter
from .viewsets import EmployeeProfileViewSet

router = DefaultRouter()
router.register(r'employees', EmployeeProfileViewSet, basename='employee')

urlpatterns = router.urls
