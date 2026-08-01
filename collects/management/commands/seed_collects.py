from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from collects.models import Collect, Payment
from django.utils import timezone
from datetime import timedelta
import random

User = get_user_model()


class Command(BaseCommand):
    help = "Создаёт тестовые данные для Collect и Payment"

    def handle(self, *args, **options):
        self.stdout.write("🔄 Очистка старых тестовых записей...")
        Collect.objects.filter(title__startswith="[TEST]").delete()
        Payment.objects.filter(comment__startswith="[TEST]").delete()

        # Создадим одного тестового юзера, если нет
        user, created = User.objects.get_or_create(
            username="test_user", defaults={"password": "password123"}
        )
        if created:
            user.set_password("password123")
            user.save()
            self.stdout.write(f"✅ Создан тестовый пользователь: {user.username}")

        reasons = ["birthday", "wedding", "moving", "gift", "other"]
        collects = []
        for i in range(5):
            title = f"[TEST] Сбор #{i+1} на подарок"
            collect = Collect.objects.create(
                author=user,
                title=title,
                reason=random.choice(reasons),
                description=f"Тестовый сбор №{i+1}",
                target_amount=10000.00,
                end_date=timezone.now() + timedelta(days=random.randint(3, 14)),
            )
            collects.append(collect)

        payments = []
        for collect in collects:
            # Для каждого сбора создадим 3–7 платежей
            for j in range(random.randint(3, 7)):
                amount = round(random.uniform(500, 2000), 2)
                payment = Payment.objects.create(
                    collect=collect,
                    payer=user,
                    amount=amount,
                    comment=f"[TEST] Платёж #{j+1} для {collect.title}",
                )
                payments.append(payment)

        self.stdout.write(
            self.style.SUCCESS(
                f"✅ Готово: {len(collects)} сборов, {len(payments)} платежей"
            )
        )
