DROP DATABASE IF EXISTS `test`; -- Drops the existing database.

RESET MASTER; -- Resets the log file chain.

CREATE DATABASE IF NOT EXISTS `test`; -- Creates a new blank database to restore to.

USE `test`; -- Connect to the database.

CREATE TABLE IF NOT EXISTS `test_table` (
id INT(10) NOT NULL AUTO_INCREMENT,
mytext VARCHAR(10),
PRIMARY KEY (id)
); -- Create a test table.

INSERT INTO `test_table` (`mytext`)
VALUES
	('test'); -- Insert a new row, with the mytext field set to test.

FLUSH LOGS; -- Flush the binary logs and force MySQL to start a new transaction logs

SHOW BINARY LOGS; -- Show the transaction logs in the current index.