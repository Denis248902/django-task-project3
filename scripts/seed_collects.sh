echo "💵 Создаём тестовые платежи и обновляем collected_amount..."

python manage.py shell << 'EOF'
import decimal
from django.contrib.auth import get_user_model
from collects.models import Collect, Payment

User = get_user_model()

# Получаем пользователей
try:
    admin = User.objects.get(username='admin')
    test_user = User.objects.get(username='test_user')
except User.DoesNotExist as e:
    print(f"❌ Пользователь не найден: {e}")
    exit(1)

# Берём первый сбор для тестов
collect = Collect.objects.first()
if not collect:
    print("❌ Нет ни одного сбора — сначала создай сбор в скрипте.")
else:
    # Создаём несколько платежей
    Payment.objects.create(collect=collect, payer=admin, amount=decimal.Decimal('1000.00'), comment="Взнос от автора")
    Payment.objects.create(collect=collect, payer=test_user, amount=decimal.Decimal('500.00'), comment="Поддержка сбора")
    Payment.objects.create(collect=collect, payer=test_user, amount=decimal.Decimal('200.00'), comment="Ещё немного")

    # Пересчитываем collected_amount
    total = sum(p.amount for p in collect.payments.all())
    collect.collected_amount = total
    collect.save()
    print(f"✅ Платежи созданы. collected_amount = {total}")
EOF

echo "✅ Seed завершён."
