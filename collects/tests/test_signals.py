from django.test import TestCase
from django.contrib.auth import get_user_model
from collects.models import Collect, Payment
from django.db.models import Sum
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class PaymentSignalTest(TestCase):
    def setUp(self):
        # Создаём админа
        self.admin = User.objects.create_user(
            username='admin',
            password='admin123'
        )
        # Создаём сбор с обязательным end_date
        self.collect = Collect.objects.create(
            title='Test Collect',
            target_amount=1000.00,
            author=self.admin,
            end_date=timezone.now() + timedelta(days=30)  # <-- добавляем дату
        )

    def test_signal_updates_collected_amount(self):
        initial_amount = self.collect.collected_amount
        self.assertEqual(initial_amount, 0.0)

        # Создаём платёж — должен сработать сигнал и обновить collected_amount
        payment = Payment.objects.create(
            collect=self.collect,
            payer=self.admin,
            amount=300.0,
            comment='Test payment via TestCase'
        )

        self.collect.refresh_from_db()
        expected_amount = initial_amount + payment.amount
        self.assertEqual(self.collect.collected_amount, expected_amount)

        total = self.collect.payments.aggregate(total=Sum('amount'))['total'] or 0
        self.assertEqual(self.collect.collected_amount, total)
