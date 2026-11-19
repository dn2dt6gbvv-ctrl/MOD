#if defined _jobs_schema_inc
    #endinput
#endif
#define _jobs_schema_inc

stock InitJobsSchema()
{
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `player_skills` (`player_id` INT NOT NULL, `skill_id` INT NOT NULL, `level` INT NOT NULL DEFAULT 1, `progress` INT NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`,`skill_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `avtobus_marsh` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(64) NOT NULL, `start_index` INT NOT NULL DEFAULT 0, `point_count` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `avtobus_cars` (`id` INT NOT NULL AUTO_INCREMENT, `model` INT NOT NULL, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `angle` FLOAT NOT NULL, `marsh_id` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `avtobus_route` (`id` INT NOT NULL AUTO_INCREMENT, `type` INT NOT NULL, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `order` INT NOT NULL DEFAULT 0, `stop_name` VARCHAR(64) NOT NULL DEFAULT '', PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `factory_storage` (`id` INT NOT NULL AUTO_INCREMENT, `wood` INT NOT NULL DEFAULT 0, `metal` INT NOT NULL DEFAULT 0, `materials` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `mechanic_spawns` (`id` INT NOT NULL AUTO_INCREMENT, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `angle` FLOAT NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `mechanic_azs` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(64) NOT NULL, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `razvoz_orders` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(64) NOT NULL, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `required` INT NOT NULL DEFAULT 0, `price` INT NOT NULL DEFAULT 0, `active` TINYINT NOT NULL DEFAULT 1, `type` INT NOT NULL DEFAULT 1, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", "", "");
    return 1;
}
