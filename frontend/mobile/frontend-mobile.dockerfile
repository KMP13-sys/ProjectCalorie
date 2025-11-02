# Build stage
FROM node:20-alpine AS builder

# Install essential build tools
RUN apk add --no-cache python3 make g++ \
    && apk add --no-cache git

WORKDIR /app

# Install dependencies
COPY ./frontend/package*.json ./
RUN npm install

# Copy source code
COPY . .

# Environment setup
ENV NEXT_DISABLE_ESLINT=true
ENV NODE_ENV=development
ENV EXPO_CLI_VERSION=7.3.0

# Install Expo CLI
RUN npm install -g expo

# Install app dependencies
RUN npm install

# Expose development port
EXPOSE 19000
EXPOSE 19001
EXPOSE 19002

# Start development server
CMD ["npm", "start"]
