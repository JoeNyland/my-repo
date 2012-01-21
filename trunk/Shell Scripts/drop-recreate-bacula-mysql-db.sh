mysqldump -B bacula -u  -p | bzip2 -qz > /mnt/backup/Databases//bacula.21012012.sql.bz2
cp -v /usr/share/bacula-director/make_mysql_tables ~/
sed -i 's/XXX_DBNAME_XXX/bacula/g' ~/make_mysql_tables
sed -i "s/'$* -f'/'$* -f u  -p'/g" ~/make_mysql_tables
mysql -u  -p <<EOMYSQL
SHOW DATABASES;
DROP DATABASE bacula;
CREATE DATABASE bacula;
SHOW DATABASES;
EOMYSQL
chmod +x ~/make_mysql_tables
~/make_mysql_tables && rm -v ~/make_mysql_tables