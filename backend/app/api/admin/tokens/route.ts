import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(_req: NextRequest) {
  try {
    const meters = await prisma.meter.findMany({
      include: {
        user: true,
      },
      orderBy: {
        id: 'asc',
      },
    });

    const data = meters.map((m) => ({
      meterId: m.id,
      userId: m.userId,
      name: m.user.name,
      email: m.user.email,
      token: m.tokenBalance,
      kwh: m.currentKwh,
    }));

    return NextResponse.json({ data });
  } catch (error) {
    console.error('GET /api/admin/tokens error:', error);
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 },
    );
  }
}