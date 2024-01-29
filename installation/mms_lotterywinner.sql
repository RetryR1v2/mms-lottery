CREATE TABLE `mms_lotterywinner` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`firstname` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`lastname` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`pricemoney` INT(11) NOT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=6
;
