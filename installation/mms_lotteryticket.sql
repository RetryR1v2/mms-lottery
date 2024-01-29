CREATE TABLE `mms_lotteryticket` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`firstname` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`lastname` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`identifier` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci',
	`tickets` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=58
;
