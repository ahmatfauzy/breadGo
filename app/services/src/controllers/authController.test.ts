import { describe, it, expect, vi, beforeEach } from 'vitest';
import bcrypt from 'bcryptjs';
import { prisma } from '../utils/prisma';

vi.mock('../utils/prisma', () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
    },
  },
}));

vi.mock('../services/emailService', () => ({
  sendVerificationCode: vi.fn(() => Promise.resolve()),
}));

vi.mock('jsonwebtoken', () => ({
  default: {
    sign: vi.fn(() => 'mock-token'),
  },
  sign: vi.fn(() => 'mock-token'),
}));

import { register, login, verifyEmail, resendCode, getMe } from './authController';
import { sendVerificationCode } from '../services/emailService';

const mockResponse = () => {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  return res as any;
};

describe('register', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('registers user and sends verification code (no token returned)', async () => {
    const req = { body: { name: 'Test', email: 'test@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue(null);
    vi.mocked(prisma.user.create).mockResolvedValue({
      id: '1',
      name: 'Test',
      email: 'test@test.com',
      password: 'hashed',
      role: 'customer',
      isVerified: false,
      verificationCode: 'hashed-code',
      verificationCodeCreatedAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await register(req, res);

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        message: 'Verification code sent to email',
        data: { email: 'test@test.com' },
      })
    );
    expect(sendVerificationCode).toHaveBeenCalledWith('test@test.com', expect.any(String));
  });

  it('returns 400 when fields missing', async () => {
    const req = { body: { name: '', email: '', password: '' } } as any;
    const res = mockResponse();

    await register(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('returns 400 when user already exists', async () => {
    const req = { body: { name: 'Test', email: 'exists@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({ id: '1' } as any);

    await register(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'User already exists' })
    );
  });

  it('handles prisma error on register', async () => {
    const req = { body: { name: 'Test', email: 'test@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockRejectedValue(new Error('DB down'));

    await register(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'Server error during registration' })
    );
  });
});

describe('verifyEmail', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('verifies email with correct code and returns token', async () => {
    const hashedCode = await bcrypt.hash('123456', 10);
    const createdAt = new Date();

    const req = { body: { email: 'test@test.com', code: '123456' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      name: 'Test',
      email: 'test@test.com',
      role: 'customer',
      isVerified: false,
      verificationCode: hashedCode,
      verificationCodeCreatedAt: createdAt,
      password: 'hashed',
      createdAt: new Date(),
      updatedAt: new Date(),
    } as any);

    vi.mocked(prisma.user.update).mockResolvedValue({} as any);

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        message: 'Email verified successfully',
        data: expect.objectContaining({
          token: 'mock-token',
          email: 'test@test.com',
        }),
      })
    );
  });

  it('returns 400 for invalid code', async () => {
    const hashedCode = await bcrypt.hash('123456', 10);

    const req = { body: { email: 'test@test.com', code: '000000' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: false,
      verificationCode: hashedCode,
      verificationCodeCreatedAt: new Date(),
    } as any);

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'Invalid verification code' })
    );
  });

  it('returns 400 for expired code', async () => {
    const hashedCode = await bcrypt.hash('123456', 10);
    const expiredDate = new Date(Date.now() - 11 * 60 * 1000);

    const req = { body: { email: 'test@test.com', code: '123456' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: false,
      verificationCode: hashedCode,
      verificationCodeCreatedAt: expiredDate,
    } as any);

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'Verification code has expired. Request a new one.' })
    );
  });

  it('returns 400 for already verified email', async () => {
    const req = { body: { email: 'test@test.com', code: '123456' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: true,
    } as any);

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'Email already verified' })
    );
  });

  it('returns 400 when verification code not found', async () => {
    const req = { body: { email: 'test@test.com', code: '123456' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: false,
      verificationCode: null,
      verificationCodeCreatedAt: null,
    } as any);

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'No verification code found. Request a new one.' })
    );
  });

  it('handles database error on verify', async () => {
    const req = { body: { email: 'test@test.com', code: '123456' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockRejectedValue(new Error('DB down'));

    await verifyEmail(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

describe('login', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns 403 with needsVerification when user is not verified', async () => {
    const hashedPassword = await bcrypt.hash('password123', 10);

    const req = { body: { email: 'test@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      email: 'test@test.com',
      password: hashedPassword,
      isVerified: false,
    } as any);

    await login(req, res);

    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        message: 'Please verify your email first',
        needsVerification: true,
        email: 'test@test.com',
      })
    );
  });

  it('returns token when user is verified', async () => {
    const hashedPassword = await bcrypt.hash('password123', 10);

    const req = { body: { email: 'test@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      name: 'Test',
      email: 'test@test.com',
      role: 'customer',
      password: hashedPassword,
      isVerified: true,
    } as any);

    await login(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        message: 'Login successful',
      })
    );
  });

  it('returns 401 for invalid credentials', async () => {
    vi.mocked(prisma.user.findUnique).mockResolvedValue(null);

    const req = { body: { email: 'wrong@test.com', password: 'wrong' } } as any;
    const res = mockResponse();

    await login(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  it('returns 401 for wrong password', async () => {
    const hashedPassword = await bcrypt.hash('realpassword', 10);

    const req = { body: { email: 'test@test.com', password: 'wrongpassword' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      password: hashedPassword,
      isVerified: true,
    } as any);

    await login(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  it('handles database error on login', async () => {
    const req = { body: { email: 'test@test.com', password: 'password123' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockRejectedValue(new Error('DB down'));

    await login(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

describe('resendCode', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('resends code for unverified user', async () => {
    const req = { body: { email: 'test@test.com' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: false,
      verificationCodeCreatedAt: new Date(Date.now() - 120 * 1000),
    } as any);

    vi.mocked(prisma.user.update).mockResolvedValue({} as any);

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        message: 'New verification code sent to email',
      })
    );
    expect(sendVerificationCode).toHaveBeenCalledWith('test@test.com', expect.any(String));
  });

  it('returns 429 if rate limited', async () => {
    const req = { body: { email: 'test@test.com' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: false,
      verificationCodeCreatedAt: new Date(), // just now
    } as any);

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(429);
  });

  it('returns 400 if already verified', async () => {
    const req = { body: { email: 'test@test.com' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      isVerified: true,
    } as any);

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('returns 404 if user not found for resend', async () => {
    const req = { body: { email: 'notfound@test.com' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue(null);

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  it('returns 400 if no email provided for resend', async () => {
    const req = { body: {} } as any;
    const res = mockResponse();

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('handles database error on resend', async () => {
    const req = { body: { email: 'test@test.com' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockRejectedValue(new Error('DB down'));

    await resendCode(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

describe('getMe', () => {
  it('returns user data when authorized', async () => {
    const req = { user: { userId: '1', email: 'test@test.com', role: 'customer' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue({
      id: '1',
      name: 'Test',
      email: 'test@test.com',
      role: 'customer',
      isVerified: true,
      createdAt: new Date(),
    } as any);

    await getMe(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: true })
    );
  });

  it('returns 401 without auth', async () => {
    const req = {} as any;
    const res = mockResponse();

    await getMe(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  it('returns 404 if user not found', async () => {
    const req = { user: { userId: 'nonexistent', email: 'test@test.com', role: 'customer' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockResolvedValue(null);

    await getMe(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  it('handles database error on getMe', async () => {
    const req = { user: { userId: '1', email: 'test@test.com', role: 'customer' } } as any;
    const res = mockResponse();

    vi.mocked(prisma.user.findUnique).mockRejectedValue(new Error('DB down'));

    await getMe(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});
