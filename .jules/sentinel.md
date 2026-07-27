## 2024-07-27 - Missing Rate Limiting on Login
**Vulnerability:** No rate limiting was implemented on the `/login` endpoint in `authRoutes.ts`.
**Learning:** This exposes the application to brute-force and credential stuffing attacks against user accounts.
**Prevention:** Always implement rate limiting on sensitive endpoints (like login, password reset, etc.) to mitigate automated attacks. An in-memory rate limiter can be a lightweight initial defense when a dedicated cache (like Redis) is not available.
