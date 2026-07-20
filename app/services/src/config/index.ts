import dotenv from 'dotenv';

// Load env variables
dotenv.config();

if (!process.env.JWT_SECRET) {
  throw new Error("Missing JWT_SECRET in environment variables!");
}

export const config = {
  port: parseInt(process.env.PORT || '5000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  isProduction: process.env.NODE_ENV === 'production',
  dbUrl: process.env.DATABASE_URL || '',
  dbAuthToken: process.env.AUTH_TOKEN_DB || '',
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: '1d',
};
