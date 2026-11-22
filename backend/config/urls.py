from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('admin/', admin.site.urls),

    path('api/auth/', include('accounts.urls')),
    path('api/', include('clients.urls')),
    path('api/', include('cases.urls')),
    path('api/', include('hearings.urls')),
    path('api/', include('tasks.urls')),
    path('api/', include('documents.urls')),
    path('api/', include('notifications.urls')),
]
