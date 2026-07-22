import { Router } from 'express';
import healthRoutes from './healthRoutes';
import authRoutes from './authRoutes';
import productsRoutes from './productsRoutes';
import ordersRoutes from './ordersRoutes';
import adminRoutes from './adminRoutes';

const router = Router();

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/products', productsRoutes);
router.use('/orders', ordersRoutes);
router.use('/admin', adminRoutes);

export default router;
