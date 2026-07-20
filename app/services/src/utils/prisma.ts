import { PrismaClient } from '@prisma/client';
import { createClient } from '@libsql/client';
import { PrismaLibSql } from '@prisma/adapter-libsql';
import { config } from '../config/index';

const libsql = createClient({
  url: config.dbUrl,
  authToken: config.dbAuthToken,
});

const adapter = new PrismaLibSql(libsql);
export const prisma = new PrismaClient({ adapter });
