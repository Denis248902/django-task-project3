#!/usr/bin/env bash
set -euo pipefail

echo "🌱 Seeding employees via API..."

# Получаем свежий токен для viewer_user
ACCESS_TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"viewer_user","password":"password123"}' \
  http://127.0.0.1:8000/api/token/ | python -c "import sys, json; r=json.load(sys.stdin); print(r.get('access', ''))")

if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Failed to get access token. Check credentials and server." >&2
  exit 1
fi

# Список сотрудников
EMPLOYEES=(
  '{"full_name":"Alice Johnson","position":"Senior Developer","hire_date":"2022-03-15","years_of_experience":4}'
  '{"full_name":"Bob Smith","position":"DevOps Engineer","hire_date":"2021-07-20","years_of_experience":5}'
  '{"full_name":"Carol Lee","position":"QA Lead","hire_date":"2020-11-10","years_of_experience":6}'
  '{"full_name":"David Kim","position":"Frontend Developer","hire_date":"2023-01-05","years_of_experience":3}'
  '{"full_name":"Eva Martinez","position":"Product Manager","hire_date":"2019-09-01","years_of_experience":7}'
)

for payload in "${EMPLOYEES[@]}"; do
  echo "  → Creating employee: $payload"
  curl -s -w "\n" -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    http://127.0.0.1:8000/api/employees/
done

echo "✅ Employees seeded."
