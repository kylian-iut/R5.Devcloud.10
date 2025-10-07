# Utilise une image officielle Python
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app

# Installer Django
RUN pip install "django>=4.2,<5"

# Créer le projet Django
RUN django-admin startproject api1 .

# Créer l'application
RUN python manage.py startapp bonjour

# Ajouter la vue personnalisée
RUN echo "from django.http import HttpResponse\n\
def saluer(request, nom=\"toi\"):\n\
    return HttpResponse(f'bonjour {nom}')\n" > bonjour/views.py

# Ajouter l'URL à l'application
RUN echo "from django.urls import path\n\
from .views import saluer\n\
urlpatterns = [\n\
    path('', saluer),\n\
    path('<str:nom>/', saluer),\n\
]\n" > bonjour/urls.py

# Modifier les urls du projet pour inclure l'app
RUN sed -i 's/from django.urls import path/from django.urls import path, include/' api1/urls.py && \
    sed -i "s/urlpatterns = \[/urlpatterns = [path('', include('bonjour.urls')),/" api1/urls.py

# Ajouter l'app dans INSTALLED_APPS
RUN sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles', 'bonjour',/" api1/settings.py

# Autoriser tous les hosts dans Django
RUN sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['*']/" api1/settings.py

# Appliquer les migrations
RUN python manage.py migrate

# Exposer le port
EXPOSE 8000

# Commande pour lancer le serveur
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]