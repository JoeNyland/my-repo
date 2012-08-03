SELECT * FROM `xbmc_video60`.`path`;
UPDATE `xbmc_video60`.`path` set `strPath` = replace(`strPath`, '', '');
SELECT * FROM `xbmc_video60`.`path`;