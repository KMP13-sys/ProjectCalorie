
# STAGE 1: Build (Compile TypeScript)
FROM node:22-alpine AS builder

# ตั้งโฟลเดอร์ทำงานใน container
WORKDIR /app

# คัดลอกไฟล์ที่จำเป็นสำหรับการติดตั้ง dependencies
COPY package*json ./

# ติดตั้ง dependencies ทั้งหมด (รวม devDependencies)
RUN npm install

# คัดลอกซอร์สโค้ดทั้งหมดเข้าไปใน container
COPY . .

# สร้างโฟลเดอร์ uploads สำหรับเก็บไฟล์ที่อัพโหลด (ถ้ายังไม่มี)
RUN mkdir /app/src/uploads

# ติดตั้ง TypeScript และคอมไพล์จาก src -> dist
RUN npm install -g typescript
RUN npm run build

# STAGE 2: Run (Production)
FROM node:22-alpine AS runner

# ตั้งโฟลเดอร์ทำงาน
WORKDIR /app

# คัดลอกเฉพาะ dependencies ที่ใช้จริงใน production
COPY package.json package-lock.json ./
RUN npm install --omit=dev

# คัดลอกไฟล์ที่คอมไพล์แล้วจาก builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.env ./.env

# เพิ่มโฟลเดอร์ uploads
RUN mkdir -p ./src/uploads
COPY --from=builder /app/src/uploads ./src/uploads

# Add wait-for script (รอ MySQL ก่อนเริ่ม API)
RUN apk add --no-cache netcat-openbsd
RUN echo '#!/bin/sh' > /wait-for.sh && \
    echo 'set -e' >> /wait-for.sh && \
    echo 'host="$1"' >> /wait-for.sh && \
    echo 'shift' >> /wait-for.sh && \
    echo 'until nc -z "$host" 3306; do' >> /wait-for.sh && \
    echo '  echo "Waiting for MySQL at $host:3306..."' >> /wait-for.sh && \
    echo '  sleep 2' >> /wait-for.sh && \
    echo 'done' >> /wait-for.sh && \
    echo 'echo "MySQL is up - starting application"' >> /wait-for.sh && \
    echo 'exec "$@"' >> /wait-for.sh && \
    chmod +x /wait-for.sh

# Config Port & Start Command

EXPOSE 4000

# ใช้ wait-for script เพื่อรอ MySQL ก่อนรัน API
ENTRYPOINT ["/wait-for.sh", "mysql"]

# รันไฟล์หลักของแอป
CMD ["node", "dist/server.js"]
