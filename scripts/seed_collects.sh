#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Запуск seed_collects.sh..."

# 1. Создаём пользователей
python manage.py shell < scripts/create_users.py

# 2. Создаём сборы
python manage.py shell << 'INNER_EOF'
from django.contrib.auth import get_user_model
from collects.models import Collect
from datetime import datetime, timedelta, timezone

User = get_user_model()
admin = User.objects.get(username='admin')
test_user = User.objects.get(username='test_user')

now = datetime.now(timezone.utc)

if not Collect.objects.filter(title='Admin collect').exists():
    Collect.objects.create(
        author=admin,
        title='Admin collect',
        reason='wedding',
        target_amount=10000,
        end_date=now + timedelta(days=30)
    )
    print("✅ Сбор от админа создан.")
else:
    print("ℹ️ Сбор от админа уже существует.")

if not Collect.objects.filter(title='Test user collect').exists():
    Collect.objects.create(
        author=test_user,
        title='Test user collect',
        reason='birthday',
        target_amount=5000,
        end_date=now + timedelta(days=15)
    )
    print("✅ Сбор от test_user создан.")
else:
    print("ℹ️ Сбор от test_user уже существует.")
INNER_EOF

echo "✅ Seed завершён."
