import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config } from './config/index';
import { requestLogger } from './middleware/logger';
import { errorHandler } from './middleware/errorHandler';
import apiRouter from './routes/index';

const app = express();

// Global Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

// Base API Routes
app.use(config.apiPrefix, apiRouter);

// Catch 404 and forward to error handler
app.use((req: Request, res: Response, next: NextFunction) => {
  const error: any = new Error(`Not Found - ${req.originalUrl}`);
  error.status = 404;
  next(error);
});

// Global Error Handler
app.use(errorHandler);

export default app;
