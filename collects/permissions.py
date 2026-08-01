from rest_framework import permissions


class IsAuthorOrAdmin(permissions.BasePermission):
    """
    - GET: всем (даже анонимным)
    - POST: только админам
    - PUT/PATCH/DELETE: автору или админу
    """

    def has_permission(self, request, view):
        # Разрешаем GET всем
        if request.method in permissions.SAFE_METHODS:
            return True

        # POST разрешён только админам
        if request.method == "POST":
            return request.user.is_authenticated and request.user.is_staff

        # Для PUT/PATCH/DELETE разрешаем всем авторизованным — дальше решит has_object_permission
        return request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        # Чтение — всем
        if request.method in permissions.SAFE_METHODS:
            return True

        is_author = hasattr(obj, "author") and obj.author == request.user
        is_admin = request.user.is_staff
        return is_author or is_admin
