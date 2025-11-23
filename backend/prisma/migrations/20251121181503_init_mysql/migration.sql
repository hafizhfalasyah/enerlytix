-- =====================================================================
-- TABEL USER
-- =====================================================================
CREATE TABLE `User` (
    `id`           INT NOT NULL AUTO_INCREMENT,
    `name`         VARCHAR(191) NOT NULL,
    `email`        VARCHAR(191) NOT NULL,
    `passwordHash` VARCHAR(191) NOT NULL,
    `role`         ENUM('ADMIN', 'USER') NOT NULL DEFAULT 'USER',
    `createdAt`    DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE KEY `User_email_key` (`email`),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- =====================================================================
-- TABEL SESSION (TOKEN LOGIN)
-- =====================================================================
CREATE TABLE `Session` (
    `id`        INT NOT NULL AUTO_INCREMENT,
    `token`     VARCHAR(191) NOT NULL,
    `userId`    INT NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE KEY `Session_token_key` (`token`),
    KEY `Session_userId_idx` (`userId`),

    CONSTRAINT `Session_userId_fkey`
      FOREIGN KEY (`userId`) REFERENCES `User`(`id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- =====================================================================
-- TABEL METER (INFO LISTRIK PER USER)
-- =====================================================================
CREATE TABLE `Meter` (
    `id`           INT NOT NULL AUTO_INCREMENT,
    `userId`       INT NOT NULL,
    `meterNumber`  VARCHAR(191) NOT NULL,
    `alias`        VARCHAR(191) NOT NULL,

    -- Daya (VA) untuk kebutuhan UI: UserDashboard & UserMonitoring
    `powerLimitVa` INT NOT NULL DEFAULT 1300,

    -- KWH kumulatif / saldo kWh
    `currentKwh`   DOUBLE NOT NULL DEFAULT 0,

    -- Saldo token dalam rupiah
    `tokenBalance` INT NOT NULL DEFAULT 0,

    -- Beban saat ini (watt)
    `currentWatt`  INT NOT NULL DEFAULT 0,

    `lastUpdate`   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    KEY `Meter_userId_idx` (`userId`),

    CONSTRAINT `Meter_userId_fkey`
      FOREIGN KEY (`userId`) REFERENCES `User`(`id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- =====================================================================
-- TABEL TOKEN HISTORY (RIWAYAT PEMBELIAN TOKEN)
-- =====================================================================
CREATE TABLE `TokenHistory` (
    `id`          INT NOT NULL AUTO_INCREMENT,
    `meterId`     INT NOT NULL,

    -- Nomor token (bisa kode unik dari provider / internal)
    `tokenNumber` VARCHAR(191) NOT NULL,

    -- KWH yang ditambahkan dari token ini
    `kwhAdded`    DOUBLE NOT NULL,

    -- Harga token dalam rupiah
    `price`       INT NOT NULL,

    `purchasedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    KEY `TokenHistory_meterId_idx` (`meterId`),

    CONSTRAINT `TokenHistory_meterId_fkey`
      FOREIGN KEY (`meterId`) REFERENCES `Meter`(`id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- =====================================================================
-- TABEL USAGE HISTORY (RIWAYAT PEMAKAIAN HARIAN KWH)
-- =====================================================================
CREATE TABLE `UsageHistory` (
    `id`        INT NOT NULL AUTO_INCREMENT,
    `meterId`   INT NOT NULL,

    -- Tanggal pemakaian (daily aggregate)
    `usageDate` DATE NOT NULL,

    -- KWH yang dipakai pada hari tersebut
    `kwhUsed`   DOUBLE NOT NULL,

    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    -- 1 row per meter per hari
    UNIQUE KEY `UsageHistory_meterId_usageDate_key` (`meterId`, `usageDate`),
    KEY `UsageHistory_meterId_idx` (`meterId`),
    KEY `UsageHistory_usageDate_idx` (`usageDate`),

    CONSTRAINT `UsageHistory_meterId_fkey`
      FOREIGN KEY (`meterId`) REFERENCES `Meter`(`id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;