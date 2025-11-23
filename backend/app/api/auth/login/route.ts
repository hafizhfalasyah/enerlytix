import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcrypt";
import { createSession } from "@/lib/session";

export async function POST(req: NextRequest) {
  try {
    const { email, password } = await req.json();

    if (!email || !password) {
      return NextResponse.json(
        { success: false, message: "email dan password wajib diisi" },
        { status: 400 }
      );
    }

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      return NextResponse.json(
        { success: false, message: "Email atau password salah" },
        { status: 401 }
      );
    }

    const ok = await bcrypt.compare(password, user.passwordHash);

    if (!ok) {
      return NextResponse.json(
        { success: false, message: "Email atau password salah" },
        { status: 401 }
      );
    }

    const session = await createSession(user.id);

    return NextResponse.json({
      success: true,
      message: "Login berhasil",
      data: {
        token: session.token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        }
      }
    });

  } catch (error) {
    console.error(error);
    return NextResponse.json(
      { success: false, message: "Terjadi kesalahan server" },
      { status: 500 }
    );
  }
}