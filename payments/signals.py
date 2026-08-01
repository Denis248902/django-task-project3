from django.db.models import Sum
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Payment


@receiver(post_save, sender=Payment)
def update_collect_total(sender, instance, created, **kwargs):
    if not created:
        # Пока не пересчитываем при редактировании платежа — чтобы не усложнять
        return

    collect = instance.collect
    # Агрегируем сумму всех платежей по этому сбору
    total = collect.payments.aggregate(Sum("amount"))["amount__sum"] or 0
    collect.collected_amount = total
    collect.save(update_fields=["collected_amount"])
