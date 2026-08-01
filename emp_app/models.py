from django.db import models
from django.contrib.auth.models import User

class EmployeeProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='employee_profile', null=True, blank=True)
    full_name = models.CharField(max_length=255)
    position = models.CharField(max_length=100)
    hire_date = models.DateField(null=True, blank=True)
    years_of_experience = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.full_name} ({self.position})"
