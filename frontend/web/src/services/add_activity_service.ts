import api from './auth_service';

// ประเภทข้อมูลที่ได้จากการบันทึกกิจกรรม
interface LogActivityResponse {
  success: boolean;
  message: string;
  sport_name: string;
  time: number;
  calories_burned: number;
  total_burned: number;
}

// ประเภทข้อมูลกีฬา
interface Sport {
  sport_id: number;
  sport_name: string;
  burn_out: number;
}

// ดึง User ID จาก localStorage
function getUserId(): number | null {
  if (typeof window === 'undefined') return null;

  const userStr = localStorage.getItem('user');
  if (!userStr) return null;

  try {
    const user = JSON.parse(userStr);
    return user.id || null;
  } catch {
    return null;
  }
}

// Service สำหรับจัดการกิจกรรมและกีฬา
export const AddActivityService = {
  // บันทึกกิจกรรม/กีฬาที่ทำ
  async logActivity(sportName: string, time: number): Promise<LogActivityResponse> {
    try {
      const userId = getUserId();

      if (!userId) {
        throw new Error('User ID not found. Please login again.');
      }

      const response = await api.post(`/api/activity/${userId}`, {
        sport_name: sportName,
        time: time,
      });

      return {
        success: true,
        message: response.data.message || 'Activity logged successfully',
        sport_name: response.data.data?.sport_name || sportName,
        time: response.data.data?.time || time,
        calories_burned: parseFloat(response.data.data?.calories_burned) || 0,
        total_burned: parseFloat(response.data.data?.total_burned) || 0,
      };
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to log activity';
      throw new Error(errorMessage);
    }
  },

  // ดึงรายการกีฬาทั้งหมด
  async getSportsList(): Promise<Sport[]> {
    try {
      const response = await api.get('/api/sports');

      if (Array.isArray(response.data)) {
        return response.data;
      } else if (response.data.sports && Array.isArray(response.data.sports)) {
        return response.data.sports;
      } else {
        throw new Error('Unexpected response format');
      }
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to fetch sports list');
    }
  },
};
