#!/usr/bin/env bash
set -euo pipefail

# Получаем ID сбора (тут парсинг допустим — он простой)
COLLECT_ID=$(python manage.py shell <<PYEOF
from collects.models import Collect
c = Collect.objects.first()
if c:
    print(c.id)
PYEOF
)
COLLECT_ID=$(echo "$COLLECT_ID" | grep -oE '[0-9]+' | head -n 1)

if [ -z "$COLLECT_ID" ]; then
  echo "❌ Нет ни одного сбора — сначала запусти seed"
  exit 1
fi
echo "✅ Используем сбор: id=$COLLECT_ID"

# ВАЖНО: жёстко задаём ID админа, чтобы не зависеть от парсинга shell-вывода
PAYER_ID=4
echo "👤 Плательщик: id=$PAYER_ID"

# Формируем JSON
PAYLOAD="{\"collect\":$COLLECT_ID,\"payer\":$PAYER_ID,\"amount\":300.0,\"comment\":\"Test payment via script\"}"

echo "📤 Отправляем платёж: $PAYLOAD"

RESPONSE=$(curl -s -u admin:admin123 \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  http://127.0.0.1:8000/api/payments/)

echo "$RESPONSE" | python -m json.tool || true

NEW_PAYMENT_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]\+' | head -n 1 | cut -d':' -f2)
if [ -n "$NEW_PAYMENT_ID" ]; then
  echo "✅ Платёж создан: id=$NEW_PAYMENT_ID"
else
  echo "❌ Платёж не создан — смотри выше JSON"
  exit 1
fi

sleep 0.5

COLLECT_DATA=$(curl -s -u admin:admin123 \
  -H "Content-Type: application/json" \
  http://127.0.0.1:8000/api/collects/$COLLECT_ID/)

CURRENT_AMOUNT=$(echo "$COLLECT_DATA" | grep -o '"collected_amount":"[^"]\+"' | sed 's/.*"\([^"]*\)".*/\1/')
echo "💰 collected_amount после платежа: $CURRENT_AMOUNT"

if echo "$CURRENT_AMOUNT" | grep -qE '^(300|300\.0+|[4-9][0-9]{2,}|[1-9][0-9]{3,})'; then
  echo "🎉 Сигнал сработал: сумма >= 300!"
else
  echo "⚠️ collected_amount < 300 — возможно, сигнал не сработал"
fi
