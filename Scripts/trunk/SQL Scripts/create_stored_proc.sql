DELIMITER $$

CREATE PROCEDURE `test_sp`
    (
        parameter1 VARCHAR(255)
    )
    BEGIN
    INSERT INTO users VALUES(parameter1,'',parameter1,'novm',0,'','out=Always|in=Adhoc','',parameter1,'default');
    END$$
    
DELIMITER ;