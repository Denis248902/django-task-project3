#!/usr/bin/env bash
set -e

echo "🚀 Запуск проверки Collect API (permissions + CRUD)..."
BASE_URL="http://127.0.0.1:8000"

# --- 1. Получаем токены ---
echo "🔑 Получение токенов..."

ADMIN_TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"SuperSecretPass123!"}' \
  "$BASE_URL/api/token/" \
  | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('access') or data.get('token'))")

if [ -z "$ADMIN_TOKEN" ]; then
  echo "❌ Ошибка: не удалось получить токен админа"
  exit 1
fi

USER_TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"viewer_user","password":"password123"}' \
  "$BASE_URL/api/token/" \
  | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('access') or data.get('token'))")

if [ -z "$USER_TOKEN" ]; then
  echo "❌ Ошибка: не удалось получить токен обычного пользователя"
  exit 1
fi

echo "✅ Токены получены."

# --- 2. Создаём сбор от имени админа (POST) ---
echo "📝 Создание сбора (админ)..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Collect by Admin",
    "reason": "Charity",
    "description": "Testing IsAuthorOrAdmin",
    "target_amount": 5000.0,
    "end_date": "2026-08-31T12:00:00Z"
  }' \
  "$BASE_URL/api/collects/")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
DATA=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" != "201" ]; then
  echo "❌ Ошибка создания: HTTP $HTTP_CODE, ответ: $DATA"
  exit 1
else
  COLLECT_ID=$(echo "$DATA" | python -c "import sys, json; print(json.load(sys.stdin).get('id'))")
  echo "✅ Сбор создан, ID: $COLLECT_ID"
fi

# --- 3. GET список (должен быть доступен всем) ---
echo "👁 Проверка GET списка (без авторизации)..."
GET_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/collects/")
GET_CODE=$(echo "$GET_RESPONSE" | tail -n1)
if [ "$GET_CODE" != "200" ]; then
  echo "❌ GET список не работает: HTTP $GET_CODE"
  exit 1
fi
echo "✅ GET список работает."

# --- 4. POST от обычного пользователя (должен быть запрещён) ---
echo "🚫 Проверка запрета POST для обычного пользователя..."
FORBIDDEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Forbidden Collect","target_amount":1000,"end_date":"2026-08-31T12:00:00Z"}' \
  "$BASE_URL/api/collects/")
FORBIDDEN_CODE=$(echo "$FORBIDDEN_RESPONSE" | tail -n1)
if [ "$FORBIDDEN_CODE" != "403" ]; then
  echo "❌ Ожидался 403, но получено: HTTP $FORBIDDEN_CODE, ответ: $FORBIDDEN_RESPONSE"
  exit 1
fi
echo "✅ Запрет POST для обычного пользователя работает."

# --- 5. PATCH чужого сбора (должен быть запрещён) ---
echo "🚫 Проверка запрета PATCH чужого сбора..."
PATCH_RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Changed Title"}' \
  "$BASE_URL/api/collects/$COLLECT_ID/")
PATCH_CODE=$(echo "$PATCH_RESPONSE" | tail -n1)
if [ "$PATCH_CODE" != "403" ]; then
  echo "❌ Ожидался 403 на PATCH чужого объекта, но получено: HTTP $PATCH_CODE"
  exit 1
fi
echo "✅ Запрет PATCH чужого сбора работает."

echo "🎉 Все проверки пройдены!"
