import { Request, Response } from "express";
import { prisma } from "../utils/prisma";

export const getProducts = async (req: Request, res: Response): Promise<void> => {
  try {
    const { category, search } = req.query;

    const where: any = { isActive: true };
    if (category && typeof category === "string") {
      where.category = category;
    }
    if (search && typeof search === "string") {
      where.name = { contains: search };
    }

    const products = await prisma.product.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: products });
  } catch (error) {
    console.error("getProducts Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getProductById = async (req: Request, res: Response): Promise<void> => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
    });

    if (!product || !product.isActive) {
      res.status(404).json({ success: false, message: "Product not found" });
      return;
    }

    res.status(200).json({ success: true, data: product });
  } catch (error) {
    console.error("getProductById Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const createProduct = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, description, price, imageUrl, category } = req.body;

    if (!name || !description || !price || !imageUrl) {
      res.status(400).json({ success: false, message: "Please provide all required fields" });
      return;
    }

    const product = await prisma.product.create({
      data: {
        name,
        description,
        price: Number(price),
        imageUrl,
        category: category || "bread",
      },
    });

    res.status(201).json({ success: true, message: "Product created", data: product });
  } catch (error) {
    console.error("createProduct Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const updateProduct = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, description, price, imageUrl, category, isActive } = req.body;

    const existing = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!existing) {
      res.status(404).json({ success: false, message: "Product not found" });
      return;
    }

    const data: any = {};
    if (name !== undefined) data.name = name;
    if (description !== undefined) data.description = description;
    if (price !== undefined) data.price = Number(price);
    if (imageUrl !== undefined) data.imageUrl = imageUrl;
    if (category !== undefined) data.category = category;
    if (isActive !== undefined) data.isActive = Boolean(isActive);

    const product = await prisma.product.update({
      where: { id: req.params.id },
      data,
    });

    res.status(200).json({ success: true, message: "Product updated", data: product });
  } catch (error) {
    console.error("updateProduct Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const deleteProduct = async (req: Request, res: Response): Promise<void> => {
  try {
    const existing = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!existing) {
      res.status(404).json({ success: false, message: "Product not found" });
      return;
    }

    await prisma.product.update({
      where: { id: req.params.id },
      data: { isActive: false },
    });

    res.status(200).json({ success: true, message: "Product deleted" });
  } catch (error) {
    console.error("deleteProduct Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};
