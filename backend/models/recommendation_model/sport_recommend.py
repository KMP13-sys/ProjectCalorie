# File: backend/models/recommendation_model/sport_recommend.py
# Purpose: Sport Recommendation System using KNN + Cosine Similarity
# แนะนำกีฬาตามประวัติการออกกำลังกายของผู้ใช้ (รองรับภาษาไทย)

import os
import mysql.connector
from datetime import datetime
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import logging

logger = logging.getLogger(__name__)


class SportRecommendationSystem:
    """
    ระบบแนะนำกีฬา โดยใช้:
    - ประวัติการออกกำลังกายของผู้ใช้ (sport history)
    - KNN + Cosine Similarity
    """

    def __init__(self, host='localhost', user='root', password='', database='calories_app'):
        """Initialize database connection"""
        self.host = host
        self.user = user
        self.password = password
        self.database = database

        # ✅ ใช้ analyzer='char_wb' ช่วยให้ภาษาไทยแยกได้ดีขึ้น
        self.vectorizer = TfidfVectorizer(
            analyzer='char_wb',   # เหมาะกับภาษาไทยที่ไม่มีช่องว่าง
            ngram_range=(2, 4)    # ใช้ช่วง 2-4 ตัวอักษรเพื่อจับคำไทยยาวๆ
        )

    def _get_connection(self):
        """Get database connection"""
        try:
            conn = mysql.connector.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                database=self.database,
                charset='utf8mb4',   # ✅ รองรับภาษาไทย
                collation='utf8mb4_general_ci'
            )
            return conn
        except mysql.connector.Error as e:
            logger.error(f"Database connection error: {e}")
            raise

    # ================================
    # Data Retrieval
    # ================================

    def get_user_sport_history(self, user_id):
        """ดึงรายชื่อกีฬาที่ผู้ใช้เคยทำ"""
        try:
            conn = self._get_connection()
            cursor = conn.cursor(dictionary=True)

            query = """
            SELECT DISTINCT s.sport_id, s.sport_name, COUNT(*) as frequency
            FROM Activity a
            JOIN ActivityDetail ad ON a.activity_id = ad.activity_id
            JOIN Sports s ON ad.sport_id = s.sport_id
            WHERE a.user_id = %s
            GROUP BY s.sport_id, s.sport_name
            ORDER BY frequency DESC
            """

            cursor.execute(query, (user_id,))
            results = cursor.fetchall()
            cursor.close()
            conn.close()

            return [sport['sport_name'] for sport in results]

        except Exception as e:
            logger.error(f"Error getting sport history: {e}")
            return []

    def get_user_profiles(self):
        """ดึง user profile ของทุกคน"""
        try:
            conn = self._get_connection()
            cursor = conn.cursor(dictionary=True)

            query = """
            SELECT DISTINCT a.user_id, s.sport_name
            FROM Activity a
            JOIN ActivityDetail ad ON a.activity_id = ad.activity_id
            JOIN Sports s ON ad.sport_id = s.sport_id
            ORDER BY a.user_id, s.sport_name
            """

            cursor.execute(query)
            results = cursor.fetchall()
            cursor.close()
            conn.close()

            user_profiles = {}
            for row in results:
                uid = row['user_id']
                sport = row['sport_name']
                user_profiles.setdefault(uid, []).append(sport)
            return user_profiles

        except Exception as e:
            logger.error(f"Error getting user profiles: {e}")
            return {}

    # ================================
    # Recommendation Logic
    # ================================

    def recommend_sports(self, user_id, top_n=3, k_neighbors=5):
        """แนะนำชื่อกีฬา (ภาษาไทย)"""
        try:
            user_history = self.get_user_sport_history(user_id)
            if not user_history:
                return {
                    'success': False,
                    'message': 'ไม่พบประวัติการออกกำลังกายของผู้ใช้นี้'
                }

            user_profiles = self.get_user_profiles()
            if not user_profiles or user_id not in user_profiles:
                return {
                    'success': False,
                    'message': 'ไม่สามารถดึงข้อมูลผู้ใช้สำหรับการแนะนำ'
                }

            user_ids = list(user_profiles.keys())
            texts = [' '.join(user_profiles[uid]) for uid in user_ids]

            tfidf_matrix = self.vectorizer.fit_transform(texts)

            if user_id not in user_ids:
                return {'success': False, 'message': 'ไม่พบผู้ใช้เป้าหมาย'}

            target_idx = user_ids.index(user_id)
            similarities = cosine_similarity(
                tfidf_matrix[target_idx], tfidf_matrix
            ).flatten()

            k_neighbors = min(k_neighbors, len(user_ids) - 1)
            similar_indices = np.argsort(-similarities)[1:k_neighbors + 1]

            similar_sports = {}
            for idx in similar_indices:
                uid = user_ids[idx]
                for sport in user_profiles[uid]:
                    if sport not in user_history:
                        similar_sports[sport] = similar_sports.get(sport, 0) + 1

            if not similar_sports:
                return {'success': False, 'message': 'ไม่มีกีฬาใหม่ที่แนะนำได้'}

            recommendations = sorted(
                similar_sports.items(),
                key=lambda x: x[1],
                reverse=True
            )[:top_n]

            return {
                'success': True,
                'user_id': user_id,
                'recommendations': [name for name, _ in recommendations],
                'timestamp': datetime.now().isoformat()
            }

        except Exception as e:
            logger.error(f"Error in recommend_sports: {e}")
            return {'success': False, 'error': str(e)}
