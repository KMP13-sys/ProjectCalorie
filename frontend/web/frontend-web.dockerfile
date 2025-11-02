# =========================
#  FRONTEND WEB (Next.js)
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy and install dependencies
COPY ./frontend/web/package*.json ./
RUN npm install

# Copy all source code and build
COPY . ./
RUN npm run build --no-lint

# ===========
#  RUN STAGE
# ===========
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app ./

EXPOSE 3000
CMD ["npm", "start"]
