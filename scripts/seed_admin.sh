#!/usr/bin/env bash
set -euo pipefail

# Запускаем чистый Python-скрипт с ручной инициализацией Django
python - <<EOF
import os
import django

# Указываем точный путь к настройкам (из твоего пути: core/settings.py)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

user = User.objects.filter(username='deni').first()
if not user:
    user = User.objects.create_superuser('deni', 'deni@example.com', '1')
    print('✅ Создан новый суперпользователь deni')
else:
    user.is_active = True
    user.set_password('1')
    user.save()
    print('✅ Обновлён существующий пользователь deni')

print('✅ Готово: админ deni готов к работе')
EOF
