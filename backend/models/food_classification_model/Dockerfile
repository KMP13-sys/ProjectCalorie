# Dockerfile สำหรับ Food Classification model
# - ติดตั้ง Python runtime ที่จำเป็นสำหรับรันโมเดล (ONNX runtime, และตัวเลือก PyTorch CPU wheel)
# - คัดลอกไฟล์โมเดล (.pt, .onnx, .pth) เข้า image
# - เปิดพอร์ต 8000 เป็นค่าเริ่มต้นสำหรับ inference API (ถ้าจะใช้ FastAPI/uvicorn)

FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app

# ติดตั้ง dependency ของระบบที่อาจจำเป็น (เช่น lib ที่ Pillow/torch ต้องการ)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    git \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# ติดตั้ง Python packages ที่ใช้บ่อยสำหรับ inference
# - onnxruntime: รัน ONNX models
# - fastapi, uvicorn: ถ้าต้องการสร้าง API wrapper (ไม่บังคับ)
# - torch CPU wheel: optional (บางกรณีต้องการ .pt/.pth รันโดย PyTorch)
# Note: การติดตั้ง torch CPU ใช้ wheel จาก pytorch CPU index
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir numpy pillow fastapi uvicorn onnxruntime

# Optional: install CPU-only PyTorch (ถ้าต้องการใช้ไฟล์ .pt/.pth)
# ถ้าไม่ต้องการ PyTorch ให้คอมเมนต์บรรทัดด้านล่าง หรือย้ายเป็น requirement ในขณะที่ build
RUN pip install --no-cache-dir "torch==2.2.0+cpu" --index-url https://download.pytorch.org/whl/cpu/torch_stable.html || true

# คัดลอกโมเดลและไฟล์ใด ๆ ที่อยู่ในโฟลเดอร์นี้เข้า image
COPY . /app

# แนะนำพอร์ตสำหรับ inference API
EXPOSE 8000

# Default command: เป็น placeholder ให้คุณแก้เป็นคำสั่งเริ่ม inference server ของคุณ
# ตัวอย่างการรัน FastAPI (ถ้าคุณเพิ่มไฟล์ app.py / main.py ที่กำหนด app):
#   CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
# หรือถ้าต้องการรันสคริปต์ทดสอบ: CMD ["python", "test_infer.py"]
CMD ["bash", "-c", "echo 'Build image สำเร็จ — โปรดตั้ง CMD ให้รัน inference server ของคุณ (uvicorn หรือ python script)'; sleep infinity"]
