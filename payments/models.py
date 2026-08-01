from django.contrib.auth import get_user_model
from django.db import models

User = get_user_model()


class Payment(models.Model):
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    paid_at = models.DateTimeField(auto_now_add=True)
    collect = models.ForeignKey(
        "collects.Collect", on_delete=models.CASCADE, related_name="payments"
    )
    payer = models.ForeignKey(User, on_delete=models.PROTECT)

    def __str__(self):
        full_name = f"{self.payer.first_name} {self.payer.last_name}".strip()
        name = full_name if full_name else self.payer.username
        return f"{self.amount} от {name}"
