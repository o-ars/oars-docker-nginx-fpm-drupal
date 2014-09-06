#!/bin/bash

service php5-fpm restart
service nginx restart

 # Start mysql
/usr/bin/mysqld_safe &
sleep 10s

# Database config
MYSQL_ROOT_PASSWORD="root"
MYSQL_DB="db"
MYSQL_USER="usr"
MYSQL_PASSWORD="pass"

MYSQL=`which mysql`

Q1="CREATE DATABASE IF NOT EXISTS $MYSQL_DB;"
Q2="GRANT USAGE ON *.* TO $MYSQL_USER@localhost IDENTIFIED BY '$MYSQL_PASSWORD';"
Q3="GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO $MYSQL_USER@localhost;"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"

$MYSQL -u root -p"$MYSQL_ROOT_PASSWORD" -e "$SQL"
# GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON vt.* TO 'ku'@'localhost' IDENTIFIED BY 'si';

### Drupal config

#cd /srv/drupal/www;
#drush site-install standard -y --account-name=admin --account-pass=admin --db-url="mysqli://usr:pass@localhost:3306/db"

# Directories
##########################################################
httpDir="/srv/drupal/www"
rootDir="" #leave blank to set http directory as root directory.
##########################################################
 
# Site
##########################################################
siteName="Drupal 7 Site"
siteSlogan="oar's Drupal Dockerfile"
siteLocale="tr"
##########################################################
 
# Database
##########################################################
dbHost="localhost"
dbName="db"
dbUser="usr"
dbPassword="pass"
##########################################################
 
# Admin
##########################################################
AdminUsername="admin"
AdminPassword="admin"
adminEmail="admin@example.com"
##########################################################
 
# Download Core
##########################################################
# drush dl -y --destination=$httpDir --drupal-project-rename=$rootDir;
 
cd $httpDir/$rootDir;
 
# Install core
##########################################################
drush site-install -y standard --account-mail=$adminEmail --account-name=$AdminUsername --account-pass=$AdminPassword --site-name=$siteName --site-mail=$adminEmail --locale=$siteLocale --db-url=mysql://$dbUser:$dbPassword@$dbHost/$dbName;
 
# Download modules and themes
##########################################################
drush -y dl \
ctools \
views \
token \
fences \
metatag \
module_filter \
redirect \
globalredirect \
entity \
views_bulk_operations \
features \
strongarm \
boost \
field_group \
menu_block \
devel \
httprl \
xmlsitemap \
pathauto \
admin_menu \
google_analytics \
backup_migrate \
jquery_update \
webform \
zen;
 
# Disable some core modules
##########################################################
drush -y dis \
color \
aggregator \
blog \
book \
comment \
contact \
dashboard \
dblog \
forum \
overlay \
rdf \
toolbar \
shortcut \
search;
 
# Enable modules
##########################################################
drush -y en \
views \
views_ui \
token \
fences \
metatag \
module_filter \
redirect \
features \
strongarm \
globalredirect \
views_bulk_operations \
entity \
devel \
field_group \
devel_generate \
xmlsitemap \
pathauto \
admin_menu \
backup_migrate \
jquery_update \
webform \
googleanalytics \
admin_menu \
admin_menu_toolbar \
menu_block
zen;
 
# Pre configure settings
##########################################################
# disable user pictures
drush vset -y user_pictures 0;
# allow only admins to register users
drush vset -y user_register 0;
# set site slogan
drush vset -y site_slogan $siteSlogan;
 
# Configure JQuery update
drush vset -y jquery_update_compression_type "min";
drush vset -y jquery_update_jquery_cdn "google";
drush -y eval "variable_set('jquery_update_jquery_version', strval(1.7));"
 
echo -e "////////////////////////////////////////////////////"
echo -e "// Install Completed"
echo -e "////////////////////////////////////////////////////"
while true; do
    read -p "press enter to exit" yn
    case $yn in
        * ) exit;;
    esac
done





# Start all the services
# /usr/local/bin/supervisord -n