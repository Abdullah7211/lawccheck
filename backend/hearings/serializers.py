
from rest_framework import serializers
from .models import Hearing


class HearingSerializer(serializers.ModelSerializer):

    class Meta:
        model = Hearing

        fields = [
            'id',
            'case',
            'hearing_date',
            'hearing_time',
            'court_name',
            'judge_name',
            'status',
            'outcome',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
        ]
