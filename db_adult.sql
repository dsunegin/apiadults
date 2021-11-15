# Create user for Cron Backup of Database
#create user backup_user@localhost;
#set password for backup_user@localhost=password('psw_backup_user');

CREATE DATABASE video CHARACTER SET utf8 COLLATE utf8_general_ci;
create user adult_user@localhost;
set password for adult_user@localhost=password('psw_adult_user');
grant all on video.* to adult_user@localhost with grant option;
grant all on video.* to backup_user@localhost with grant option;

use video;

CREATE TABLE adult (
id INT(7) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
alias VARCHAR(255) NOT NULL,
video TEXT,
image TEXT,
youtube_channel TEXT,
description TEXT,
created DATETIME DEFAULT  CURRENT_TIMESTAMP,
publish_up DATETIME DEFAULT  CURRENT_TIMESTAMP,
published INT(1) UNSIGNED DEFAULT 1,
ru INT(1) UNSIGNED DEFAULT 0,
uk INT(1) UNSIGNED DEFAULT 0,
be INT(1) UNSIGNED DEFAULT 0,
pl INT(1) UNSIGNED DEFAULT 0,
en INT(1) UNSIGNED DEFAULT 0,
fr INT(1) UNSIGNED DEFAULT 0,
de INT(1) UNSIGNED DEFAULT 0,
es INT(1) UNSIGNED DEFAULT 0,
it INT(1) UNSIGNED DEFAULT 0,
bg INT(1) UNSIGNED DEFAULT 0

);


