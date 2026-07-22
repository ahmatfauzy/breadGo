import { Router } from "express";
import {
  createOrder,
  getOrders,
  getOrderById,
  updateOrderStatus,
} from "../controllers/ordersController";
import { protect } from "../middleware/authMiddleware";
import { adminOnly } from "../middleware/adminOnly";

const router = Router();

router.post("/", protect, createOrder);
router.get("/", protect, getOrders);
router.get("/:id", protect, getOrderById);
router.patch("/:id/status", protect, adminOnly, updateOrderStatus);

export default router;
