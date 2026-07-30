import bcrypt from 'bcryptjs';

const CODE_EXPIRY_MINUTES = 10;

export const generateVerificationCode = (): string => {
  return String(Math.floor(100000 + Math.random() * 900000));
};

export const hashVerificationCode = async (code: string): Promise<string> => {
  return bcrypt.hash(code, 10);
};

export const compareVerificationCode = async (
  code: string,
  hash: string
): Promise<boolean> => {
  return bcrypt.compare(code, hash);
};

export const getCodeExpiry = (createdAt: Date): Date => {
  return new Date(createdAt.getTime() + CODE_EXPIRY_MINUTES * 60 * 1000);
};

export const isCodeExpired = (createdAt: Date): boolean => {
  return new Date() > getCodeExpiry(createdAt);
};
