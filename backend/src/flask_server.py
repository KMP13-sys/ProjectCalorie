# File: backend/src/flask_server.py
# Purpose: Main Flask entry point for ProjectCalorie backend

import os
import logging
import sys
from pathlib import Path
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_cors import CORS

# ==============================================
# Path setup & environment
# ==============================================
BASE_DIR = Path(__file__).resolve().parent        # backend/src
PROJECT_ROOT = BASE_DIR.parent                   # backend/
FLASK_DIR = BASE_DIR / "flask"

# เพิ่ม path เพื่อให้ import modules ได้ทุกระดับ
sys.path.insert(0, str(BASE_DIR))
sys.path.insert(0, str(FLASK_DIR))
sys.path.insert(0, str(PROJECT_ROOT / "models"))

# โหลด .env จาก project root
load_dotenv(str(PROJECT_ROOT / '.env'))

# ==============================================
# JWT & Security setup
# ==============================================
JWT_SECRET = os.getenv("JWT_SECRET")
if not JWT_SECRET:
    print("JWT_SECRET from .env =", JWT_SECRET)
    raise RuntimeError("❌ Missing JWT_SECRET in environment (.env). Application cannot start.")

# ==============================================
# Logging setup
# ==============================================
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(
    level=LOG_LEVEL,
    format="[%(asctime)s] %(levelname)s in %(module)s: %(message)s",
)
logger = logging.getLogger(__name__)
logger.info("✅ Flask Server starting...")

# ==============================================
# Flask app initialization
# ==============================================
app = Flask(__name__)

# ตั้งค่า CORS (อนุญาตทุก origin ชั่วคราว, ปรับภายหลังได้)
allowed_origins = os.getenv("CORS_ORIGINS", "*")
CORS(app, resources={r"/api/*": {"origins": allowed_origins}})

# ==============================================
# Import and register Blueprints
# ==============================================
try:
    from flask_app.food_detect_routes import food_detect_bp
    from flask_app.recommendation_routes import recommendation_bp

    app.register_blueprint(food_detect_bp)
    app.register_blueprint(recommendation_bp)
    logger.info("✅ Blueprints registered successfully")

except Exception as e:
    logger.exception("❌ Error registering blueprints: %s", e)
    raise

# ==============================================
# General routes
# ==============================================
@app.route("/api/health", methods=["GET"])
def health():
    """Health check"""
    from datetime import datetime
    return jsonify({
        "status": "ok",
        "message": "ProjectCalorie Backend Flask API is running",
        "timestamp": datetime.now().isoformat()
    }), 200

# ==============================================
# Error Handlers
# ==============================================
@app.errorhandler(400)
def bad_request(error):
    return jsonify({
        "error": "Bad Request",
        "message": "Invalid request parameters"
    }), 400

@app.errorhandler(401)
def unauthorized(error):
    return jsonify({
        "error": "Unauthorized",
        "message": "Please provide valid authentication credentials"
    }), 401

@app.errorhandler(403)
def forbidden(error):
    return jsonify({
        "error": "Forbidden",
        "message": "You do not have permission to access this resource"
    }), 403

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "error": "Not Found",
        "message": "The requested resource was not found"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    logger.exception("Internal server error: %s", error)
    return jsonify({
        "error": "Internal Server Error",
        "message": "An unexpected error occurred. Please try again later."
    }), 500

@app.errorhandler(Exception)
def handle_exception(error):
    """Catch all unhandled exceptions"""
    logger.exception("Unhandled exception: %s", error)
    return jsonify({
        "error": "Server Error",
        "message": str(error)
    }), 500

# ==============================================
#  Run Server
# ==============================================
if __name__ == "__main__":
    port = int(os.getenv("PORT", 4000))
    debug_mode = os.getenv("FLASK_DEBUG", "false").lower() == "true"

    logger.info(f" Running Flask on port {port} (debug={debug_mode})")

    app.run(host="0.0.0.0", port=port, debug=debug_mode)
