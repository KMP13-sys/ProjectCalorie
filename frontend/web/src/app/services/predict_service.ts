// File: frontend/web/src/app/services/predict_service.ts
// Purpose: Service to interact with the Flask API for food prediction and meal saving

// ============================================
// Types & Interfaces
// ============================================

export interface NutritionData {
  calories: number;
  protein_gram: number;
  carbohydrate_gram: number;
  fat_gram: number;
}

export interface PredictFoodResponse {
  success: boolean;
  data?: {
    userId: number;
    success: boolean;
    predicted_food: string;
    confidence: number;
    food_id?: number;
    nutrition?: NutritionData;
    warning?: string;
  };
  message?: string;
}

export interface SaveMealRequest {
  food_id: number;
  confidence_score?: number;
  meal_datetime?: string; // Format: 'YYYY-MM-DD HH:MM:SS'
}

export interface SaveMealResponse {
  success: boolean;
  message?: string;
  data?: {
    success: boolean;
    meal_id: number;
    meal_detail_id: number;
    meal_date: string;
    meal_time: string;
    analysis_id?: number;
    message: string;
    error?: string;
  };
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  error?: string;
}

// ============================================
// Configuration
// ============================================

const FLASK_API_BASE_URL = process.env.NEXT_PUBLIC_FLASK_API_URL || 'http://127.0.0.1:5000';

// ============================================
// Helper Functions
// ============================================

function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null;
  // Check for accessToken (used by auth_service.ts)
  return localStorage.getItem('accessToken') || localStorage.getItem('token') || localStorage.getItem('authToken');
}

function getAuthHeaders(): HeadersInit {
  const token = getAuthToken();
  if (!token) {
    throw new Error('Authentication token not found. Please login first.');
  }
  return {
    'Authorization': `Bearer ${token}`,
  };
}

function handleApiError(error: any): never {
  if (error.response) {

    const message = error.response.data?.message || error.response.data?.error || 'Server error occurred';
    throw new Error(message);
  } else if (error.request) {
    throw new Error('No response from server. Please check your connection.');
  } else {
    throw new Error(error.message || 'An unexpected error occurred');
  }
}

// ============================================
// API Service Functions
// ============================================

export async function predictFood(
  userId: number,
  imageFile: File
): Promise<PredictFoodResponse> {
  try {
    // Validate file type
    const allowedTypes = ['image/png', 'image/jpg', 'image/jpeg'];
    if (!allowedTypes.includes(imageFile.type)) {
      throw new Error('Invalid file type. Only PNG, JPG, and JPEG are allowed.');
    }

    // Validate file size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (imageFile.size > maxSize) {
      throw new Error('File size too large. Maximum size is 5MB.');
    }
    // Prepare form data
    const formData = new FormData();
    formData.append('image', imageFile);

    const response = await fetch(
      `${FLASK_API_BASE_URL}/api/predict-food/${userId}`,
      {
        method: 'POST',
        headers: getAuthHeaders(),
        body: formData,
      }
    );

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw {
        response: {
          status: response.status,
          data: errorData,
        },
      };
    }

    // Parse response
    const data: PredictFoodResponse = await response.json();
    return data;

  } catch (error: any) {
    console.error('Error in predictFood:', error);
    handleApiError(error);
  }
}

export async function saveMeal(
  userId: number,
  mealData: SaveMealRequest
): Promise<SaveMealResponse> {
  try {
    // Validate required fields
    if (!mealData.food_id) {
      throw new Error('food_id is required');
    }

    // Validate confidence_score if provided
    if (
      mealData.confidence_score !== undefined &&
      (mealData.confidence_score < 0 || mealData.confidence_score > 1)
    ) {
      throw new Error('confidence_score must be between 0 and 1');
    }

    const response = await fetch(
      `${FLASK_API_BASE_URL}/api/save-meal/${userId}`,
      {
        method: 'POST',
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(mealData),
      }
    );

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw {
        response: {
          status: response.status,
          data: errorData,
        },
      };
    }

    // Parse response
    const data: SaveMealResponse = await response.json();
    return data;

  } catch (error: any) {
    console.error('Error in saveMeal:', error);
    handleApiError(error);
  }
}

export async function predictAndSaveFood(
  userId: number,
  imageFile: File,
  autoSave: boolean = false
): Promise<{
  prediction: PredictFoodResponse;
  saved?: SaveMealResponse;
}> {
  try {
    const prediction = await predictFood(userId, imageFile);

    if (!prediction.success || !prediction.data) {
      return { prediction };
    }

    if (autoSave && prediction.data.food_id) {
      const mealData: SaveMealRequest = {
        food_id: prediction.data.food_id,
        confidence_score: prediction.data.confidence,
      };

      const saved = await saveMeal(userId, mealData);
      return { prediction, saved };
    }

    return { prediction };

  } catch (error: any) {
    console.error('Error in predictAndSaveFood:', error);
    throw error;
  }
}

export async function checkFlaskApiHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${FLASK_API_BASE_URL}/api/health`, {
      method: 'GET',
    });
    return response.ok;
  } catch (error) {
    console.error('Flask API health check failed:', error);
    return false;
  }
}

// ============================================
// Export default object
// ============================================

const PredictService = {
  predictFood,
  saveMeal,
  predictAndSaveFood,
  checkFlaskApiHealth,
};

export default PredictService;
