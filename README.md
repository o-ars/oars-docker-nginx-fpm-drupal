# oar's Docker Nginx PHP-FPM Drupal 7

This is a Dockerfile

 * phusion/baseimage ( Ubuntu 14.04 )
 * Nginx ( latest )
 * PHP-FPM ( latest )
 * MySQL 5.5
 * Drupal 7 ( latest ) + Drush ( latest )


When builded it's size 836.9 MB. 

# OK ! HOW ?

 * 1 - Download & open this repo 
	```
	git clone https://github.com/o-ars/oars-docker-nginx-fpm-drupal.git
	```
 
	```
	cd oars-docker-nginx-fpm-drupal
	``` 
 * 2 - If you didn't install docker before run this command. 
	```
	./install_docker.sh
	``` 
 * 3 - Build this Dockerfile. ( wait approx 5 min. )
	```
	./build.sh
	```
 * 4 - Serve the docker image to your system.
	```
	./serve.sh
	```
 * 5 - After the logged in the image run the configuration script. ( wait approx 2 min. )
	```
	root@7b3080757ac5:/# ./serve.sh
    
	```
 * 6 - Your Drupal 7 is ready. Open your browser and type.
 	```
	http://127.0.0.1  
	```
 
 # Users & Passwords 

MySQL root Password = root

MySQL DB = db

MySQL User = usr

MySQL Password = pass

Drupal Admin Username = admin

Drupal Admin Password = admin

Drupal Admin Email = admin@example.com

 
 
 ___ Enabled Drupal 7 modules ___

admin_menu

admin_menu_toolbar 

views
  
views_ui

token

fences

metatag

module_filter

redirect

features

strongarm

globalredirect

views_bulk_operations

entity

devel

field_group

devel_generate

xmlsitemap

pathauto

admin_menu

backup_migrate

jquery_update

webform

googleanalytics

menu_block

zen ( theme )

	Please don't thank me for my service. If you like this you'll maybe donate this great open-source programs.