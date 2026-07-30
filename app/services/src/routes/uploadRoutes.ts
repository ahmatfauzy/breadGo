import { Router } from 'express';
import { upload, uploadImage } from '../controllers/uploadController';
import { protect } from '../middleware/authMiddleware';
import { adminOnly } from '../middleware/adminOnly';

const router = Router();

router.post('/', protect, adminOnly, upload.single('image'), uploadImage);

export default router;
