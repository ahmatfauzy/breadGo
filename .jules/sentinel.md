## 2024-05-18 - Missing Input Validation on Authentication
**Vulnerability:** Registration endpoint lacked backend validation for email format and password length, even though frontend validation existed.
**Learning:** Client-side validation can be easily bypassed. The backend must independently enforce data integrity and security rules to prevent bad data or weak credentials from entering the database.
**Prevention:** Always implement robust input validation on the server side for all incoming data, especially authentication credentials, regardless of frontend checks.
