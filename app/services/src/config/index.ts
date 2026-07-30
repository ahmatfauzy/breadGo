import dotenv from 'dotenv';

// Load env variables
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '5000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  isProduction: process.env.NODE_ENV === 'production',
  dbUrl: process.env.DATABASE_URL || '',
  dbAuthToken: process.env.AUTH_TOKEN_DB || '',
  // ponytail: ganti dengan lazy throw getter saat production sudah punya env var di Vercel dashboard
  jwtSecret: process.env.JWT_SECRET || 'dev-secret-fallback',
  jwtExpiresIn: '1d',
};
