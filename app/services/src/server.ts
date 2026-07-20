import app from './app';
import { config } from './config/index';

const server = app.listen(config.port, () => {
  console.log(`=================================`);
  console.log(`  Server running on port ${config.port}`);
  console.log(`  Environment: ${config.nodeEnv}`);
  console.log(`  API Prefix: ${config.apiPrefix}`);
  console.log(`=================================`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err: any) => {
  console.error('[Unhandled Rejection] Shutting down server...');
  console.error(err);
  server.close(() => {
    process.exit(1);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err: any) => {
  console.error('[Uncaught Exception] Shutting down server...');
  console.error(err);
  server.close(() => {
    process.exit(1);
  });
});
