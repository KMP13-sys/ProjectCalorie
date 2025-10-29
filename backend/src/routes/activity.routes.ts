import express from "express";
import { logActivity } from "../controllers/activity.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// ต้องมี validateToken ก่อน logActivity(แก้ error)
router.post("/:userId", validateToken, logActivity);

export default router;
