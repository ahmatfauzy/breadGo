import { v2 as cloudinary } from 'cloudinary';
import { prisma } from './src/utils/prisma';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const products = [
  { name: "Roti Coklat", url: "https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=800" },
  { name: "Roti Keju", url: "https://images.unsplash.com/photo-1586444248902-2f64eddc13b3?w=800" },
  { name: "Roti Sosis", url: "https://images.unsplash.com/photo-1574345224353-8d022b7dc009?w=800" },
  { name: "Roti Pandan", url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800" },
  { name: "Brownies Coklat", url: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800" },
  { name: "Cheesecake Strawberry", url: "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=800" },
  { name: "Banana Bread", url: "https://images.unsplash.com/photo-1601938769868-57683d4b15a8?w=800" },
  { name: "Croissant Butter", url: "https://images.unsplash.com/photo-1555507036-ab1f4038024a?w=800" },
];

async function main() {
  console.log("Starting image upload to Cloudinary...");
  const mapping: Record<string, string> = {};
  for (const p of products) {
    try {
      console.log(`Uploading for ${p.name}...`);
      const result = await cloudinary.uploader.upload(p.url, { folder: "breadgo_products" });
      const secureUrl = result.secure_url;
      
      await prisma.product.updateMany({
        where: { name: p.name },
        data: { imageUrl: secureUrl }
      });
      mapping[p.name] = secureUrl;
      console.log(`Updated ${p.name} with URL: ${secureUrl}`);
    } catch (e) {
      console.error(`Failed to upload/update ${p.name}:`, e);
    }
  }
  
  fs.writeFileSync('cloudinary_mapping.json', JSON.stringify(mapping, null, 2));
  console.log("Finished updating product images.");
}

main().catch(console.error).finally(() => prisma.$disconnect());
