USE `mythconverg`;
SELECT DISTINCT `hostname` FROM `settings`;
SELECT DISTINCT `hostname` FROM `keybindings`;

DELETE FROM `settings` WHERE `hostname` = 'hostname1';
DELETE FROM `settings` WHERE `hostname` = 'hostname2';

DELETE FROM `keybindings` WHERE `hostname` = 'hostname1';
DELETE FROM `keybindings` WHERE `hostname` = 'hostname2';

SELECT DISTINCT `hostname` FROM `settings`;
SELECT DISTINCT `hostname` FROM `keybindings`;