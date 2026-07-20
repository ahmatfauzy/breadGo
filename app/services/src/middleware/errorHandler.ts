import { Request, Response, NextFunction } from 'express';
import { config } from '../config/index';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  console.error('[Error Handled]:', err.stack || err.message || err);

  const statusCode = err.status || err.statusCode || 500;
  
  res.status(statusCode).json({
    success: false,
    error: {
      message: err.message || 'Internal Server Error',
      ...(config.isProduction ? {} : { stack: err.stack }),
    },
  });
};
