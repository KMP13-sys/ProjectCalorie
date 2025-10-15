# สำหรับสร้าง Docker image ของแอปพลิเคชัน Next.js
# ---------------------------------------------------
# Stage 1: Build Next.js (Build(คอมไพล์) โค้ด Next.js)
# ---------------------------------------------------
# Base Image: alpine Linux Node.js v22 | Name: builder
FROM node:22-alpine AS builder
# /app เป็นไดเร็กทอรีทำงานหลักภายในคอนเทนเนอร์
WORKDIR /app

# คัดลอกไฟล์ package*.json และติดตั้ง Dependencies ทั้งหมด
COPY package*.json ./
RUN npm install
# คัดลอก Source Code Next.js ทั้งหมด
COPY . .
# รันคำสั่ง Build ของ Next.js(คอมไพล์โค้ดและสร้างไฟล์ที่พร้อมใช้งาน)
RUN npm run build

# ---------------------------------------------------------------------
# Stage 2: Serve with NGINX (รัน NGINX เพื่อเสิร์ฟไฟล์ Next.js ที่ถูก Build แล้ว)
# ---------------------------------------------------------------------
# ใช้ NGINX บน Alpine Linux เป็น Base Image สำหรับ Stage สุดท้าย
FROM nginx:alpine
# ตั้งค่าไดเร็กทอรีทำงานภายใน NGINX เพื่อเสิร์ฟไฟล์เว็บไซต์
WORKDIR /usr/share/nginx/html

# คัดลอกโฟลเดอร์ .next (ที่เก็บผลลัพธ์จากการ Build เช่น ไฟล์ HTML, CSS, JavaScript) จาก Stage builder มาไว้ใน Stage ปัจจุบัน
COPY --from=builder /app/.next ./.next
# คัดลอกโฟลเดอร์ public (ที่เก็บไฟล์สาธารณะ เช่น รูปภาพ, ไอคอน) จาก Stage builder มาไว้ใน Stage ปัจจุบัน
COPY --from=builder /app/public ./public
# คัดลอกไฟล์ package*.json จาก Stage builder มาไว้ใน Stage ปัจจุบัน
COPY --from=builder /app/package*.json ./

# " คัดลอกไฟล์ Configuration ของ NGINX ที่เราเตรียมไว้จากเครื่องเรา เข้าไปแทนที่ไฟล์ Config หลักของ NGINX ในคอนเทนเนอร์ "
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
# รัน NGINX ในโหมด Foreground (เพื่อให้คอนเทนเนอร์ไม่หยุดทำงาน)
CMD ["nginx", "-g", "daemon off;"]
