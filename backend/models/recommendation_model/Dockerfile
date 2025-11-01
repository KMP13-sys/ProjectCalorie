# -----------------------------------------------------
# Dockerfile สำหรับระบบแนะนำอาหาร (FoodRecommendationSystem)
# -----------------------------------------------------
FROM python:3.10-slim

# ปิด buffer log ของ Python เพื่อให้ log แสดงทันที
ENV PYTHONUNBUFFERED=1

# ตั้ง working directory
WORKDIR /app

# ติดตั้ง dependency ของระบบ (จำเป็นสำหรับบางไลบรารี เช่น scikit-learn)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# อัปเดต pip และติดตั้งไลบรารีทั้งหมดที่สคริปต์ใช้
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        mysql-connector-python \
        numpy \
        pandas \
        scikit-learn \
        python-dotenv

# คัดลอกทุกไฟล์ในโปรเจกต์เข้า container
COPY . /app

# คำสั่งเริ่มต้น: รันสคริปต์หลัก
CMD ["python", "food_recommend.py"]
