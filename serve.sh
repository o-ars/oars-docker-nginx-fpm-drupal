#!/bin/bash
echo "run ./config after login";
sudo docker run -t -i -p 80:80 oars/nginx-fpm-drupal /sbin/my_init /bin/bash
