-- DropForeignKey
ALTER TABLE `usagehistory` DROP FOREIGN KEY `UsageHistory_meterId_fkey`;

-- DropIndex
DROP INDEX `UsageHistory_meterId_usageDate_key` ON `usagehistory`;

-- DropIndex
DROP INDEX `UsageHistory_usageDate_idx` ON `usagehistory`;

-- AlterTable
ALTER TABLE `usagehistory` MODIFY `usageDate` DATETIME(3) NOT NULL;

-- AddForeignKey
ALTER TABLE `UsageHistory` ADD CONSTRAINT `UsageHistory_meterId_fkey` FOREIGN KEY (`meterId`) REFERENCES `Meter`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
