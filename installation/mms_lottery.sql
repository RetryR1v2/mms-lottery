CREATE TABLE `mms_lotteryjackpot` (
	`jackpot` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`money` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;

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

CREATE TABLE `mms_lotterytimer` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`timer` INT(11) NOT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
;
