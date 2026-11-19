-- Выполнить один раз. Команда /pass больше не требует /create_pass.
-- Поля оставлены для совместимости со старой системой и будущего расширения.
ALTER TABLE `accounts`
  ADD COLUMN IF NOT EXISTS `passport_first_name` VARCHAR(32) NOT NULL DEFAULT '' AFTER `name`,
  ADD COLUMN IF NOT EXISTS `passport_last_name`  VARCHAR(32) NOT NULL DEFAULT '' AFTER `passport_first_name`,
  ADD COLUMN IF NOT EXISTS `birth_date` VARCHAR(10) NOT NULL DEFAULT '01.01.2000' AFTER `passport_last_name`,
  ADD COLUMN IF NOT EXISTS `has_passport` TINYINT(1) NOT NULL DEFAULT 1 AFTER `birth_date`;

UPDATE `accounts`
SET `has_passport` = 1,
    `passport_first_name` = IF(`passport_first_name` = '', SUBSTRING_INDEX(`name`, '_', 1), `passport_first_name`),
    `passport_last_name` = IF(`passport_last_name` = '', SUBSTRING_INDEX(`name`, '_', -1), `passport_last_name`);
