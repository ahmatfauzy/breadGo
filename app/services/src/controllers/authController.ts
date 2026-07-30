import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../utils/prisma';
import { config } from '../config/index';
import { AuthRequest } from '../middleware/authMiddleware';
import {
  generateVerificationCode,
  hashVerificationCode,
  compareVerificationCode,
  isCodeExpired,
} from '../services/verificationService';
import { sendVerificationCode as sendEmail } from '../services/emailService';

const generateToken = (userId: string, email: string, role: string) => {
  return jwt.sign({ userId, email, role }, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn as any,
  });
};

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      res.status(400).json({ success: false, message: 'Please provide all required fields' });
      return;
    }

    const userExists = await prisma.user.findUnique({ where: { email } });
    if (userExists) {
      res.status(400).json({ success: false, message: 'User already exists' });
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const code = generateVerificationCode();
    const hashedCode = await hashVerificationCode(code);

    await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
        isVerified: false,
        verificationCode: hashedCode,
        verificationCodeCreatedAt: new Date(),
      },
    });

    // Fire and forget — don't block response on email send failure
    sendEmail(email, code).catch((err) => {
      console.error('Failed to send verification email:', err);
    });

    res.status(201).json({
      success: true,
      message: 'Verification code sent to email',
      data: { email },
    });
  } catch (error) {
    console.error('Register Error:', error);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
};

export const verifyEmail = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      res.status(400).json({ success: false, message: 'Please provide email and verification code' });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    if (user.isVerified) {
      res.status(400).json({ success: false, message: 'Email already verified' });
      return;
    }

    if (!user.verificationCode || !user.verificationCodeCreatedAt) {
      res.status(400).json({ success: false, message: 'No verification code found. Request a new one.' });
      return;
    }

    if (isCodeExpired(user.verificationCodeCreatedAt)) {
      res.status(400).json({ success: false, message: 'Verification code has expired. Request a new one.' });
      return;
    }

    const isValid = await compareVerificationCode(code, user.verificationCode);
    if (!isValid) {
      res.status(400).json({ success: false, message: 'Invalid verification code' });
      return;
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        isVerified: true,
        verificationCode: null,
        verificationCodeCreatedAt: null,
      },
    });

    const token = generateToken(user.id, user.email, user.role);

    res.status(200).json({
      success: true,
      message: 'Email verified successfully',
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        token,
      },
    });
  } catch (error) {
    console.error('Verify Email Error:', error);
    res.status(500).json({ success: false, message: 'Server error during verification' });
  }
};

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ success: false, message: 'Please provide email and password' });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
      return;
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
      return;
    }

    if (!user.isVerified) {
      res.status(403).json({
        success: false,
        message: 'Please verify your email first',
        needsVerification: true,
        email: user.email,
      });
      return;
    }

    const token = generateToken(user.id, user.email, user.role);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        token,
      },
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};

export const resendCode = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({ success: false, message: 'Please provide email' });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    if (user.isVerified) {
      res.status(400).json({ success: false, message: 'Email already verified' });
      return;
    }

    // Basic rate limit: 60 seconds since last code
    if (user.verificationCodeCreatedAt) {
      const elapsed = (Date.now() - user.verificationCodeCreatedAt.getTime()) / 1000;
      if (elapsed < 60) {
        const remaining = Math.ceil(60 - elapsed);
        res.status(429).json({
          success: false,
          message: `Please wait ${remaining} seconds before requesting a new code`,
        });
        return;
      }
    }

    const code = generateVerificationCode();
    const hashedCode = await hashVerificationCode(code);

    await prisma.user.update({
      where: { id: user.id },
      data: {
        verificationCode: hashedCode,
        verificationCodeCreatedAt: new Date(),
      },
    });

    sendEmail(email, code).catch((err) => {
      console.error('Failed to resend verification email:', err);
    });

    res.status(200).json({
      success: true,
      message: 'New verification code sent to email',
    });
  } catch (error) {
    console.error('Resend Code Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export const getMe = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ success: false, message: 'Not authorized' });
      return;
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        isVerified: true,
        createdAt: true,
      },
    });

    if (!user) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Get Me Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
