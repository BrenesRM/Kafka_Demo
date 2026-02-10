FROM python:3.9-slim

RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org confluent-kafka

WORKDIR /app
COPY app.py .

CMD ["python", "app.py"]
