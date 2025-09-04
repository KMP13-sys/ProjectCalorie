# download_model.py
import os
import urllib.request

def download_model():
    model_url = "https://github.com/username/repo/releases/download/v1.0.0/food_classifier.pt" #ไว้เปลี่ยนลิงก์
    model_path = "backend/models/food_classifier.pt", "backend/models/food_classifier.onnx"
    
    if not os.path.exists(model_path):
        print("Downloading pre-trained model...")
        urllib.request.urlretrieve(model_url, model_path)
        print("Model downloaded successfully!")
    else:
        print("Model already exists.")

if __name__ == "__main__":
    download_model()