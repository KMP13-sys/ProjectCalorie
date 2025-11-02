# -----------------------------------------------------
# Dockerfile สำหรับระบบ food_detect (Flask + PyTorch)
# -----------------------------------------------------
FROM python:3.10-slim

# ตั้ง working directory ภายใน container
WORKDIR /app

# ติดตั้ง library ระบบที่จำเป็นสำหรับ OpenCV / Torch / Pillow
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ติดตั้ง Python dependencies ที่จำเป็นโดยตรง
RUN pip install --no-cache-dir \
    flask \
    torch \
    torchvision \
    pillow \
    python-dotenv \
    mysql-connector-python \
    pyjwt

# คัดลอก source code และโมเดลเข้ามาใน container
COPY src ./src
COPY models ./models
COPY .env .

# เปิดพอร์ต Flask
EXPOSE 5000

# ตั้งค่า Environment Variable ให้ Flask ทำงานได้
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=src.flask.food_detect
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000

# สั่งรัน Flask app
CMD ["flask", "run"]
