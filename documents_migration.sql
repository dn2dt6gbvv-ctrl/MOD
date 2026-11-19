-- DOCUMENTS CEF: execute ONCE before starting the new gamemode.
-- It creates persistent license columns and passport birth date defaults.
ALTER TABLE `accounts`
  ADD COLUMN IF NOT EXISTS `birth_date` VARCHAR(10) NOT NULL DEFAULT '01.01.2000' AFTER `name`,
  ADD COLUMN IF NOT EXISTS `has_passport` TINYINT(1) NOT NULL DEFAULT 1 AFTER `birth_date`,
  ADD COLUMN IF NOT EXISTS `license_a` TINYINT(1) NOT NULL DEFAULT 0 AFTER `legality`,
  ADD COLUMN IF NOT EXISTS `license_b` TINYINT(1) NOT NULL DEFAULT 0 AFTER `license_a`,
  ADD COLUMN IF NOT EXISTS `license_c` TINYINT(1) NOT NULL DEFAULT 0 AFTER `license_b`,
  ADD COLUMN IF NOT EXISTS `license_weapon` TINYINT(1) NOT NULL DEFAULT 0 AFTER `license_c`,
  ADD COLUMN IF NOT EXISTS `license_flight` TINYINT(1) NOT NULL DEFAULT 0 AFTER `license_weapon`,
  ADD COLUMN IF NOT EXISTS `license_business` TINYINT(1) NOT NULL DEFAULT 0 AFTER `license_flight`;

UPDATE `accounts`
SET `birth_date` = '01.01.2000'
WHERE `birth_date` IS NULL OR `birth_date` = '';

-- Examples for issuing licenses (replace ACCOUNT_ID with account id):
-- UPDATE `accounts` SET license_a=1, license_b=1, license_c=1 WHERE id=ACCOUNT_ID;
-- UPDATE `accounts` SET license_weapon=1 WHERE id=ACCOUNT_ID;
-- UPDATE `accounts` SET license_flight=1 WHERE id=ACCOUNT_ID;
-- UPDATE `accounts` SET license_business=1 WHERE id=ACCOUNT_ID;
