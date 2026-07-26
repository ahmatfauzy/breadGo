import { Response } from "express";
import { prisma } from "../utils/prisma";
import { AuthRequest } from "../middleware/authMiddleware";

export const createOrder = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { customerName, customerPhone, customerAddress, latitude, longitude, items } = req.body;

    if (!customerName || !customerPhone || !customerAddress) {
      res.status(400).json({ success: false, message: "Please provide all required fields" });
      return;
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      res.status(400).json({ success: false, message: "Items cannot be empty" });
      return;
    }

    for (const item of items) {
      const qty = Number(item.quantity);
      if (!Number.isInteger(qty) || qty <= 0) {
        res.status(400).json({ success: false, message: "Invalid quantity for item. Quantity must be a positive integer." });
        return;
      }
    }

    const productIds = Array.from(new Set(items.map((i: any) => i.productId))) as string[];
    const products = await prisma.product.findMany({
      where: { id: { in: productIds }, isActive: true },
    });

    if (products.length !== productIds.length) {
      const found = new Set(products.map((p: any) => p.id));
      const missing = productIds.find((id: string) => !found.has(id));
      res.status(404).json({ success: false, message: `Product not found: ${missing}` });
      return;
    }

    const productMap = new Map(products.map((p: any) => [p.id, p]));

    let totalAmount = 0;
    const orderItems = items.map((item: any) => {
      const product = productMap.get(item.productId)!;
      const qty = Number(item.quantity);
      totalAmount += qty * product.price;
      return {
        productId: item.productId,
        quantity: qty,
        price: product.price,
      };
    });

    const order = await prisma.order.create({
      data: {
        userId: req.user!.userId,
        customerName,
        customerPhone,
        customerAddress,
        latitude: latitude !== undefined ? Number(latitude) : 0,
        longitude: longitude !== undefined ? Number(longitude) : 0,
        totalAmount,
        items: {
          create: orderItems,
        },
      },
      include: {
        items: {
          include: {
            product: { select: { name: true } },
          },
        },
      },
    });

    const response = {
      id: order.id,
      userId: order.userId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      latitude: order.latitude,
      longitude: order.longitude,
      totalAmount: order.totalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
      items: order.items.map((item: any) => ({
        id: item.id,
        productId: item.productId,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.price,
      })),
    };

    res.status(201).json({ success: true, message: "Order created", data: response });
  } catch (error) {
    console.error("createOrder Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getOrders = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const orders = await prisma.order.findMany({
      where: { userId: req.user!.userId },
      include: {
        items: {
          include: {
            product: { select: { name: true } },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    const data = orders.map((order: any) => ({
      id: order.id,
      userId: order.userId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      latitude: order.latitude,
      longitude: order.longitude,
      totalAmount: order.totalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
      items: order.items.map((item: any) => ({
        id: item.id,
        productId: item.productId,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.price,
      })),
    }));

    res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("getOrders Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getOrderById = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const id = req.params.id as string;
    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: {
          include: {
            product: { select: { name: true } },
          },
        },
      },
    });

    if (!order) {
      res.status(404).json({ success: false, message: "Order not found" });
      return;
    }

    if (order.userId !== req.user!.userId) {
      res.status(403).json({ success: false, message: "Not authorized to view this order" });
      return;
    }

    const data = {
      id: order.id,
      userId: order.userId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      latitude: order.latitude,
      longitude: order.longitude,
      totalAmount: order.totalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
      items: order.items.map((item: any) => ({
        id: item.id,
        productId: item.productId,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.price,
      })),
    };

    res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("getOrderById Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const updateOrderStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const id = req.params.id as string;
    const { status } = req.body;
    const validStatuses = ["pending", "confirmed", "delivered", "cancelled"];

    if (!status || !validStatuses.includes(status)) {
      res.status(400).json({ success: false, message: "Invalid status" });
      return;
    }

    const existing = await prisma.order.findUnique({ where: { id } });
    if (!existing) {
      res.status(404).json({ success: false, message: "Order not found" });
      return;
    }

    const order = await prisma.order.update({
      where: { id },
      data: { status },
      include: {
        items: {
          include: {
            product: { select: { name: true } },
          },
        },
      },
    });

    const data = {
      id: order.id,
      userId: order.userId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      latitude: order.latitude,
      longitude: order.longitude,
      totalAmount: order.totalAmount,
      status: order.status,
      createdAt: order.createdAt.toISOString(),
      items: order.items.map((item: any) => ({
        id: item.id,
        productId: item.productId,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.price,
      })),
    };

    res.status(200).json({ success: true, message: "Order status updated", data });
  } catch (error) {
    console.error("updateOrderStatus Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};
