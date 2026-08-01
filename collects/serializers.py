from rest_framework import serializers
from .models import Collect


class CollectSerializer(serializers.ModelSerializer):
    author = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Collect
        fields = [
            "id",
            "title",
            "reason",
            "description",
            "target_amount",
            "collected_amount",
            "cover_image",
            "end_date",
            "created_at",
            "author",
        ]

    def create(self, validated_data):
        validated_data["author"] = self.context["request"].user
        return super().create(validated_data)
