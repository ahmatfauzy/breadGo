import { Router } from "express";
import { getAllOrders, getAllProducts, getOrderDetailAdmin } from "../controllers/adminController";
import { protect } from "../middleware/authMiddleware";
import { adminOnly } from "../middleware/adminOnly";

const router = Router();

router.get("/orders", protect, adminOnly, getAllOrders);
router.get("/orders/:id", protect, adminOnly, getOrderDetailAdmin);
router.get("/products", protect, adminOnly, getAllProducts);

export default router;
