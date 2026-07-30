import { Router } from 'express';
import { register, login, verifyEmail, resendCode, getMe } from '../controllers/authController';
import { protect } from '../middleware/authMiddleware';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/verify-email', verifyEmail);
router.post('/resend-code', resendCode);
router.get('/me', protect, getMe);

export default router;
