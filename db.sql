CREATE DATABASE db CHARACTER SET utf8 COLLATE utf8_general_ci;

USE db;

CREATE TABLE `users`
(
`id` bigint(21) NOT NULL AUTO_INCREMENT,
`alias` varchar(250) CHARACTER SET utf8 collate utf8_general_ci NOT NULL,
`name` varchar(250) CHARACTER SET utf8 collate utf8_general_ci NOT NULL,
`lastname` varchar(250) CHARACTER SET utf8 collate utf8_general_ci NOT NULL,
`pass` varchar(250) CHARACTER SET utf8 collate utf8_general_ci NOT NULL,
`email` varchar(250) CHARACTER SET utf8 collate utf8_general_ci NOT NULL,
`country` char(2) CHARACTER SET utf8 collate utf8_general_ci,
`town` char(250) CHARACTER SET utf8 collate utf8_general_ci,
`dofb` char(10) CHARACTER SET utf8 collate utf8_general_ci,
`gender` char(1) CHARACTER SET utf8 collate utf8_general_ci ,
`account` varchar(250) CHARACTER SET utf8 collate utf8_general_ci,
`mobile` varchar(100) CHARACTER SET utf8 collate utf8_general_ci,
`about` text CHARACTER SET utf8 collate utf8_general_ci,
`ip` text CHARACTER SET utf8 collate utf8_general_ci,
`time` bigint(21),
PRIMARY KEY (`id`),
UNIQUE KEY `alias` (`alias`),
UNIQUE KEY `email` (`email`),
UNIQUE KEY `account` (`account`)
)ENGINE=innoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE utf8_general_ci;

# add user
insert into users VALUES('','woow','M','L', md5('pass'),'xx@xx.xx', 'PL','Town',0,0,0,0,0,0,0);



#short
CREATE TABLE `shortorders`
(
`positionid` varchar(250) CHARACTER SET utf8 collate utf8_general_ci DEFAULT 0,
`position` text CHARACTER SET utf8 collate utf8_general_ci,
`closetime` varchar(250) CHARACTER SET utf8 collate utf8_general_ci DEFAULT 0,
`closeprice` varchar(250) CHARACTER SET utf8 collate utf8_general_ci DEFAULT 0,
`profit` varchar(250) CHARACTER SET utf8 collate utf8_general_ci DEFAULT 0,
`accountid` varchar(250) CHARACTER SET utf8 collate utf8_general_ci DEFAULT 0,
`time` text CHARACTER SET utf8 collate utf8_general_ci,
UNIQUE (`positionid`)
)ENGINE=innoDB DEFAULT CHARSET=utf8 COLLATE utf8_general_ci;
