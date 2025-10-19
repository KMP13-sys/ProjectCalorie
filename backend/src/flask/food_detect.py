import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import io
import json
import mysql.connector
from dotenv import load_dotenv
import os
from datetime import datetime
from pathlib import Path

# โหลด .env จาก backend root (C:\Users\User\Documents\ProjectCalorie\backend\.env)
PROJECT_ROOT = Path(__file__).resolve().parents[2]  # .../ProjectCalorie/backend
load_dotenv(str(PROJECT_ROOT / '.env'))

# ============================================
# Database Config
# ============================================

DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME'),
    'port': int(os.getenv('DB_PORT', '3306'))
}

# ============================================
# Load Mappings
# ============================================

with open(str(PROJECT_ROOT / 'src' / 'config' / 'food_classification_model' / 'food_class_name.json'), 'r', encoding='utf-8') as f:
    class_names = json.load(f)['class_names']

with open(str(PROJECT_ROOT / 'src' / 'config' / 'food_classification_model' / 'class_mapping.json'), 'r', encoding='utf-8') as f:
    class_to_idx = json.load(f)['class_to_idx']

idx_to_class = {v: k for k, v in class_to_idx.items()}

# ============================================
# Load Model
# ============================================

MODEL_PATH = str(PROJECT_ROOT / 'models' / 'food_classification_model' / 'food_model.pth')
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

from torchvision.models import efficientnet_b0
model = efficientnet_b0(pretrained=False)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(class_to_idx))

checkpoint = torch.load(MODEL_PATH, map_location=device)

# Handle backbone prefix
if any(k.startswith('backbone.') for k in checkpoint.keys()):
    new_checkpoint = {}
    for k, v in checkpoint.items():
        new_key = k.replace('backbone.', '')
        new_checkpoint[new_key] = v
    checkpoint = new_checkpoint

model.load_state_dict(checkpoint, strict=False)
model.to(device)
model.eval()

# ============================================
# Image Preprocessing
# ============================================

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# ============================================
# Database Functions
# ============================================

def get_nutrition_data(food_name):
    """ค้นหาข้อมูลโภชนาการจากชื่ออาหาร"""
    try:
        print(f"Searching for food: '{food_name}'")
        
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        query = "SELECT * FROM Foods WHERE food_name = %s"
        cursor.execute(query, (food_name,))
        result = cursor.fetchone()
        
        cursor.close()
        conn.close()
        return result
        
    except Exception as e:
        print(f"Database error: {e}")
        return None


def save_meal_to_db(data):
    """บันทึกมื้อาหารลงฐานข้อมูล"""
    try:
        user_id = data.get('user_id')
        food_id = data.get('food_id')
        meal_datetime = data.get('meal_datetime')
        
        if not user_id or not food_id:
            return {'error': 'user_id and food_id are required'}
        
        # Default เวลาปัจจุบัน
        if not meal_datetime:
            meal_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        # แยกวันที่
        dt = datetime.strptime(meal_datetime, '%Y-%m-%d %H:%M:%S')
        meal_date = dt.strftime('%Y-%m-%d')
        
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # เริ่ม transaction
        conn.start_transaction()
        
        # Step 1: Insert or get existing Meal
        insert_meal_query = """
            INSERT INTO Meals (user_id, date) 
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE meal_id = LAST_INSERT_ID(meal_id)
        """
        cursor.execute(insert_meal_query, (user_id, meal_date))
        meal_id = cursor.lastrowid
        
        # Step 2: Insert MealDetail
        insert_detail_query = """
            INSERT INTO MealDetails (meal_id, food_id, meal_datetime)
            VALUES (%s, %s, %s)
        """
        cursor.execute(insert_detail_query, (meal_id, food_id, meal_datetime))
        meal_detail_id = cursor.lastrowid
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return {
            'success': True,
            'meal_id': meal_id,
            'meal_detail_id': meal_detail_id,
            'message': 'Meal saved successfully'
        }
        
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error: {e}")
        return {'error': str(e)}

# ============================================
# Model Prediction
# ============================================

def predict_food_image(file):
    """ทำนายอาหารจากรูปภาพ"""
    try:
        # Read image
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
            response['food_id'] = nutrition['food_id']
            response['nutrition'] = {
                'calories': float(nutrition['calories']),
                'protein_gram': float(nutrition['protein_gram']),
                'carbohydrate_gram': float(nutrition['carbohydrate_gram']),
                'fat_gram': float(nutrition['fat_gram'])
            }
        else:
            response['message'] = 'Nutrition data not found in database'
        
        return response
        
    except Exception as e:
        return {'error': str(e)}