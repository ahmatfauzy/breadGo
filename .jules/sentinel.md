## 2024-07-24 - [Input Validation] Negative Quantity Vulnerability
**Vulnerability:** The `createOrder` endpoint lacked input validation for the `quantity` of items, allowing a malicious user to submit negative quantities or non-integers.
**Learning:** This could manipulate the total order amount to be negative or invalid. E-commerce systems are susceptible to these types of manipulation if quantity validation is not enforced.
**Prevention:** Always validate that numeric inputs representing quantities are positive integers (`Number.isInteger(qty) && qty > 0`) before processing them in calculations.
