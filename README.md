# django-task-project3

Django + DRF API для управления сборами средств. Реализована ролевая модель: админ может создавать/редактировать, обычный пользователь — только просматривать. Также есть автопересчёт суммы собранных средств через сигналы.

## Быстрый старт (локально)

### 1. Клонирование и окружение

```bash
git clone https://github.com/Denis248902/django-task-project3.git
cd django-task-project3
python -m venv venv
source venv/Scripts/activate  # Windows / MINGW64
pip install -r requirements.txt