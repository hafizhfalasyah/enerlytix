import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Start seeding database...');

  // ============================
  // 1. Hash password
  // ============================
  const adminPassword = await bcrypt.hash('admin', 10);
  const userPassword = await bcrypt.hash('user', 10);

  // ============================
  // 2. Create Users
  // ============================
  const admin = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      name: 'Admin',
      email: 'admin@example.com',
      passwordHash: adminPassword,
      role: Role.ADMIN,
    },
  });

  const user1 = await prisma.user.upsert({
    where: { email: 'budi@example.com' },
    update: {},
    create: {
      name: "Budi Budiman",
      email: 'budi@example.com',
      passwordHash: userPassword,
      role: Role.USER,
    },
  });

  const user2 = await prisma.user.upsert({
    where: { email: 'adi@example.com' },
    update: {},
    create: {
      name: 'Adi Setiawan',
      email: 'adi@example.com',
      passwordHash: userPassword,
      role: Role.USER,
    },
  });

  console.log('✅ Users created:', { admin: admin.id, user1: user1.id, user2: user2.id });

  // ============================
  // 3. Create Meters
  // ============================
  const meter1 = await prisma.meter.create({
    data: {
      userId: user1.id,
      meterNumber: 'MTR-001-BUDI',
      alias: 'Rumah Budi',
      powerLimitVa: 1300,
      currentKwh: 120.5,
      tokenBalance: 45000,
      currentWatt: 315,
    },
  });

  const meter2 = await prisma.meter.create({
    data: {
      userId: user2.id,
      meterNumber: 'MTR-002-ADI',
      alias: 'Rumah Adi',
      powerLimitVa: 2200,
      currentKwh: 98.3,
      tokenBalance: 75000,
      currentWatt: 500,
    },
  });

  console.log('✅ Meters created:', { meter1: meter1.id, meter2: meter2.id });

  // ============================
  // 4. Token History (Top Up)
  // ============================
  await prisma.tokenHistory.createMany({
    data: [
      {
        meterId: meter1.id,
        tokenNumber: 'TOKBUD1',
        kwhAdded: 45.0,
        price: 45000,
      },
      {
        meterId: meter2.id,
        tokenNumber: 'TOKADI1',
        kwhAdded: 75.0,
        price: 75000,
      },
    ],
  });

  console.log('✅ TokenHistory created');

  // ============================
  // 5. Usage History (5 hari terakhir)
  // ============================
  const today = new Date();

  function dayOffset(offset: number) {
    const d = new Date(today);
    d.setDate(d.getDate() - offset);
    return d;
  }

  const usageUser1 = [
    { offset: 0, kwh: 3.2 },
    { offset: 1, kwh: 2.8 },
    { offset: 2, kwh: 2.4 },
    { offset: 3, kwh: 2.1 },
    { offset: 4, kwh: 1.9 },
  ].map((u) => ({
    meterId: meter1.id,
    usageDate: dayOffset(u.offset),
    kwhUsed: u.kwh,
  }));

  const usageUser2 = [
    { offset: 0, kwh: 4.1 },
    { offset: 1, kwh: 3.7 },
    { offset: 2, kwh: 3.3 },
    { offset: 3, kwh: 2.9 },
    { offset: 4, kwh: 2.5 },
  ].map((u) => ({
    meterId: meter2.id,
    usageDate: dayOffset(u.offset),
    kwhUsed: u.kwh,
  }));

  await prisma.usageHistory.createMany({
    data: [...usageUser1, ...usageUser2],
  });

  console.log('✅ UsageHistory created for 2 meters (5 days each)');

  console.log('🌱 Seeding finished.');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });