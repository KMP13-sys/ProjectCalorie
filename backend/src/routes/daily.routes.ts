import { Router } from "express";
import {
  getTodayMeals,
  getTodayActivities,
  calculateBMR,
  calculateTargetCalories,
  updateConsumedCalories,
  getCalorieStatus,
  getDailyMacros,
  getWeeklyCalories,
} from "../controllers/daily.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// รายการอาหารของวันปัจจุบัน
router.get("/foods/:userId", validateToken, getTodayMeals);
// รายการกิจกรรมของวันปัจจุบัน
router.get("/sports/:userId", validateToken, getTodayActivities);
// กราฟรายสัปดาห์
router.get("/weekly", validateToken, getWeeklyCalories);

// คำนวณหลอด Kcal
router.post("/calculate-bmr/:userId", validateToken, calculateBMR);
router.post("/calculate-target/:userId", validateToken, calculateTargetCalories);
router.post("/update-consumed/:userId", validateToken, updateConsumedCalories);
router.get("/status/:userId", validateToken, getCalorieStatus);
router.get("/macros/:userId", validateToken, getDailyMacros);

export default router;
