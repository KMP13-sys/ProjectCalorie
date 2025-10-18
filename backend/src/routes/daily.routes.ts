import { Router } from "express";
import { getTodayMeals, getTodayActivities } from "../controllers/daily.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// รายการอาหารของวันปัจจุบัน
router.get("/foods/:userId", validateToken, getTodayMeals);

// รายการกิจกรรมของวันปัจจุบัน
router.get("/sports/:userId", validateToken, getTodayActivities);

export default router;
