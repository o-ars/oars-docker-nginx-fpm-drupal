# docker Drupal
#
# VERSION 1
# DOCKER-VERSION 1

FROM phusion/baseimage:latest
MAINTAINER oar <argunomer@gmail.com> 

### TODO ###
# 1 - MOVE DRUPAL /srv/drupal/www -> /srv/www/drupal7
# 2 - Setup proper ports configuration
# 3 - clean docker init 

### ----------------------------------- ###
### ----- 1 - MAIN Configurations ----- ###
### ----------------------------------- ###
# System Packages & Updates #
RUN apt-get update -y && \
	apt-get install -y nano git curl wget bash-completion python-software-properties pwgen python-setuptools unzip language-pack-en
#RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl
CMD ["/sbin/my_init"]

# Environment Variables #
ENV HOME /home
ENV DEBIAN_FRONTEND noninteractive

# Language UTF-8 #
RUN apt-get -y install locales && \
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8



### ---------------------------------------- ###
### ----- 2 - Update Package Libraries ----- ###
### ---------------------------------------- ###
# Ubuntu Packages #
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list

# Nginx Latest Packages #
RUN add-apt-repository -y ppa:nginx/stable

# PHP 5 Latest Packages #
RUN add-apt-repository -y ppa:ondrej/php5

# Ready to Install #
RUN apt-key update && \
	apt-get update -y && \
	apt-get upgrade -y



### -------------------------------- ###
### ----- 3 - Install Packages ----- ###
### -------------------------------- ###
RUN apt-get -y install nginx php5-fpm php5-cli php5-mysql php5-gd php5-curl php-pear
RUN apt-get install -y supervisor

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD /config/supervisord.conf /etc/supervisord.conf
ADD /config/drupal7.conf /etc/nginx/sites-available/default



### --------------------------------- ###
### ----- 4 - PHP Configuration ----- ###
### --------------------------------- ###
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini 
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;



### ----------------------------------- ###
### ----- 5 - MYSQL Configuration ----- ###
### ----------------------------------- ###
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get install -y mysql-server && \
    sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf
RUN sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf && \
	sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
RUN /usr/sbin/mysqld --skip-networking & \
    sleep 5s && \
    echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES" \
    | mysql -u root -proot



### ----------------------------------- ###
### ----- 6 - NGINX Configuration ----- ###
### ----------------------------------- ###

RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN unlink /etc/nginx/sites-enabled/default
RUN cp /etc/nginx/sites-available/default /etc/nginx/sites-available/drupal7.conf
RUN awk '{sub(/1/,"root /srv/drupal/www;")}root /usr/share/nginx/html;' /etc/nginx/sites-available/default > /etc/nginx/sites-available/drupal7.conf
RUN ln -s /etc/nginx/sites-available/drupal7.conf /etc/nginx/sites-enabled/drupal7.conf




### ------------------------------------- ###
### ----- 7 - Install DRUPAL & DRUSH----- ###
### ------------------------------------- ###
RUN pear channel-discover pear.drush.org && pear install drush/drush
RUN cd /srv && mkdir -p /srv/drupal && chmod 755 /srv/drupal
RUN drush dl drupal --destination=/srv/drupal --drupal-project-rename=www
RUN	chown -R www-data:www-data /srv/drupal/www/
RUN	cp /srv/drupal/www/sites/default/default.settings.php /srv/drupal/www/sites/default/settings.php
RUN	chmod a+w /srv/drupal/www/sites/default/settings.php
RUN chown -R www-data:www-data /srv/drupal/www/
RUN cd /srv/drupal/www


### -------------------------------------- ###
### ----- 8 - Clean & Initialization ----- ###
### -------------------------------------- ###
# Clean #
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get autoremove -y
RUN apt-get autoclean -y

# Drupal Initialization and Startup Script
ADD config.sh /config.sh
RUN chmod 755 /config.sh

# PORT Configurations #
EXPOSE 80
EXPOSE 3306
EXPOSE 22
EXPOSE 8000
EXPOSE 10000

# Initialization #
CMD ["/bin/bash", "/config.sh"]






















# nginx
#RUN rm -rf /etc/nginx
#RUN rm -rf /srv/www/*
#RUN mkdir -p /var/cache/nginx/microcache
#RUN mkdir -p /var/lib/nginx/speed
#RUN mkdir -p /var/lib/nginx/body
#RUN git clone https://github.com/perusio/drupal-with-nginx /etc/nginx
#ADD perusio-customconf.patch /tmp/perusio-customconf.patch
#RUN cd /etc/nginx && cat /tmp/perusio-customconf.patch | git apply
##RUN cd /etc/nginx | git apply
#ADD config/etc/nginx/sites-available/site.conf /etc/nginx/sites-available/site.conf
#RUN mkdir -p /etc/nginx/sites-enabled

# php55
#RUN adduser --system --group --home /srv/www www55 && usermod -aG www-data www55
#RUN mkdir -p /etc/php5/fpm/pool.d
#RUN mkdir /var/log/php
#ADD config/etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
#ADD config/etc/php5/fpm/fpm-pool-common.conf /etc/php5/fpm/fpm-pool-common.conf
#ADD config/etc/php5/fpm/php.ini /etc/php5/fpm/php.ini
#ADD config/etc/php5/fpm/pool.d/www55.conf /etc/php5/fpm/pool.d/www55.conf
#ADD config/etc/php5/cli/php.ini /etc/php5/cli/php.ini