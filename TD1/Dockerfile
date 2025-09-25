FROM python:3.11-slim
WORKDIR /app
COPY modele .
EXPOSE 8000
RUN pip install --no-cache-dir django==4.2
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]


