import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(_req: NextRequest) {
  try {
    const meters = await prisma.meter.findMany({
      include: {
        user: true,
      },
    });

    const totalKwhAgg = await prisma.meter.aggregate({
      _sum: { currentKwh: true },
    });
    const totalKwhToday = totalKwhAgg._sum.currentKwh ?? 0;

    const activeUsers = meters.length;

    const list = meters.map((m) => ({
      meterId: m.id,
      userId: m.userId,
      name: m.user.name,
      token: m.tokenBalance,
      kwh: m.currentKwh,
      watt: m.currentWatt,
    }));

    return NextResponse.json({
      totalKwhToday,
      activeUsers,
      list,
    });
  } catch (error) {
    console.error('GET /api/admin/monitoring error:', error);
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 },
    );
  }
}