# File: backend/src/flask/recommendation_routes.py
from flask import Blueprint, request, jsonify, current_app
import os
import sys
from pathlib import Path
from functools import wraps
import jwt
from jwt import ExpiredSignatureError, InvalidTokenError

# ============================================
# Path setup
# ============================================
BASE_DIR = Path(__file__).resolve().parent  # backend/src/flask
PROJECT_ROOT = BASE_DIR.parent.parent       # backend
MODELS_DIR = PROJECT_ROOT / 'models' / 'recommendation_model'
sys.path.insert(0, str(MODELS_DIR))

# ============================================
# Model imports
# ============================================
try:
    from food_recommend import FoodRecommendationSystem
    from sport_recommend import SportRecommendationSystem
except ImportError as e:
    raise ImportError(f"Cannot import recommendation models: {e}")

# ============================================
# Auth decorator
# ============================================
def require_auth(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization", None)
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"success": False, "message": "Invalid or missing token"}), 401

        token = auth_header.split(" ")[1]
        try:
            payload = jwt.decode(token, os.getenv("JWT_SECRET"), algorithms=["HS256"])
            request.user_id = payload["id"]
        except ExpiredSignatureError:
            return jsonify({"success": False, "message": "Token expired"}), 401
        except InvalidTokenError:
            return jsonify({"success": False, "message": "Invalid token"}), 401

        return f(*args, **kwargs)
    return wrapper

# ============================================
# Blueprint setup
# ============================================
recommendation_bp = Blueprint('recommendation', __name__)

# ============================================
# Model instances
# ============================================
food_recommender = FoodRecommendationSystem(
    host=os.getenv('DB_HOST', 'localhost'),
    user=os.getenv('DB_USER', 'root'),
    password=os.getenv('DB_PASSWORD', ''),
    database=os.getenv('DB_NAME', 'calories_app')
)

sport_recommender = SportRecommendationSystem(
    host=os.getenv('DB_HOST', 'localhost'),
    user=os.getenv('DB_USER', 'root'),
    password=os.getenv('DB_PASSWORD', ''),
    database=os.getenv('DB_NAME', 'calories_app')
)

# ============================================
# Helper
# ============================================
def verify_user_access(user_id_from_token, user_id_from_path):
    try:
        return int(user_id_from_token) == int(user_id_from_path)
    except (TypeError, ValueError):
        return False

# ============================================
# Routes
# ============================================
@recommendation_bp.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"success": True, "service": "recommendation", "status": "running"}), 200

# ---------- Food ----------
@recommendation_bp.route('/api/food-recommend/<int:userId>', methods=['GET'])
@require_auth
def recommend_food(userId):
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({'success': False, 'message': 'Forbidden'}), 403

        date = request.args.get('date')
        try:
            top_n = int(request.args.get('top_n', 3))
        except ValueError:
            top_n = 3

        result = food_recommender.recommend_foods(user_id=userId, date=date, top_n=top_n)
        return jsonify(result), (200 if result.get('success') else 404)

    except Exception as e:
        current_app.logger.exception(e)
        return jsonify({'success': False, 'error': str(e)}), 500

@recommendation_bp.route('/api/user/<int:userId>/food-history', methods=['GET'])
@require_auth
def get_food_history(userId):
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({'success': False, 'message': 'Forbidden'}), 403

        history = food_recommender.get_user_food_history(userId)
        return jsonify({'success': True, 'user_id': userId, 'total_foods': len(history), 'history': history}), 200

    except Exception as e:
        current_app.logger.exception(e)
        return jsonify({'success': False, 'error': str(e)}), 500

@recommendation_bp.route('/api/user/<int:userId>/remaining-calories', methods=['GET'])
@require_auth
def get_remaining_calories(userId):
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({'success': False, 'message': 'Forbidden'}), 403

        # ไม่รับ date parameter - ใช้วันปัจจุบันเสมอ
        from datetime import datetime
        today = datetime.now().strftime('%Y-%m-%d')
        
        remaining_calories = food_recommender.get_remaining_calories(userId, None)
        
        if remaining_calories is not None:
            return jsonify({
                'success': True, 
                'user_id': userId, 
                'date': today,  # ส่งวันปัจจุบันกลับไป
                'remaining_calories': float(remaining_calories)
            }), 200
            
        return jsonify({
            'success': False, 
            'message': 'No calorie data found for today',
            'user_id': userId,
            'date': today
        }), 404

    except Exception as e:
        current_app.logger.exception(e)
        return jsonify({'success': False, 'error': str(e)}), 500

# ---------- Sport ----------
@recommendation_bp.route('/api/sport-recommend/<int:userId>', methods=['GET'])
@require_auth
def recommend_sport(userId):
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({'success': False, 'message': 'Forbidden'}), 403

        try:
            top_n = int(request.args.get('top_n', 3))
            k_neighbors = int(request.args.get('k_neighbors', 5))
        except ValueError:
            top_n, k_neighbors = 3, 5

        result = sport_recommender.recommend_sports(user_id=userId, top_n=top_n, k_neighbors=k_neighbors)
        return jsonify(result), (200 if result.get('success') else 404)

    except Exception as e:
        current_app.logger.exception(e)
        return jsonify({'success': False, 'error': str(e)}), 500

@recommendation_bp.route('/api/user/<int:userId>/sport-history', methods=['GET'])
@require_auth
def get_sport_history(userId):
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({'success': False, 'message': 'Forbidden'}), 403

        sports = sport_recommender.get_user_sport_history(userId)
        return jsonify({'success': True, 'user_id': userId, 'total_sports': len(sports), 'sports': sports}), 200

    except Exception as e:
        current_app.logger.exception(e)
        return jsonify({'success': False, 'error': str(e)}), 500
