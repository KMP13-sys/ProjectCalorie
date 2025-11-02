# Flutter development environment
FROM ubuntu:22.04

# Install essential tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter doctor && \
    flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web

WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Expose Flutter web port
EXPOSE 8080

# Start Flutter web server
CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "8080"]
