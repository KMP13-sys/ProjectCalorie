# Use PyTorch base image with CUDA support
FROM pytorch/pytorch:latest

# Set working directory
WORKDIR /app

# Install essential packages
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    pillow \
    torchvision \
    matplotlib

# Copy model files
COPY . /app/

# Set default command
CMD ["python", "-c", "import torch; print('PyTorch version:', torch.__version__)"]
