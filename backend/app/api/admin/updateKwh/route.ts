import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const meterId = Number(body.meterId);
    const deltaKwh = Number(body.deltaKwh);

    if (!meterId || Number.isNaN(deltaKwh)) {
      return NextResponse.json(
        { message: 'meterId dan deltaKwh wajib diisi' },
        { status: 400 },
      );
    }

    const updatedMeter = await prisma.meter.update({
      where: { id: meterId },
      data: {
        currentKwh: {
          increment: deltaKwh,
        },
        lastUpdate: new Date(),
      },
    });

    return NextResponse.json({
      message: 'KWH berhasil diperbarui',
      meter: {
        id: updatedMeter.id,
        currentKwh: updatedMeter.currentKwh,
      },
    });
  } catch (error) {
    console.error('POST /api/admin/update-kwh error:', error);
    return NextResponse.json(
      { message: 'Internal server error' },
      { status: 500 },
    );
  }
}