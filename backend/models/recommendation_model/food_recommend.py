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
import os  # ← เพิ่ม

BASE_DIR = Path(__file__).resolve().parent.parent        # backend/models/recommendation_model
PROJECT_ROOT = BASE_DIR.parent                           # backend/
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
# FoodRecommendationSystem Class
# -----------------------------------------------------
class FoodRecommendationSystem:
    def __init__(self, host=None, user=None, password=None, database=None):
        """
        ระบบแนะนำอาหารด้วย TF-IDF + Cosine Similarity
        """
        # ใช้ค่าจาก parameter ก่อน ถ้าไม่มีค่อยใช้จาก .env
        self.db_config = {
            'host': host or os.getenv('DB_HOST', 'localhost'),
            'user': user or os.getenv('DB_USER', 'root'),
            'password': password or os.getenv('DB_PASSWORD', ''),
            'database': database or os.getenv('DB_NAME', 'calories_app')
        }
        
        # Log config (ไม่แสดง password)
        logger.info(f"Initializing DB connection to: {self.db_config['host']}/{self.db_config['database']}")
        
        self.vectorizer = None
        self.food_vectors = None
        self.food_data = None  # cache (id, name, cal)

    # -------------------------------------------------
    # Database Connection
    # -------------------------------------------------
    @contextmanager
    def _get_connection(self):
        """สร้าง connection กับ database แบบ context manager"""
        conn = None
        try:
            logger.info(f"Connecting to database: {self.db_config['host']}/{self.db_config['database']}")
            conn = mysql.connector.connect(**self.db_config)
            logger.info("✅ Database connected successfully")
            yield conn
        except Error as e:
            logger.error(f"❌ Database connection error:")
            logger.error(f"   Host: {self.db_config['host']}")
            logger.error(f"   User: {self.db_config['user']}")
            logger.error(f"   Database: {self.db_config['database']}")
            logger.error(f"   Error: {e}")
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
                logger.info(f"✅ Fetched {len(foods)} foods from database")
                return foods
        except Exception as e:
            logger.error(f"Error fetching foods: {e}")
            return []

    def get_user_food_history(self, user_id):
        """ดึงประวัติอาหารของผู้ใช้"""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                
                # 🔍 Debug: แสดง user_id
                logger.info(f"Fetching food history for user_id: {user_id}")
                
                # แก้ไข: เพิ่ม m.date ใน SELECT เพื่อให้ ORDER BY ทำงานได้
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
                
                # 🔍 Debug: แสดงผลลัพธ์
                logger.info(f"Query returned {len(results)} rows")
                if results:
                    logger.info(f"Sample results: {results[:3]}")  # แสดงแค่ 3 แรก
                
                history = [row['food_name'] for row in results]
                cursor.close()
                
                # 🔍 Debug: แสดงประวัติที่ได้
                logger.info(f"✅ Final history list ({len(history)} items): {history[:5]}...")
                
                return history
        except Exception as e:
            logger.error(f"Error fetching user history (user_id={user_id}): {e}")
            return []

    def get_remaining_calories(self, user_id, date=None):
        """ดึงแคลอรีที่เหลือของผู้ใช้ในวันนั้น"""
        if not date:
            date = datetime.now().strftime('%Y-%m-%d')

        try:
            with self._get_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                logger.info(f"Fetching remaining calories for user_id={user_id}, date={date}")
                
                cursor.execute("""
                    SELECT remaining_calories
                    FROM DailyCalories
                    WHERE user_id = %s AND date = %s
                """, (user_id, date))
                result = cursor.fetchone()
                cursor.close()
                
                if result:
                    logger.info(f"✅ Remaining calories: {result['remaining_calories']}")
                else:
                    logger.warning(f"⚠️ No DailyCalories record found for user_id={user_id}, date={date}")
                
                return result['remaining_calories'] if result else None
        except Exception as e:
            logger.error(f"Error fetching remaining calories for user_id={user_id}: {e}")
            return None

    # -------------------------------------------------
    # Core Recommendation Logic
    # -------------------------------------------------
    def _prepare_food_vectors(self):
        """โหลดและแปลงข้อมูลอาหารเป็นเวกเตอร์ TF-IDF"""
        all_foods = self.get_all_foods()
        if not all_foods:
            raise RuntimeError("ไม่พบข้อมูลอาหารในฐานข้อมูล")

        food_names = [food['food_name'] for food in all_foods]
        self.vectorizer = TfidfVectorizer(
            analyzer='char',
            ngram_range=(1, 3),
            lowercase=True,
            strip_accents='unicode'
        )
        self.food_vectors = self.vectorizer.fit_transform(food_names)
        self.food_data = all_foods
        
        logger.info(f"✅ Prepared {len(self.food_data)} food vectors")

    def recommend_foods(self, user_id, date=None, top_n=3):
        """แนะนำอาหารสำหรับผู้ใช้"""
        try:
            logger.info(f"Starting recommendation for user_id={user_id}, top_n={top_n}")
            
            # 1️⃣ ดึงประวัติอาหาร
            user_history = self.get_user_food_history(user_id)
            if not user_history:
                return {
                    'success': False,
                    'message': 'ผู้ใช้ยังไม่มีประวัติการกิน',
                    'user_history': [],
                    'remaining_calories': 0,
                    'recommendations': []
                }

            # 2️⃣ ดึงแคลอรีที่เหลือ
            remaining_calories = self.get_remaining_calories(user_id, date)
            if remaining_calories is None:
                return {
                    'success': False,
                    'message': 'ไม่พบข้อมูล DailyCalories สำหรับวันนี้',
                    'user_history': user_history,
                    'remaining_calories': 0,
                    'recommendations': []
                }

            if remaining_calories <= 0:
                return {
                    'success': False,
                    'message': 'แคลอรีเหลือ 0 หรือติดลบ ไม่สามารถแนะนำได้',
                    'user_history': user_history,
                    'remaining_calories': float(remaining_calories),
                    'recommendations': []
                }

            # 3️⃣ เตรียมเวกเตอร์ TF-IDF ถ้ายังไม่มี
            if self.food_vectors is None or self.vectorizer is None:
                logger.info("Preparing food vectors...")
                self._prepare_food_vectors()

            # 4️⃣ สร้าง user profile vector
            user_vec = self.vectorizer.transform(user_history)
            user_profile = user_vec.mean(axis=0)
            
            # แปลง matrix เป็น array (แก้ไข numpy compatibility)
            user_profile = np.asarray(user_profile)

            # 5️⃣ คำนวณ cosine similarity
            similarities = cosine_similarity(user_profile, self.food_vectors).flatten()

            # 6️⃣ จัดอันดับอาหาร
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
                    'message': 'ไม่พบอาหารที่เหมาะสม (อาจเคยทานหมดแล้ว หรือแคลอรีไม่พอ)',
                    'user_history': user_history,
                    'remaining_calories': float(remaining_calories),
                    'recommendations': []
                }

            logger.info(f"✅ Generated {len(recommendations)} recommendations")
            
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