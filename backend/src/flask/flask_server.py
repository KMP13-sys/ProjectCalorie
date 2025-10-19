from flask import Flask, request, jsonify
import os
from dotenv import load_dotenv
from pathlib import Path
import sys

# หาตำแหน่ง root ของโปรเจกต์ (backend) แล้วโหลด .env จากที่นั่น
PROJECT_ROOT = Path(__file__).resolve().parents[2]  # .../ProjectCalorie/backend
load_dotenv(str(PROJECT_ROOT / '.env'))

# เพิ่มโฟลเดอร์ปัจจุบัน (ที่มีไฟล์ food_detect.py) ลงใน sys.path เพื่อให้ import ทำงานได้เมื่อรันเป็นสคริปต์
CURRENT_DIR = Path(__file__).resolve().parent
if str(CURRENT_DIR) not in sys.path:
    sys.path.insert(0, str(CURRENT_DIR))

# import โมดูลจากไฟล์ food_detect.py (ไฟล์อยู่ที่ backend/src/flask/food_detect.py)
from food_detect import predict_food_image, save_meal_to_db

app = Flask(__name__)

# ============================================
# API Routes
# ============================================

@app.route('/api/predict-food', methods=['POST'])
def predict_food():
    """ทำนายอาหารจากรูปภาพ"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        file = request.files['image']
        result = predict_food_image(file)
        return jsonify(result)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/save-meal', methods=['POST'])
def save_meal():
    """บันทึกมื้อาหาร"""
    try:
        data = request.get_json()
        result = save_meal_to_db(data)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'ok'})

# ============================================
# Run Server
# ============================================

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 4000)), debug=True)