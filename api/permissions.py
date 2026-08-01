from rest_framework import permissions
from django.contrib.auth.models import Group

class IsAdminOrEditorOrReadOnly(permissions.BasePermission):
    """
    Разрешает:
      - GET/HEAD/OPTIONS — всем
      - POST/PUT/PATCH/DELETE — пользователям из групп 'admin' или 'editor'
    """

    def has_permission(self, request, view):
        # Чтение разрешено всем
        if request.method in permissions.SAFE_METHODS:
            return True

        user = request.user
        if not user or not user.is_authenticated:
            return False

        # Для изменяющих действий проверяем группы
        allowed_group_names = {'admin', 'editor'}
        return user.groups.filter(name__in=allowed_group_names).exists()