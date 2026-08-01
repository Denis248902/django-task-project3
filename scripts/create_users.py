from django.contrib.auth import get_user_model

User = get_user_model()

# Создаём админа
if not User.objects.filter(username="admin").exists():
    User.objects.create_superuser("admin", "admin@example.com", "admin123")
    print("✅ Админ (admin/admin123) создан.")
else:
    print("ℹ️ Админ уже существует.")

# Создаём test_user
if not User.objects.filter(username="test_user").exists():
    User.objects.create_user("test_user", "user@example.com", "password123")
    print("✅ test_user (test_user/password123) создан.")
else:
    print("ℹ️ test_user уже существует.")
