## 2024-05-24 - Missing Input Validation on Order Quantities
**Vulnerability:** The `createOrder` endpoint in `app/services/src/controllers/ordersController.ts` accepted any numeric value for item quantities, including negative numbers and decimals.
**Learning:** This could allow a malicious user to manipulate their order total, potentially receiving goods for free or causing negative billing. All numerical inputs affecting billing must be strictly validated.
**Prevention:** Always validate that quantities are positive integers before using them in mathematical operations, particularly those dealing with pricing or billing.
