// src/routes/auth.routes.ts
import { Router } from "express";
import { register, login, refreshToken , deleteOwnAccount} from "../controllers/auth.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/refresh", refreshToken);
router.delete("/delete-account", validateToken, deleteOwnAccount);

export default router;
