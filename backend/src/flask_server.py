# =====================================================
# File: backend/src/flask/flask_server.py
# Purpose: Main Flask entry point for ProjectCalorie backend
# =====================================================

import os
import logging
import sys
from pathlib import Path
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_cors import CORS

# -----------------------------------------------------
# Path setup & environment
# -----------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent        # backend/src
PROJECT_ROOT = BASE_DIR.parent                   # backend/
sys.path.append(os.path.dirname(__file__))
sys.path.append(os.path.join(os.path.dirname(__file__), "flask"))
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "models"))

# โหลด .env จาก project root
load_dotenv(str(PROJECT_ROOT / '.env'))

# -----------------------------------------------------
# JWT & Security setup
# -----------------------------------------------------
JWT_SECRET = os.getenv("JWT_SECRET")
if not JWT_SECRET:
    print("🔍 JWT_SECRET from .env =", JWT_SECRET)
    raise RuntimeError("❌ Missing JWT_SECRET in environment (.env). Application cannot start.")

# -----------------------------------------------------
# Logging setup
# -----------------------------------------------------
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(
    level=LOG_LEVEL,
    format="[%(asctime)s] %(levelname)s in %(module)s: %(message)s",
)
logger = logging.getLogger(__name__)
logger.info("✅ Flask Server starting...")

# -----------------------------------------------------
# Flask app initialization
# -----------------------------------------------------
app = Flask(__name__)

# ตั้งค่า CORS (อนุญาตทุก origin ชั่วคราว, ปรับเป็นเฉพาะโดเมนภายหลัง)
allowed_origins = os.getenv("CORS_ORIGINS", "*")
CORS(app, resources={r"/api/*": {"origins": allowed_origins}})

# -----------------------------------------------------
# Import and register Blueprints
# -----------------------------------------------------
try:
    from food_detect_routes import food_detect_bp
    from recommendation_routes import recommendation_bp

    app.register_blueprint(food_detect_bp)
    app.register_blueprint(recommendation_bp)
    logger.info("✅ Blueprints registered successfully")
except Exception as e:
    logger.exception("❌ Error registering blueprints: %s", e)
    raise

# -----------------------------------------------------
# General routes
# -----------------------------------------------------
@app.route("/")
def home():
    """Root endpoint for quick API overview"""
    return jsonify({
        "message": "Flask ML API",
        "version": "1.0",
        "endpoints": {
            "health": "/api/health",
            "food_detection": {
                "predict": "/api/predict-food/<userId>",
                "save_meal": "/api/save-meal/<userId>"
            },
            "food_recommendation": {
                "recommend": "/api/recommend/<userId>",
                "history": "/api/user/<userId>/food-history",
                "calories": "/api/user/<userId>/remaining-calories"
            }
        }
    })

@app.route("/api/health", methods=["GET"])
def health():
    """Health check"""
    return jsonify({"status": "ok", "message": "Flask ML API is running"})

# -----------------------------------------------------
# Error Handlers
# -----------------------------------------------------
@app.errorhandler(401)
def unauthorized(error):
    return jsonify({"error": "Unauthorized", "message": "Please login"}), 401

@app.errorhandler(403)
def forbidden(error):
    return jsonify({"error": "Forbidden", "message": "Access denied"}), 403

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not Found", "message": "Resource not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.exception("Internal server error: %s", error)
    return jsonify({"error": "Internal Server Error", "message": "Unexpected error"}), 500

@app.errorhandler(Exception)
def handle_exception(error):
    """Catch all unhandled exceptions"""
    logger.exception("Unhandled exception: %s", error)
    return jsonify({"error": "Server Error", "message": str(error)}), 500

# -----------------------------------------------------
# Run Server
# -----------------------------------------------------
if __name__ == "__main__":
    port = int(os.getenv("PORT", 4000))
    debug_mode = os.getenv("FLASK_DEBUG", "false").lower() == "true"

    logger.info(f"🚀 Running Flask on port {port} (debug={debug_mode})")
    app.run(host="0.0.0.0", port=port, debug=debug_mode)
