import { Request, Response } from "express";
import { prisma } from "../utils/prisma";

const orderInclude = {
  user: { select: { name: true, email: true } },
  items: {
    include: {
      product: { select: { name: true } },
    },
  },
} as const;

const formatOrder = (order: any) => ({
  id: order.id,
  userId: order.userId,
  userName: order.user.name,
  userEmail: order.user.email,
  customerName: order.customerName,
  customerPhone: order.customerPhone,
  customerAddress: order.customerAddress,
  latitude: order.latitude,
  longitude: order.longitude,
  totalAmount: order.totalAmount,
  status: order.status,
  paymentProof: order.paymentProof,
  createdAt: order.createdAt.toISOString(),
  items: order.items.map((item: any) => ({
    id: item.id,
    productId: item.productId,
    productName: item.product.name,
    quantity: item.quantity,
    price: item.price,
  })),
});

export const getAllOrders = async (req: Request, res: Response): Promise<void> => {
  try {
    const { status } = req.query;

    const where: any = {};
    if (status && typeof status === "string") {
      where.status = status;
    }

    const orders = await prisma.order.findMany({
      where,
      include: orderInclude,
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: orders.map(formatOrder) });
  } catch (error) {
    console.error("getAllOrders Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getAllProducts = async (req: Request, res: Response): Promise<void> => {
  try {
    const products = await prisma.product.findMany({
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: products });
  } catch (error) {
    console.error("getAllProducts Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getOrderDetailAdmin = async (req: Request, res: Response): Promise<void> => {
  try {
    const id = req.params.id as string;
    const order = await prisma.order.findUnique({
      where: { id },
      include: orderInclude,
    });

    if (!order) {
      res.status(404).json({ success: false, message: "Order not found" });
      return;
    }

    res.status(200).json({ success: true, data: formatOrder(order) });
  } catch (error) {
    console.error("getOrderDetailAdmin Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};
