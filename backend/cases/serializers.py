from rest_framework import serializers
from .models import Case


class CaseSerializer(serializers.ModelSerializer):

    class Meta:
        model = Case

        fields = [
            'id',
            'client',
            'case_number',
            'title',
            'case_type',
            'court_name',
            'status',
            'filing_date',
            'next_hearing_date',
            'created_at',
            'updated_at',
        ]

        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
        ]