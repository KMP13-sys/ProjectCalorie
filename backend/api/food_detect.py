from flask import Flask, request, jsonify
import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import io
import json
import mysql.connector
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv('../config/database/.env')

app = Flask(__name__)

# Configuration
MODEL_PATH = "../models/food_classification_model/food_model.pth"  # Update this path
DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME'),
    'port': int(os.getenv('DB_PORT'))
}

# Load mappings
with open('../config/food_classification_model/food_class_name.json', 'r', encoding='utf-8') as f:
    class_names = json.load(f)['class_names']

with open('../config/food_classification_model/class_mapping.json', 'r', encoding='utf-8') as f:
    class_to_idx = json.load(f)['class_to_idx']

idx_to_class = {v: k for k, v in class_to_idx.items()}

# Load model
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

from torchvision.models import efficientnet_b0
model = efficientnet_b0(pretrained=False)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(class_to_idx))

checkpoint = torch.load(MODEL_PATH, map_location=device)
# Handle backbone prefix if exists
if any(k.startswith('backbone.') for k in checkpoint.keys()):
    new_checkpoint = {}
    for k, v in checkpoint.items():
        new_key = k.replace('backbone.', '')
        new_checkpoint[new_key] = v
    checkpoint = new_checkpoint

model.load_state_dict(checkpoint, strict=False)
model.to(device)
model.eval()

# Image preprocessing
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

def get_nutrition_data(food_name):
    """Get nutrition from database"""
    try:
        print(f"Searching for food: '{food_name}'")
        
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        query = "SELECT * FROM foods WHERE food_name = %s"
        cursor.execute(query, (food_name,))
        result = cursor.fetchone()
        
        cursor.close()
        conn.close()
        return result
        
    except Exception as e:
        print(f"Database error: {e}")
        return None

@app.route('/api/predict-food', methods=['POST'])
def predict_food():
    """Predict food from image"""
    try:
        # Get image
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        file = request.files['image']
        
        # Read image bytes once
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        
        # Predict
        input_tensor = transform(image).unsqueeze(0).to(device)
        
        with torch.no_grad():
            outputs = model(input_tensor)
            predicted_idx = torch.argmax(outputs, dim=1).item()
            confidence = torch.softmax(outputs, dim=1)[0][predicted_idx].item()
        
        # Get food info
        class_folder = idx_to_class[predicted_idx]
        food_name = class_names[class_folder]
        
        # Get nutrition
        nutrition = get_nutrition_data(food_name)
        
        response = {
            'predicted_food': food_name,
            'confidence': round(confidence, 4)
        }
        
        if nutrition:
            response['nutrition'] = {
                'calories': float(nutrition['calories']),
                'protein_gram': float(nutrition['protein_gram']),
                'carbohydrate_gram': float(nutrition['carbohydrate_gram']),
                'fat_gram': float(nutrition['fat_gram'])
            }
        else:
            response['message'] = 'Nutrition data not found in database'
        
        return jsonify(response)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 4000)), debug=True)