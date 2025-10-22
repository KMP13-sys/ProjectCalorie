import logging
import os
import sys
from pathlib import Path
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename

BASE_DIR = Path(__file__).resolve().parent      # backend/src/flask
sys.path.insert(0, str(BASE_DIR))

# Import functions จากไฟล์เดียวกัน
from food_detect import (
    predict_food_image,
    save_meal_to_db,
    require_auth
)

# ---------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------
food_detect_bp = Blueprint("food_detect", __name__)
logger = logging.getLogger(__name__)

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

# ---------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------
def verify_user_access(user_id_from_token, user_id_from_path):
    """ตรวจสอบว่า userId ใน JWT token ตรงกับ userId ใน URL path หรือไม่"""
    try:
        return int(user_id_from_token) == int(user_id_from_path)
    except (ValueError, TypeError):
        return False


def allowed_file(filename: str) -> bool:
    """ตรวจสอบว่านามสกุลไฟล์อนุญาตไหม"""
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


# ---------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------

@food_detect_bp.route("/api/predict-food/<int:userId>", methods=["POST"])
@require_auth
def predict_food(userId):
    """
    ทำนายอาหารจากรูปภาพ (ต้อง login)
    """
    try:
        # ตรวจสอบสิทธิ์การเข้าถึง
        if not verify_user_access(request.user_id, userId):
            return jsonify({
                "success": False,
                "error": "Forbidden",
                "message": "You do not have permission to access this resource"
            }), 403

        # ตรวจสอบว่ามีไฟล์ภาพไหม
        if "image" not in request.files:
            return jsonify({
                "success": False,
                "error": "MissingImage",
                "message": "No image file uploaded"
            }), 400

        file = request.files["image"]

        if file.filename == "":
            return jsonify({
                "success": False,
                "error": "EmptyFilename",
                "message": "Uploaded file has no name"
            }), 400

        if not allowed_file(file.filename):
            return jsonify({
                "success": False,
                "error": "InvalidFileType",
                "message": "Allowed types are png, jpg, jpeg"
            }), 400

        filename = secure_filename(file.filename)
        logger.info(f"🔍 Predicting food for user {userId} with file: {filename}")

        # เรียกฟังก์ชันทำนายอาหารจากโมเดล
        result = predict_food_image(file)

        # เพิ่ม userId ใน response
        result["userId"] = userId

        return jsonify({
            "success": True,
            "data": result
        }), 200

    except Exception as e:
        logger.exception(f"❌ Error in predict_food for user {userId}: {e}")
        return jsonify({
            "success": False,
            "error": "ServerError",
            "message": "An unexpected error occurred while predicting food"
        }), 500


# ---------------------------------------------------------------------

@food_detect_bp.route("/api/save-meal/<int:userId>", methods=["POST"])
@require_auth
def save_meal(userId):
    """
    บันทึกมื้ออาหาร (ต้อง login)
    """
    try:
        if not verify_user_access(request.user_id, userId):
            return jsonify({
                "success": False,
                "error": "Forbidden",
                "message": "You do not have permission to access this resource"
            }), 403

        # ตรวจสอบข้อมูล JSON ที่ส่งมา
        data = request.get_json()
        if not data:
            return jsonify({
                "success": False,
                "error": "MissingData",
                "message": "No JSON body provided"
            }), 400

        logger.info(f"💾 Saving meal for user {userId}: {data}")

        # เรียกฟังก์ชันบันทึกลงฐานข้อมูล
        result = save_meal_to_db(userId, data)

        # ถ้า function ส่ง error กลับมา
        if isinstance(result, dict) and "error" in result:
            return jsonify({
                "success": False,
                "error": result.get("error", "SaveError"),
                "message": result.get("message", "Cannot save meal")
            }), 400

        return jsonify({
            "success": True,
            "message": "บันทึกมื้ออาหารสำเร็จ",
            "data": result
        }), 201

    except Exception as e:
        logger.exception(f"❌ Error in save_meal for user {userId}: {e}")
        return jsonify({
            "success": False,
            "error": "ServerError",
            "message": "An unexpected error occurred while saving meal"
        }), 500
