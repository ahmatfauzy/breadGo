import bcrypt from "bcryptjs";
import { prisma } from "../src/utils/prisma";

const products = [
  { name: "Roti Coklat", description: "Roti lembut isi coklat lumer", price: 15000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784956278/breadgo_products/cu15fhx1of4ai1rckizy.jpg", category: "bread" },
  { name: "Roti Keju", description: "Roti panggang taburan keju mozzarella", price: 12000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955959/breadgo_products/th6nafdnz4cgxjdnh98s.jpg", category: "bread" },
  { name: "Roti Sosis", description: "Roti gulung isi sosis sapi", price: 18000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955964/breadgo_products/ndmgwqo2d3eftuzq6wnm.jpg", category: "bread" },
  { name: "Roti Pandan", description: "Roti pandan kukus isi selai kelapa", price: 10000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955967/breadgo_products/wfk4fs8jaqadm87x2pyd.jpg", category: "bread" },
  { name: "Brownies Coklat", description: "Brownies panggang fudge coklat premium", price: 25000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955969/breadgo_products/ix0ypsdjho67hgtey6ju.jpg", category: "cake" },
  { name: "Cheesecake Strawberry", description: "Cheesecake lembut topping strawberry segar", price: 35000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955971/breadgo_products/q3uhhyhry8ldybl4b1bv.jpg", category: "cake" },
  { name: "Banana Bread", description: "Roti pisang panggang kacang walnut", price: 22000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955974/breadgo_products/dcyri7prooz6wdjihrhx.jpg", category: "bread" },
  { name: "Croissant Butter", description: "Croissant Prancis lapis butter renyah", price: 20000, imageUrl: "https://res.cloudinary.com/dkofai5kp/image/upload/v1784955976/breadgo_products/blzbr7nrvse4ivwocotb.jpg", category: "bread" },
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
      await prisma.product.update({ where: { id: found.id }, data: p });
      console.log(`  ^ ${p.name} (updated)`);
    }
  }

  console.log("\nDone");
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
