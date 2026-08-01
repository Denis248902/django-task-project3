#!/usr/bin/env bash
set -e
echo "🚀 Запуск тестов модуля collects.tests..."
python manage.py test collects.tests.test_signals
