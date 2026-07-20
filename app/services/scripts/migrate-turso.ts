import { createClient } from '@libsql/client';
import { config } from '../src/config/index';

async function migrate() {
  const client = createClient({
    url: config.dbUrl,
    authToken: config.dbAuthToken,
  });

  console.log('Menghubungkan ke Turso DB...');

  try {
    await client.execute(`
      CREATE TABLE IF NOT EXISTS "User" (
          "id" TEXT NOT NULL PRIMARY KEY,
          "name" TEXT NOT NULL,
          "email" TEXT NOT NULL,
          "password" TEXT NOT NULL,
          "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
          "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    // Create unique index for email
    await client.execute(`
      CREATE UNIQUE INDEX IF NOT EXISTS "User_email_key" ON "User"("email");
    `);

    console.log('✅ Tabel User berhasil dibuat di Turso DB!');
  } catch (error) {
    console.error('❌ Gagal membuat tabel:', error);
  } finally {
    client.close();
  }
}

migrate();
