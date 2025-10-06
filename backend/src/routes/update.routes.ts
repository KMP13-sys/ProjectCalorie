import express from "express";
import { updateUserProfile } from "../controllers/update.controller";

const router = express.Router();

// PUT /api/users/:id
router.put("/users/:id", updateUserProfile);

export default router;
