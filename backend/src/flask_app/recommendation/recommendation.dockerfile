FROM python:3.10-slim

WORKDIR /app

COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src/flask_app/ /app/
COPY ./models/recommendation_model/food_recommend.py /app/models/food_recommend.py

EXPOSE 5001

CMD ["python", "-m", "flask_app.recommendation"]
