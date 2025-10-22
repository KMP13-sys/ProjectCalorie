import express from "express";
import { deleteUserByAdmin } from "../controllers/admin.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// ลบผู้ใช้โดยแอดมิน
router.delete("/delete-user/:id", validateToken, deleteUserByAdmin);

export default router;
