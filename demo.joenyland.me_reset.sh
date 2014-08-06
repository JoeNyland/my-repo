#!/bin/sh

# Reset DBs for demo.joenyland.me sites

USER='demo'
PASSWORD='VBMiElHFoGv7aZ7vsSu8wpQcCoRntajV'

# αCRM Demo
mysql -u${USER} -p${PASSWORD} -e 'DROP DATABASE IF EXISTS demo_alpha_crm;'
mysql -u${USER} -p${PASSWORD} < /var/www/demo.joenyland.me/alpha-crm/app/db/create-schema.sql
mysql -u${USER} -p${PASSWORD} < /var/www/demo.joenyland.me/alpha-crm/app/db/create-users-and-groups.sql
