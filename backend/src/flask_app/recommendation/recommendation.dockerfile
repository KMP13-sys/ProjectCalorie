FROM python:3.10-slim

WORKDIR /app

COPY ../../../../requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ../../../../src/flask_app/ /app/
COPY ../../../../models/recommendation_model/recommendation_model.pkl /app/models/recommendation_model.pkl

EXPOSE 5001

CMD ["python", "-m", "flask_app.recommendation"]
