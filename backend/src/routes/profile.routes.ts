import { Router } from "express";
import { getProfile, getProfileSummary } from "../controllers/profile.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.get("/:id", validateToken, getProfile);
router.get("/:id/summary", validateToken, getProfileSummary);

export default router;
