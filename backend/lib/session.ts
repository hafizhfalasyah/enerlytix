import { NextRequest } from "next/server";
import { prisma } from "./prisma";
import crypto from "crypto";

export async function createSession(userId: number) {
  const token = crypto.randomBytes(32).toString("hex");

  const session = await prisma.session.create({
    data: {
      token,
      userId,
    },
    include: {
      user: true,
    },
  });

  return session;
}

export async function getUserFromRequest(req: NextRequest) {
  const sessionToken = req.headers.get("x-session-token");
  if (!sessionToken) return null;

  const session = await prisma.session.findUnique({
    where: { token: sessionToken },
    include: { user: true },
  });

  if (!session) return null;

  return session.user;
}