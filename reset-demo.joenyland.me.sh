#!/bin/sh

# Reset DBs for demo.joenyland.me sites

# MySQL variables
HOST='rds1.aws.joenyland.me'
USER_NAME='demo'
PASSWORD='VBMiElHFoGv7aZ7vsSu8wpQcCoRntajV'

# αCRM Demo
SITE_ROOT=/var/www/demo.joenyland.me/alpha-crm

git --work-tree $SITE_ROOT --git-dir ${SITE_ROOT}/.git fetch && \
git --work-tree $SITE_ROOT --git-dir ${SITE_ROOT}/.git reset --hard origin/demo && \
git --work-tree $SITE_ROOT --git-dir ${SITE_ROOT}/.git clean -d --force

mysql -h $HOST -u $USER_NAME -p${PASSWORD} -e 'DROP DATABASE IF EXISTS demo_alpha_crm;' && \
mysql -h $HOST -u $USER_NAME -p${PASSWORD} < ${SITE_ROOT}/app/db/create-schema.sql && \
mysql -h $HOST -u $USER_NAME -p${PASSWORD} < ${SITE_ROOT}/app/db/create-users-and-groups.sql
mysql -h $HOST -u $USER_NAME -p${PASSWORD} < ${SITE_ROOT}/app/db/create-demo-data.sql
