import { describe, it, expect } from 'vitest';
import {
  generateVerificationCode,
  isCodeExpired,
} from './verificationService';

describe('verificationService', () => {
  describe('generateVerificationCode', () => {
    it('generates a 6-digit code', () => {
      const code = generateVerificationCode();
      expect(code).toMatch(/^\d{6}$/);
    });

    it('generates different codes each time', () => {
      const code1 = generateVerificationCode();
      const code2 = generateVerificationCode();
      expect(code1).not.toBe(code2);
    });
  });

  describe('isCodeExpired', () => {
    it('returns false for recent timestamp', () => {
      const recent = new Date();
      expect(isCodeExpired(recent)).toBe(false);
    });

    it('returns true for timestamp older than 10 minutes', () => {
      const old = new Date(Date.now() - 11 * 60 * 1000);
      expect(isCodeExpired(old)).toBe(true);
    });
  });
});
