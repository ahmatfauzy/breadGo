import bcrypt from "bcryptjs";
import { prisma } from "../src/utils/prisma";

const products = [
  { name: "Roti Coklat", description: "Roti lembut isi coklat lumer", price: 15000, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400", category: "bread" },
  { name: "Roti Keju", description: "Roti panggang taburan keju mozzarella", price: 12000, imageUrl: "https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400", category: "bread" },
  { name: "Roti Sosis", description: "Roti gulung isi sosis sapi", price: 18000, imageUrl: "https://images.unsplash.com/photo-1550376027-737ee5e56be6?w=400", category: "bread" },
  { name: "Roti Pandan", description: "Roti pandan kukus isi selai kelapa", price: 10000, imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400", category: "bread" },
  { name: "Brownies Coklat", description: "Brownies panggang fudge coklat premium", price: 25000, imageUrl: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400", category: "cake" },
  { name: "Cheesecake Strawberry", description: "Cheesecake lembut topping strawberry segar", price: 35000, imageUrl: "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400", category: "cake" },
  { name: "Banana Bread", description: "Roti pisang panggang kacang walnut", price: 22000, imageUrl: "https://images.unsplash.com/photo-1601938769868-57683d4b15a8?w=400", category: "bread" },
  { name: "Croissant Butter", description: "Croissant Prancis lapis butter renyah", price: 20000, imageUrl: "https://images.unsplash.com/photo-1555507036-ab1f4038024a?w=400", category: "bread" },
];

async function main() {
  console.log("Creating admin user...");
  const adminEmail = "admin@breadgo.com";
  const existing = await prisma.user.findUnique({ where: { email: adminEmail } });
  if (!existing) {
    const hashed = await bcrypt.hash("breadgo2026", await bcrypt.genSalt(10));
    await prisma.user.create({ data: { name: "Admin BreadGo", email: adminEmail, password: hashed, role: "admin" } });
    console.log(`  Admin created: admin@breadgo.com / breadgo2026`);
  } else {
    if (existing.role !== "admin") await prisma.user.update({ where: { email: adminEmail }, data: { role: "admin" } });
    console.log(`  Admin exists`);
  }

  console.log("\nSeeding products...");
  for (const p of products) {
    const found = await prisma.product.findFirst({ where: { name: p.name } });
    if (!found) {
      await prisma.product.create({ data: p });
      console.log(`  + ${p.name}`);
    } else {
      console.log(`  - ${p.name} (exists)`);
    }
  }

  console.log("\nDone");
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
