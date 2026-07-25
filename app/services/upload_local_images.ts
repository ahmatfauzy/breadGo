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
  { name: "Roti Coklat", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/roti_coklat_1784955651373.jpg" },
  { name: "Roti Keju", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/roti_keju_1784955660664.jpg" },
  { name: "Roti Sosis", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/roti_sosis_1784955669969.jpg" },
  { name: "Roti Pandan", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/roti_pandan_1784955679582.jpg" },
  { name: "Brownies Coklat", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/brownies_coklat_1784955701479.jpg" },
  { name: "Cheesecake Strawberry", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/cheesecake_strawberry_1784955711304.jpg" },
  { name: "Banana Bread", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/banana_bread_1784955721068.jpg" },
  { name: "Croissant Butter", path: "/home/fauzi/.gemini/antigravity-cli/brain/002e6407-b410-4821-be25-13bcfb2bc347/croissant_butter_1784955730965.jpg" },
];

async function main() {
  console.log("Starting image upload to Cloudinary...");
  const mapping: Record<string, string> = {};
  for (const p of products) {
    try {
      console.log(`Uploading for ${p.name}...`);
      const result = await cloudinary.uploader.upload(p.path, { folder: "breadgo_products" });
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
