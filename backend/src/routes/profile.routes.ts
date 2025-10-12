import { Router } from "express";
import { getUserProfile } from "../controllers/profile.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.get("/:id", validateToken, getUserProfile);

export default router;
