-- Admin account for .
CREATE USER ''@'%' IDENTIFIED BY '';
GRANT ALL ON *.* TO ''@'%' WITH GRANT OPTION;
-- XBMC user.
CREATE USER 'xbmc'@'%' IDENTIFIED BY '';
GRANT ALL ON `xbmc\_%`.* TO `xbmc`@`%`;
-- Access account for Bacula MySQL backups.
CREATE USER 'bacula_backup'@'localhost' IDENTIFIED BY '';
GRANT SELECT,RELOAD,SHOW DATABASES,SUPER,LOCK TABLES,SHOW VIEW ON *.* TO 'bacula_backup'@'localhost';
-- Reset password for Bacula account.
SET PASSWORD FOR 'bacula'@'localhost' = PASSWORD('');
-- Apply privileges.
FLUSH PRIVILEGES;