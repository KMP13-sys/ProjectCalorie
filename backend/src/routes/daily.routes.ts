import { Router } from "express";
import {
  getTodayMeals,
  getTodayActivities,
  calculateAndSaveCalories,
  getCalorieStatus,
  getDailyMacros,
  getWeeklyCalories,
} from "../controllers/daily.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// รายการอาหารของวันปัจจุบัน
router.get("/meals/:userId", validateToken, getTodayMeals);

// รายการกิจกรรมของวันปัจจุบัน
router.get("/activities/:userId", validateToken, getTodayActivities);

// กราฟรายสัปดาห์
router.get("/weekly/:userId", validateToken, getWeeklyCalories);

// คำนวณและบันทึกแคลอรี่ (BMR + TDEE + Target Calories)
router.post("/calculate-calories/:userId", validateToken, calculateAndSaveCalories);

// สถานะแคลอรี่ประจำวัน
router.get("/status/:userId", validateToken, getCalorieStatus);

// กราฟวงกลม
router.get("/macros/:userId", validateToken, getDailyMacros);

export default router;
