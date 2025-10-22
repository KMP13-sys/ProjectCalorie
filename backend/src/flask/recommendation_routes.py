from flask import Blueprint, request, jsonify
import os
import sys
from pathlib import Path

# Path: C:\Users\User\Documents\ProjectCalorie\backend\src\flask\recommendation_routes.py
BASE_DIR = Path(__file__).resolve().parent  # backend/src/flask
PROJECT_ROOT = BASE_DIR.parent.parent        # backend
MODELS_DIR = PROJECT_ROOT / 'models' / 'recommendation_model'

# เพิ่ม path ของโมเดล
sys.path.insert(0, str(MODELS_DIR))

# Import model จาก backend/models/recommendation_model/food_recommend.py
try:
    from food_recommend import FoodRecommendationSystem
except ImportError as e:
    print(f"Error importing FoodRecommendationSystem: {e}")
    print(f"MODELS_DIR: {MODELS_DIR}")
    print(f"sys.path: {sys.path}")
    raise

# Import require_auth จาก food_detect.py (อยู่ใน folder เดียวกัน)
try:
    from food_detect import require_auth
except ImportError:
    # ถ้า import ไม่ได้ ให้สร้าง dummy decorator
    def require_auth(f):
        def wrapper(*args, **kwargs):
            request.user_id = kwargs.get('userId', None)
            return f(*args, **kwargs)
        wrapper.__name__ = f.__name__
        return wrapper

# สร้าง Blueprint
recommendation_bp = Blueprint('recommendation', __name__)

# สร้าง instance ของโมเดล
recommender = FoodRecommendationSystem(
    host=os.getenv('DB_HOST', 'localhost'),
    user=os.getenv('DB_USER', 'root'),
    password=os.getenv('DB_PASSWORD', ''),
    database=os.getenv('DB_NAME', 'calories_app')  # อัปเดตชื่อ database
)

# ============================================
# Helper Functions
# ============================================

def verify_user_access(user_id_from_token, user_id_from_path):
    """ตรวจสอบสิทธิ์การเข้าถึง"""
    if user_id_from_token is None:
        return True  # ถ้าไม่มี auth ให้ผ่านไปก่อน (สำหรับ development)
    return int(user_id_from_token) == int(user_id_from_path)

# ============================================
# Routes
# ============================================

@recommendation_bp.route('/api/recommend/<int:userId>', methods=['GET'])
@require_auth
def recommend_food(userId):
    """
    แนะนำอาหารสำหรับผู้ใช้
    
    Query Parameters:
    - date: วันที่ต้องการแนะนำ (optional, default = วันนี้)
    - top_n: จำนวนอาหารที่แนะนำ (optional, default = 3)
    
    Response:
    {
        "success": true,
        "message": "แนะนำอาหารสำเร็จ",
        "user_id": 1,
        "date": "2025-09-26",
        "user_history": [...],
        "remaining_calories": 400.0,
        "recommendations": [...]
    }
    """
    try:
        # ตรวจสอบสิทธิ์การเข้าถึง
        if not verify_user_access(getattr(request, 'user_id', None), userId):
            return jsonify({
                'error': 'Forbidden',
                'message': 'You do not have permission to access this resource'
            }), 403
        
        # รับ query parameters
        date = request.args.get('date', None)
        top_n = int(request.args.get('top_n', 3))
        
        # เรียกใช้โมเดล
        result = recommender.recommend_foods(
            user_id=userId,
            date=date,
            top_n=top_n
        )
        
        # เพิ่มข้อมูล
        result['user_id'] = userId
        if date:
            result['date'] = date
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 404
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@recommendation_bp.route('/api/user/<int:userId>/food-history', methods=['GET'])
@require_auth
def get_food_history(userId):
    """
    ดึงประวัติอาหารของผู้ใช้
    
    Response:
    {
        "success": true,
        "user_id": 1,
        "total_foods": 10,
        "history": ["ข้าวผัด", "ปลาทอด", ...]
    }
    """
    try:
        # ตรวจสอบสิทธิ์การเข้าถึง
        if not verify_user_access(getattr(request, 'user_id', None), userId):
            return jsonify({
                'error': 'Forbidden',
                'message': 'You do not have permission to access this resource'
            }), 403
        
        history = recommender.get_user_food_history(userId)
        
        return jsonify({
            'success': True,
            'user_id': userId,
            'total_foods': len(history),
            'history': history
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@recommendation_bp.route('/api/user/<int:userId>/remaining-calories', methods=['GET'])
@require_auth
def get_remaining_calories(userId):
    """
    ดึงแคลอรีที่เหลือของผู้ใช้
    
    Query Parameters:
    - date: วันที่ต้องการตรวจสอบ (optional, default = วันนี้)
    
    Response:
    {
        "success": true,
        "user_id": 1,
        "date": "2025-09-26",
        "remaining_calories": 400.0
    }
    """
    try:
        # ตรวจสอบสิทธิ์การเข้าถึง
        if not verify_user_access(getattr(request, 'user_id', None), userId):
            return jsonify({
                'error': 'Forbidden',
                'message': 'You do not have permission to access this resource'
            }), 403
        
        date = request.args.get('date', None)
        
        remaining_calories = recommender.get_remaining_calories(userId, date)
        
        if remaining_calories is not None:
            response = {
                'success': True,
                'user_id': userId,
                'remaining_calories': float(remaining_calories)
            }
            if date:
                response['date'] = date
                
            return jsonify(response), 200
        else:
            return jsonify({
                'success': False,
                'message': 'ไม่พบข้อมูลแคลอรีสำหรับวันที่กำหนด'
            }), 404
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500