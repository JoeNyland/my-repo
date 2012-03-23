USE `mythconverg`;
SELECT DISTINCT `hostname` FROM `settings`;
DELETE FROM `settings` WHERE `hostname` = 'hostname1';
DELETE FROM `settings` WHERE `hostname` = 'hostname2';
SELECT DISTINCT `hostname` FROM `settings`;