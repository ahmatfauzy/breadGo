import "dotenv/config";
import { createClient } from "@libsql/client";

const url = process.env.DATABASE_URL;
const authToken = process.env.AUTH_TOKEN_DB;

if (!url || !authToken) {
  console.error("DATABASE_URL and AUTH_TOKEN_DB are required in .env");
  process.exit(1);
}

const client = createClient({ url, authToken });

async function migrate() {
  console.log("Connecting to Turso DB...");

  try {
    await client.execute(`
      CREATE TABLE IF NOT EXISTS "User" (
        "id" TEXT NOT NULL PRIMARY KEY,
        "name" TEXT NOT NULL,
        "email" TEXT NOT NULL,
        "password" TEXT NOT NULL,
        "role" TEXT NOT NULL DEFAULT 'customer',
        "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    `);
    await client.execute(`CREATE UNIQUE INDEX IF NOT EXISTS "User_email_key" ON "User"("email");`);
    console.log("  User table OK");

    await client.execute(`
      CREATE TABLE IF NOT EXISTS "Product" (
        "id" TEXT NOT NULL PRIMARY KEY,
        "name" TEXT NOT NULL,
        "description" TEXT NOT NULL,
        "price" REAL NOT NULL,
        "imageUrl" TEXT NOT NULL,
        "category" TEXT NOT NULL DEFAULT 'bread',
        "isActive" INTEGER NOT NULL DEFAULT 1,
        "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("  Product table OK");

    await client.execute(`
      CREATE TABLE IF NOT EXISTS "Order" (
        "id" TEXT NOT NULL PRIMARY KEY,
        "userId" TEXT NOT NULL,
        "customerName" TEXT NOT NULL,
        "customerPhone" TEXT NOT NULL,
        "customerAddress" TEXT NOT NULL,
        "latitude" REAL NOT NULL,
        "longitude" REAL NOT NULL,
        "totalAmount" REAL NOT NULL,
        "status" TEXT NOT NULL DEFAULT 'pending',
        "paymentProof" TEXT,
        "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY ("userId") REFERENCES "User"("id")
      );
    `);
    console.log("  Order table OK");
    try { await client.execute(`ALTER TABLE "Order" ADD COLUMN "paymentProof" TEXT;`); } catch (e) { /* column may already exist */ }

    await client.execute(`
      CREATE TABLE IF NOT EXISTS "OrderItem" (
        "id" TEXT NOT NULL PRIMARY KEY,
        "orderId" TEXT NOT NULL,
        "productId" TEXT NOT NULL,
        "quantity" INTEGER NOT NULL,
        "price" REAL NOT NULL,
        FOREIGN KEY ("orderId") REFERENCES "Order"("id"),
        FOREIGN KEY ("productId") REFERENCES "Product"("id")
      );
    `);
    console.log("  OrderItem table OK");

    console.log("\nAll tables created on Turso DB");
  } catch (error) {
    console.error("Migration failed:", error);
    process.exit(1);
  } finally {
    client.close();
  }
}

migrate();
