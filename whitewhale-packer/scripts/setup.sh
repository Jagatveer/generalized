#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install apache2 -y
sudo a2enmod rewrite
sudo a2enmod deflate
sudo a2enmod headers
sudo a2enmod expires
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update -y
sudo apt-get install php7.3 -y
sudo apt-get install php7.3-apcu -y
sudo apt-get install php7.3-ssh2 -y
sudo apt-get install php7.3-ldap -y
sudo cp /home/ubuntu/apcu.ini /etc/php/7.3/mods-available/apcu.ini
sudo cp /home/ubuntu/php.ini /etc/php/7.3/apache2/php.ini
sudo cp /home/ubuntu/expires.conf /etc/apache2/mods-available/expires.conf
sudo cp /home/ubuntu/deflate.conf /etc/apache2/mods-available/deflate.conf
sudo ln -s /etc/apache2/mods-available/expires.conf /etc/apache2/mods-enabled/expires.conf
sudo systemctl restart apache2
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs