from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):

    password = serializers.CharField(
        write_only=True,
        required=True
    )

    password2 = serializers.CharField(
        write_only=True,
        required=True
    )

    class Meta:
        model = User
        fields = [
            'id',
            'phone_number',
            'first_name',
            'last_name',
            'email',
            'password',
            'password2',
        ]

    def validate(self, attrs):

        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({
                'password': 'Passwords do not match.'
            })

        validate_password(attrs['password'])

        return attrs

    def create(self, validated_data):

        validated_data.pop('password2')

        password = validated_data.pop('password')

        user = User.objects.create_user(
            password=password,
            **validated_data
        )

        return user
class ProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = [
            'id',
            'phone_number',
            'first_name',
            'last_name',
            'email',
        ]

        read_only_fields = ['id', 'phone_number']

class PhoneChangeRequestSerializer(serializers.Serializer):
    new_phone_number = serializers.CharField(max_length=20)


class PhoneChangeVerifySerializer(serializers.Serializer):
    new_phone_number = serializers.CharField(max_length=20)
    otp = serializers.CharField(
        min_length=6,
        max_length=6
    )

class PasswordChangeSerializer(serializers.Serializer):
    current_password = serializers.CharField(
        write_only=True,
        required=True
    )

    new_password = serializers.CharField(
        write_only=True,
        required=True
    )

    confirm_new_password = serializers.CharField(
        write_only=True,
        required=True
    )

    def validate(self, attrs):
        user = self.context['request'].user

        if not user.check_password(attrs['current_password']):
            raise serializers.ValidationError({
                'current_password': 'Current password is incorrect.'
            })

        if attrs['new_password'] != attrs['confirm_new_password']:
            raise serializers.ValidationError({
                'confirm_new_password': 'New passwords do not match.'
            })

        if attrs['current_password'] == attrs['new_password']:
            raise serializers.ValidationError({
                'new_password': 'New password must be different from the current password.'
            })

        validate_password(attrs['new_password'], user=user)

        return attrs