from django.http import JsonResponse
from django.urls import path

def health(request):
    return JsonResponse({"status": "healthy"})

def root(request):
    return JsonResponse({"service": "${{values.appName}}", "version": "0.1.0"})

urlpatterns = [path("health/", health), path("", root)]
