## 2024-05-18 - Missing Input Validation on Authentication Routes
**Vulnerability:** Missing input validation for email format and string limits for name/password in register and login routes.
**Learning:** The Express backend relies on Prisma for structural integrity but misses controller-level limits, exposing the server to potential abusive inputs (e.g., excessively long passwords making bcrypt hashing a vector for DoS).
**Prevention:** Consistently validate input strings at the controller layer and apply reasonable upper bounds (e.g. max 100 characters for password) before passing them to expensive operations like bcrypt.
