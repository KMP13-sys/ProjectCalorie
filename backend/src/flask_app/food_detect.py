# File: backend/src/flask/food_detect.py
import os
import io
import json
import logging
from pathlib import Path
from datetime import datetime
from contextlib import contextmanager
from functools import wraps

import jwt
import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image, UnidentifiedImageError

import mysql.connector
from mysql.connector import Error
from flask import request, jsonify
from dotenv import load_dotenv

# ============================================
# Setup Logging
# ============================================
logger = logging.getLogger(__name__)
if not logger.handlers:
    logging.basicConfig(level=logging.INFO, format="[%(asctime)s] %(levelname)s in %(module)s: %(message)s")

# ============================================
# Load Environment
# ============================================
PROJECT_ROOT = Path(__file__).resolve().parents[2]  # backend
env_path = PROJECT_ROOT / ".env"
load_dotenv(str(env_path))

# ============================================
# Configuration
# ============================================
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'calories_app'),
    'port': int(os.getenv('DB_PORT', '3306')),
    'autocommit': False,
    'connection_timeout': 10
}

JWT_SECRET = os.getenv('JWT_SECRET')
JWT_ALGORITHM = os.getenv('JWT_ALGORITHM', 'HS256')

if not JWT_SECRET:
    logger.critical("❌ JWT_SECRET missing in environment")
    raise RuntimeError("JWT_SECRET is not set in .env")

# ============================================
# Database Connection Manager
# ============================================
@contextmanager
def get_db_connection():
    conn = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        yield conn
    except Error as e:
        logger.error("Database connection error: %s", e)
        raise
    finally:
        if conn and conn.is_connected():
            conn.close()

# ============================================
# Load Model and Classes
# ============================================
try:
    CONFIG_DIR = PROJECT_ROOT / 'src' / 'config' / 'food_classification_model'
    with open(CONFIG_DIR / 'food_class_name.json', 'r', encoding='utf-8') as f:
        class_names = json.load(f)['class_names']

    with open(CONFIG_DIR / 'class_mapping.json', 'r', encoding='utf-8') as f:
        class_to_idx = json.load(f)['class_to_idx']

    idx_to_class = {v: k for k, v in class_to_idx.items()}
    logger.info("✅ Loaded %d food classes", len(class_names))
except Exception as e:
    logger.exception("❌ Failed to load food mapping: %s", e)
    raise

# ============================================
# Load Model
# ============================================
try:
    MODEL_PATH = PROJECT_ROOT / 'models' / 'food_classification_model' / 'food_model.pth'
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model file not found: {MODEL_PATH}")

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    from torchvision.models import efficientnet_b0
    model = efficientnet_b0(pretrained=False)
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(class_to_idx))

    checkpoint_raw = torch.load(MODEL_PATH, map_location=device)
    checkpoint = checkpoint_raw.get('state_dict', checkpoint_raw)

    def strip_prefix(state_dict, prefixes=('module.', 'backbone.')):
        cleaned = {}
        for k, v in state_dict.items():
            for p in prefixes:
                if k.startswith(p):
                    k = k[len(p):]
            cleaned[k] = v
        return cleaned

    load_result = model.load_state_dict(strip_prefix(checkpoint), strict=False)
    if getattr(load_result, 'missing_keys', None):
        logger.warning("Missing keys: %s", load_result.missing_keys)
    if getattr(load_result, 'unexpected_keys', None):
        logger.warning("Unexpected keys: %s", load_result.unexpected_keys)

    model.to(device)
    model.eval()
    logger.info("✅ Model loaded successfully on %s", device)
except Exception as e:
    logger.exception("❌ Model load error: %s", e)
    raise

# ============================================
# Image Transform
# ============================================
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225])
])

# ============================================
# JWT Helpers
# ============================================
def verify_token(token: str):
    try:
        if not token:
            return None
        if token.startswith("Bearer "):
            token = token[7:].strip()
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return int(payload.get("userId") or payload.get("user_id") or payload.get("sub"))
    except jwt.ExpiredSignatureError:
        logger.warning("Token expired")
        return None
    except jwt.InvalidTokenError:
        logger.warning("Invalid token")
        return None
    except Exception as e:
        logger.error("Token verify error: %s", e)
        return None


def require_auth(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        token = request.headers.get("Authorization") or request.headers.get("authorization")
        user_id = verify_token(token)
        if not user_id:
            return jsonify({'error': 'Unauthorized', 'message': 'Invalid or missing token'}), 401
        request.user_id = user_id
        return f(*args, **kwargs)
    return wrapper

# ============================================
# DB Helper Functions
# ============================================
def validate_user_exists(user_id):
    try:
        with get_db_connection() as conn:
            cur = conn.cursor()
            cur.execute("SELECT 1 FROM users WHERE user_id = %s", (user_id,))
            exists = cur.fetchone() is not None
            cur.close()
            return exists
    except Exception as e:
        logger.error("validate_user_exists failed: %s", e)
        return False


def validate_food_exists(food_id):
    try:
        with get_db_connection() as conn:
            cur = conn.cursor()
            cur.execute("SELECT 1 FROM Foods WHERE food_id = %s", (food_id,))
            exists = cur.fetchone() is not None
            cur.close()
            return exists
    except Exception as e:
        logger.error("validate_food_exists failed: %s", e)
        return False


def get_nutrition_data(food_name):
    try:
        with get_db_connection() as conn:
            cur = conn.cursor(dictionary=True)
            cur.execute("SELECT * FROM Foods WHERE food_name = %s", (food_name,))
            result = cur.fetchone()
            cur.close()
            return result
    except Exception as e:
        logger.error("get_nutrition_data failed: %s", e)
        return None

# ============================================
# Save Meal to DB
# ============================================
def save_meal_to_db(user_id, data):
    try:
        food_id = data.get('food_id')
        if not food_id:
            return {'success': False, 'error': 'food_id is required'}

        if not validate_user_exists(user_id):
            return {'success': False, 'error': 'User not found'}
        if not validate_food_exists(food_id):
            return {'success': False, 'error': 'Food not found'}

        confidence_score = data.get('confidence_score')
        if confidence_score is not None:
            try:
                confidence_score = float(confidence_score)
                if not (0 <= confidence_score <= 1):
                    return {'success': False, 'error': 'confidence_score must be 0-1'}
            except Exception:
                return {'success': False, 'error': 'Invalid confidence_score'}

        meal_datetime = data.get('meal_datetime')
        if meal_datetime:
            try:
                dt = datetime.strptime(meal_datetime, '%Y-%m-%d %H:%M:%S')
            except ValueError:
                return {'success': False, 'error': 'Invalid meal_datetime format. Use YYYY-MM-DD HH:MM:SS'}
        else:
            dt = datetime.now()

        with get_db_connection() as conn:
            cur = conn.cursor()
            conn.start_transaction()

            # ใช้ CURDATE() ของ MySQL เพื่อให้แน่ใจว่าวันที่รีเซ็ตตอนเที่ยงคืนตาม timezone ของ database
            cur.execute("""
                INSERT INTO Meals (user_id, date)
                VALUES (%s, CURDATE())
                ON DUPLICATE KEY UPDATE meal_id = LAST_INSERT_ID(meal_id)
            """, (user_id,))
            meal_id = cur.lastrowid

            cur.execute("""
                INSERT INTO MealDetails (meal_id, food_id, meal_time)
                VALUES (%s, %s, %s)
            """, (meal_id, food_id, dt.time()))
            meal_detail_id = cur.lastrowid

            analysis_id = None
            if confidence_score is not None:
                cur.execute("""
                    INSERT INTO AIAnalysis (user_id, food_id, confidence_score)
                    VALUES (%s, %s, %s)
                """, (user_id, food_id, confidence_score))
                analysis_id = cur.lastrowid

            conn.commit()
            cur.close()

            # อัปเดตแคลอรี่รวมของวัน (ใช้วันปัจจุบันของ MySQL)
            update_consumed_calories(user_id)

            result = {
                'success': True,
                'meal_id': meal_id,
                'meal_detail_id': meal_detail_id,
                'meal_date': dt.strftime('%Y-%m-%d'),
                'meal_time': dt.strftime('%H:%M:%S'),
                'message': 'Meal saved successfully'
            }
            if analysis_id:
                result['analysis_id'] = analysis_id
            return result

    except Exception as e:
        logger.exception("save_meal_to_db error: %s", e)
        return {'success': False, 'error': 'Database error'}

# ============================================
# Update Consumed Calories
# ============================================
def update_consumed_calories(user_id):
    """อัปเดตแคลอรี่ที่กินไปในวันปัจจุบัน (ใช้ CURDATE() ของ MySQL)"""
    try:
        with get_db_connection() as conn:
            cur = conn.cursor(dictionary=True)

            # คำนวณแคลอรี่รวมจากอาหารที่กินไปในวันปัจจุบัน (ใช้ CURDATE())
            cur.execute("""
                SELECT SUM(f.calories) AS totalCalories
                FROM Meals m
                JOIN MealDetails md ON m.meal_id = md.meal_id
                JOIN Foods f ON md.food_id = f.food_id
                WHERE m.user_id = %s AND m.date = CURDATE()
            """, (user_id,))

            result = cur.fetchone()
            total_consumed = result['totalCalories'] if result and result['totalCalories'] else 0

            # อัปเดต consumed_calories ลง DailyCalories (ใช้ CURDATE())
            # (ต้องมีข้อมูล DailyCalories ของวันนี้อยู่แล้ว)
            cur.execute("""
                UPDATE DailyCalories
                SET consumed_calories = %s
                WHERE user_id = %s AND date = CURDATE()
            """, (total_consumed, user_id))

            affected_rows = cur.rowcount
            conn.commit()
            cur.close()

            if affected_rows > 0:
                logger.info(f"✅ Updated consumed_calories for user {user_id}: {total_consumed} kcal")
                return True
            else:
                logger.warning(f"⚠️ No DailyCalories record found for user {user_id} today")
                return False

    except Exception as e:
        logger.error(f"❌ update_consumed_calories failed: %s", e)
        return False

# ============================================
# Prediction
# ============================================
def predict_food_image(file):
    try:
        allowed_ext = {'.jpg', '.jpeg', '.png', '.webp'}
        filename = (file.filename or "").lower()
        ext = os.path.splitext(filename)[1]
        if ext not in allowed_ext:
            return {'success': False, 'error': f'Invalid file type: {ext}'}

        content = file.read()
        if len(content) > 10 * 1024 * 1024:
            return {'success': False, 'error': 'File too large (max 10MB)'}

        try:
            image = Image.open(io.BytesIO(content)).convert('RGB')
        except UnidentifiedImageError:
            return {'success': False, 'error': 'Invalid image file'}

        tensor = transform(image).unsqueeze(0).to(device)
        with torch.no_grad():
            outputs = model(tensor)
            probs = torch.softmax(outputs, dim=1)[0]
            idx = torch.argmax(probs).item()
            confidence = float(probs[idx])

        class_folder = idx_to_class.get(idx)
        if not class_folder:
            return {'success': False, 'error': 'Unknown class index'}

        food_name = class_names.get(class_folder, class_folder)
        nutrition = get_nutrition_data(food_name)

        response = {
            'success': True,
            'predicted_food': food_name,
            'confidence': round(confidence, 4)
        }

        if nutrition:
            response.update({
                'food_id': nutrition.get('food_id'),
                'nutrition': {
                    'calories': float(nutrition.get('calories') or 0),
                    'protein_gram': float(nutrition.get('protein_gram') or 0),
                    'carbohydrate_gram': float(nutrition.get('carbohydrate_gram') or 0),
                    'fat_gram': float(nutrition.get('fat_gram') or 0)
                }
            })
        else:
            response['warning'] = 'Nutrition data not found'
        return response

    except Exception as e:
        logger.exception("Prediction failed: %s", e)
        return {'success': False, 'error': 'Prediction failed'}
