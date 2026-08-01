from rest_framework import viewsets
from .models import Payment
from .serializers import PaymentSerializer

# Если пермишны лежат в collects — можно оставить так. Если сделаешь payments/permissions.py — замени на .permissions
from collects.permissions import IsAuthorOrAdmin


class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthorOrAdmin]
