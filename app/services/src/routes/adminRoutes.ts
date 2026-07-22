import { Router } from "express";
import { getAllOrders, getOrderDetailAdmin } from "../controllers/adminController";
import { protect } from "../middleware/authMiddleware";
import { adminOnly } from "../middleware/adminOnly";

const router = Router();

router.get("/orders", protect, adminOnly, getAllOrders);
router.get("/orders/:id", protect, adminOnly, getOrderDetailAdmin);

export default router;
