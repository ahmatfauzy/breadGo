import { Request, Response, NextFunction } from 'express';

// In-memory store for rate limiting
// Key: IP address, Value: { count: number, resetTime: number }
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

const WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_ATTEMPTS = 5;

// Periodic cleanup to prevent memory leaks
setInterval(() => {
  const now = Date.now();
  for (const [ip, data] of rateLimitStore.entries()) {
    if (now > data.resetTime) {
      rateLimitStore.delete(ip);
    }
  }
}, WINDOW_MS);

export const loginRateLimiter = (req: Request, res: Response, next: NextFunction) => {
  const ip = req.ip || req.socket.remoteAddress || 'unknown';
  const now = Date.now();

  const record = rateLimitStore.get(ip);

  if (!record) {
    rateLimitStore.set(ip, { count: 1, resetTime: now + WINDOW_MS });
    return next();
  }

  // If the window has expired, reset it
  if (now > record.resetTime) {
    record.count = 1;
    record.resetTime = now + WINDOW_MS;
    return next();
  }

  // Increment the attempt count
  record.count += 1;

  if (record.count > MAX_ATTEMPTS) {
    return res.status(429).json({
      success: false,
      message: 'Too many login attempts. Please try again later.',
    });
  }

  next();
};
