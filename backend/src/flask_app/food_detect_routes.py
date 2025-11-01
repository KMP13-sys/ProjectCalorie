# File: backend/src/flask/food_detect_routes.py
import logging
import os
from pathlib import Path
from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
import jwt
from jwt import ExpiredSignatureError, InvalidTokenError
from functools import wraps

# -----------------------------
# Blueprint & Logger
# -----------------------------
food_detect_bp = Blueprint("food_detect", __name__)
logger = logging.getLogger(__name__)

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

# -----------------------------
# Auth decorator: ตรวจสอบ JWT และใส่ user_id ลง request
# -----------------------------
def require_auth(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
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

# -----------------------------
# Helper functions
# -----------------------------
def verify_user_access(user_id_from_token, user_id_from_path):
    """ตรวจสอบว่า user ที่ทำ request ตรงกับ userId ใน path"""
    try:
        return int(user_id_from_token) == int(user_id_from_path)
    except (ValueError, TypeError):
        return False

def allowed_file(filename: str) -> bool:
    """ตรวจสอบนามสกุลไฟล์ที่อนุญาต"""
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS

# -----------------------------
# Import model functions
# -----------------------------
try:
    from flask_app.food_detect import predict_food_image, save_meal_to_db
except ImportError as e:
    logger.error(f"Cannot import food_detect module: {e}")
    raise

# -----------------------------
# Routes
# -----------------------------
@food_detect_bp.route("/api/predict-food/<int:userId>", methods=["POST"])
@require_auth
def predict_food(userId):
    """Predict ชื่ออาหารจากรูปภาพและดึงข้อมูลโภชนาการ"""
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({"success": False, "message": "Forbidden"}), 403

        if "image" not in request.files:
            return jsonify({"success": False, "message": "No image file uploaded"}), 400

        file = request.files["image"]
        if file.filename == "":
            return jsonify({"success": False, "message": "Uploaded file has no name"}), 400
        if not allowed_file(file.filename):
            return jsonify({"success": False, "message": "Allowed types: png, jpg, jpeg"}), 400

        file.seek(0, os.SEEK_END)
        if file.tell() > MAX_FILE_SIZE:
            return jsonify({"success": False, "message": "File too large. Max 5MB"}), 400
        file.seek(0)

        filename = secure_filename(file.filename)
        logger.info(f"Predicting food for user {userId} with file: {filename}")

        result = predict_food_image(file)
        result["userId"] = userId
        return jsonify({"success": True, "data": result}), 200

    except Exception as e:
        logger.exception(f"Error in predict_food for user {userId}: {e}")
        return jsonify({"success": False, "message": "Server error"}), 500

@food_detect_bp.route("/api/save-meal/<int:userId>", methods=["POST"])
@require_auth
def save_meal(userId):
    """บันทึกมื้ออาหารของผู้ใช้ลงฐานข้อมูล"""
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({"success": False, "message": "Forbidden"}), 403

        data = request.get_json()
        if not data:
            return jsonify({"success": False, "message": "No JSON body provided"}), 400

        logger.info(f"Saving meal for user {userId}")
        result = save_meal_to_db(userId, data)

        if isinstance(result, dict) and "error" in result:
            return jsonify({"success": False, "message": result.get("message", "Cannot save meal")}), 400

        return jsonify({"success": True, "message": "Meal saved successfully", "data": result}), 201

    except Exception as e:
        logger.exception(f"Error in save_meal for user {userId}: {e}")
        return jsonify({"success": False, "message": "Server error"}), 500
