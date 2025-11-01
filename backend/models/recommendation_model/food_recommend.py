import mysql.connector
from mysql.connector import Error
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime
from contextlib import contextmanager
import logging
from dotenv import load_dotenv
from pathlib import Path
import os

# -----------------------------------------------------
# Load environment variables
# -----------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = BASE_DIR.parent
load_dotenv(str(PROJECT_ROOT / '.env'))

# -----------------------------------------------------
# Logging setup
# -----------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
)
logger = logging.getLogger(__name__)

# -----------------------------------------------------
# FoodRecommendationSystem
# -----------------------------------------------------
class FoodRecommendationSystem:
    def __init__(self, host=None, user=None, password=None, database=None):
        """
        ระบบแนะนำอาหารด้วย TF-IDF + Cosine Similarity
        ค่า database config จะใช้จาก parameter ก่อน ถ้าไม่มีจะ fallback ไป .env
        """
        self.db_config = {
            'host': host or os.getenv('DB_HOST', 'localhost'),
            'user': user or os.getenv('DB_USER', 'root'),
            'password': password or os.getenv('DB_PASSWORD', ''),
            'database': database or os.getenv('DB_NAME', 'calories_app')
        }
        logger.info(f"Initializing DB connection to: {self.db_config['host']}/{self.db_config['database']}")
        
        self.vectorizer = None
        self.food_vectors = None
        self.food_data = None  # Cache ข้อมูลอาหาร

    # -------------------------------------------------
    # Database Connection
    # -------------------------------------------------
    @contextmanager
    def _get_connection(self):
        """สร้าง connection กับ database แบบ context manager"""
        conn = None
        try:
            conn = mysql.connector.connect(**self.db_config)
            yield conn
        except Error as e:
            logger.error(f"Database connection failed: {e}")
            raise RuntimeError("Database connection failed. Please try again later.")
        finally:
            if conn and conn.is_connected():
                conn.close()

    # -------------------------------------------------
    # Data Retrieval
    # -------------------------------------------------
    def get_all_foods(self):
        """ดึงข้อมูลอาหารทั้งหมดจากตาราง Foods"""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute("""
                    SELECT food_id, food_name, calories
                    FROM Foods
                    ORDER BY food_name
                """)
                foods = cursor.fetchall()
                cursor.close()
                logger.info(f"Fetched {len(foods)} foods from database")
                return foods
        except Exception as e:
            logger.error(f"Error fetching foods: {e}")
            return []

    def get_user_food_history(self, user_id):
        """ดึงประวัติอาหารของผู้ใช้ (ล่าสุดก่อน)"""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute("""
                    SELECT DISTINCT f.food_name, MAX(m.date) as latest_date
                    FROM MealDetails md
                    JOIN Meals m ON md.meal_id = m.meal_id
                    JOIN Foods f ON md.food_id = f.food_id
                    WHERE m.user_id = %s
                    GROUP BY f.food_name
                    ORDER BY latest_date DESC
                """, (user_id,))
                results = cursor.fetchall()
                cursor.close()
                
                history = [row['food_name'] for row in results]
                return history
        except Exception as e:
            logger.error(f"Error fetching user history (user_id={user_id}): {e}")
            return []

    def get_remaining_calories(self, user_id, date=None):
        """ดึงแคลอรีที่เหลือของผู้ใช้ (วันปัจจุบัน)"""
        date = datetime.now().strftime('%Y-%m-%d')
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute("""
                    SELECT remaining_calories
                    FROM DailyCalories
                    WHERE user_id = %s AND date = %s
                """, (user_id, date))
                result = cursor.fetchone()
                cursor.close()
                
                if result:
                    return result['remaining_calories']
                else:
                    logger.warning(f"No DailyCalories record found for user_id={user_id}, date={date}")
                    return None
        except Exception as e:
            logger.error(f"Error fetching remaining calories for user_id={user_id}: {e}")
            return None

    # -------------------------------------------------
    # Core Recommendation Logic
    # -------------------------------------------------
    def _prepare_food_vectors(self):
        """โหลดและแปลงชื่ออาหารเป็นเวกเตอร์ TF-IDF (char-level)"""
        all_foods = self.get_all_foods()
        if not all_foods:
            raise RuntimeError("No food data found in database")

        food_names = [food['food_name'] for food in all_foods]
        self.vectorizer = TfidfVectorizer(
            analyzer='char',
            ngram_range=(1, 3),
            lowercase=True,
            strip_accents='unicode'
        )
        self.food_vectors = self.vectorizer.fit_transform(food_names)
        self.food_data = all_foods
        logger.info(f"Prepared {len(self.food_data)} food vectors")

    def recommend_foods(self, user_id, date=None, top_n=3):
        """แนะนำอาหารสำหรับผู้ใช้ตามประวัติและแคลอรีที่เหลือ"""
        try:
            user_history = self.get_user_food_history(user_id)
            if not user_history:
                return {
                    'success': False,
                    'message': 'ผู้ใช้ยังไม่มีประวัติการกิน',
                    'user_history': [],
                    'remaining_calories': 0,
                    'recommendations': []
                }

            remaining_calories = self.get_remaining_calories(user_id, date)
            if remaining_calories is None or remaining_calories <= 0:
                return {
                    'success': False,
                    'message': 'ไม่พบข้อมูลแคลอรีหรือแคลอรีเหลือไม่เพียงพอ',
                    'user_history': user_history,
                    'remaining_calories': float(remaining_calories or 0),
                    'recommendations': []
                }

            if self.food_vectors is None or self.vectorizer is None:
                self._prepare_food_vectors()

            # สร้าง user profile vector จากอาหารที่เคยทาน
            user_vec = self.vectorizer.transform(user_history)
            user_profile = np.asarray(user_vec.mean(axis=0))

            # คำนวณ cosine similarity
            similarities = cosine_similarity(user_profile, self.food_vectors).flatten()

            # เลือกอาหารแนะนำที่เหมาะสม
            recommendations = []
            for idx in np.argsort(similarities)[::-1]:
                food = self.food_data[idx]
                if food['food_name'] in user_history or food['calories'] > remaining_calories:
                    continue
                recommendations.append({
                    'food_id': food['food_id'],
                    'name': food['food_name'],
                    'calories': float(food['calories']),
                    'similarity_score': round(float(similarities[idx]), 4)
                })
                if len(recommendations) >= top_n:
                    break

            if not recommendations:
                return {
                    'success': False,
                    'message': 'ไม่พบอาหารที่เหมาะสม',
                    'user_history': user_history,
                    'remaining_calories': float(remaining_calories),
                    'recommendations': []
                }

            return {
                'success': True,
                'message': 'แนะนำอาหารสำเร็จ',
                'user_history': user_history,
                'remaining_calories': float(remaining_calories),
                'recommendations': recommendations
            }

        except Exception as e:
            logger.exception(f"Error in recommend_foods for user_id={user_id}: {e}")
            return {
                'success': False,
                'message': f'เกิดข้อผิดพลาด: {str(e)}',
                'user_history': [],
                'remaining_calories': 0,
                'recommendations': []
            }

if __name__ == "__main__":
    print("🚀 Starting Food Recommendation System...")

    system = FoodRecommendationSystem()
    # ทดสอบ connect database
    try:
        with system._get_connection() as conn:
            print("✅ Database connected successfully!")
    except Exception as e:
        print("❌ Failed to connect:", e)


