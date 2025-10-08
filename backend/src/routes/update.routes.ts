import express from "express";
import { updateUser } from "../controllers/update.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// PUT /api/update/:id
router.put("/:id", validateToken, updateUser);

export default router;
