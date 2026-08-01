from django.contrib import admin
from .models import Collect


@admin.register(Collect)
class CollectAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "target_amount", "collected_amount", "end_date")
    list_filter = ("reason",)
    search_fields = ("title", "description")
