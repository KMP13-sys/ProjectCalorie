import { Router } from "express";
import { getUserProfile, updateUserProfile } from "../controllers/user.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.get("/:id", validateToken, getUserProfile);
router.put("/:id", validateToken, updateUserProfile);

export default router;
