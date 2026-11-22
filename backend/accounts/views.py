from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.exceptions import ValidationError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from .serializers import RegisterSerializer, ProfileSerializer

from .serializers import RegisterSerializer
import secrets

from datetime import timedelta
from django.conf import settings
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone

from .models import PhoneChangeOTP
from .serializers import (
    PhoneChangeRequestSerializer,
    PhoneChangeVerifySerializer,
)

from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
from .serializers import PasswordChangeSerializer

User = get_user_model()


class RegisterView(generics.CreateAPIView):

    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class LogoutView(APIView):

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):

        refresh_token = request.data.get('refresh')

        if not refresh_token:
            return Response(
                {'error': 'Refresh token is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()

            return Response(
                {'message': 'Successfully logged out.'},
                status=status.HTTP_200_OK
            )

        except TokenError:
            raise ValidationError({
                'error': 'Invalid or expired refresh token.'
            })

class PhoneChangeRequestView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PhoneChangeRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_phone = serializer.validated_data['new_phone_number']

        user = request.user

        if new_phone == user.phone_number:
            return Response(
                {'error': 'This is already your current phone number.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(phone_number=new_phone).exists():
            return Response(
                {'error': 'This phone number is already registered.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Remove previous OTP requests for this user.
        PhoneChangeOTP.objects.filter(user=user).delete()

        # Generate a six-digit OTP.
        otp = str(secrets.randbelow(900000) + 100000)

        PhoneChangeOTP.objects.create(
            user=user,
            new_phone_number=new_phone,
            otp_hash=make_password(otp),
            expires_at=timezone.now() + timedelta(minutes=5)
        )

        response_data = {
            'message': 'OTP generated successfully. It expires in 5 minutes.'
        }

        # Development only: expose OTP for local testing.
        if settings.DEBUG:
            response_data['development_otp'] = otp

        return Response(response_data, status=status.HTTP_200_OK)

class PhoneChangeVerifyView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PhoneChangeVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_phone = serializer.validated_data['new_phone_number']
        otp = serializer.validated_data['otp']

        user = request.user

        try:
            otp_record = PhoneChangeOTP.objects.get(
                user=user,
                new_phone_number=new_phone
            )
        except PhoneChangeOTP.DoesNotExist:
            return Response(
                {'error': 'No OTP request found. Request a new OTP.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if otp_record.is_expired():
            otp_record.delete()
            return Response(
                {'error': 'OTP has expired. Request a new OTP.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if otp_record.attempts >= 5:
            otp_record.delete()
            return Response(
                {'error': 'Too many incorrect attempts. Request a new OTP.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not check_password(otp, otp_record.otp_hash):
            otp_record.attempts += 1
            otp_record.save(update_fields=['attempts'])

            return Response(
                {'error': 'Invalid OTP.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(phone_number=new_phone).exclude(pk=user.pk).exists():
            otp_record.delete()
            return Response(
                {'error': 'This phone number is already registered.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user.phone_number = new_phone
        user.save(update_fields=['phone_number'])

        PhoneChangeOTP.objects.filter(user=user).delete()

        return Response(
            {
                'message': 'Phone number updated successfully.',
                'phone_number': user.phone_number
            },
            status=status.HTTP_200_OK
        )

class PasswordChangeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PasswordChangeSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)

        user = request.user
        new_password = serializer.validated_data['new_password']

        user.set_password(new_password)
        user.save(update_fields=['password'])

        # Blacklist all outstanding refresh tokens for this user.
        for token in OutstandingToken.objects.filter(user=user):
            try:
                BlacklistedToken.objects.get_or_create(token=token)
            except Exception:
                pass

        return Response(
            {'message': 'Password changed successfully. Please log in again.'},
            status=status.HTTP_200_OK
        )