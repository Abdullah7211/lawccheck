from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import (
    RegisterView,
    ProfileView,
    LogoutView,
    PhoneChangeRequestView,
    PhoneChangeVerifyView,
)

from .views import (
    RegisterView,
    ProfileView,
    LogoutView,
    PhoneChangeRequestView,
    PhoneChangeVerifyView,
    PasswordChangeView,
)


urlpatterns = [

    # Registration
    path('register/', RegisterView.as_view(), name='register'),

    # Login
    path('login/', TokenObtainPairView.as_view(), name='login'),

    # Refresh access token
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # User profile
    path('profile/', ProfileView.as_view(), name='profile'),

    # Logout
    path('logout/', LogoutView.as_view(), name='logout'),

    path(
    'phone/change/request/',
    PhoneChangeRequestView.as_view(),
    name='phone_change_request'
    ),
    path(
        'phone/change/verify/',
        PhoneChangeVerifyView.as_view(),
        name='phone_change_verify'
    ),
    path(
    'password/change/',
    PasswordChangeView.as_view(),
    name='password_change'
    ),

]