#!/usr/bin/env bash

echo "--- Good morning, master. Let's get to work. Installing now. ---"

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties

echo "--- Package For PHP 5.6 ---"
sudo add-apt-repository -y ppa:ondrej/php5-5.6

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-intl mysql-server-5.5 php5-mysql php5-sqlite git-core

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

echo "--- What developer codes without errors turned on? Not you, master. ---"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo "-- Configure Apache"
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sudo sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www/' /etc/apache2/sites-enabled/000-default.conf

echo "--- Composer is the future. But you knew that, did you master? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Enable Swaping Memory
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

# Other Suffs

echo "-- Installing IonCube --"
cd /usr/local
sudo wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
sudo tar xzf ioncube_loaders_lin_x86-64.tar.gz
sudo mkdir -p /opt/sp/php5.6/lib/php/extensions/ioncube/
sudo cp ioncube/ioncube_loader_lin_5.6.so /opt/sp/php5.6/lib/php/extensions/ioncube/
sudo bash -c 'echo "zend_extension=/opt/sp/php5.6/lib/php/extensions/ioncube/ioncube_loader_lin_5.6.so" > /etc/php5/apache2/conf.d/0-ioncube.ini'

echo "-- Installing Z-Ray for Apache --"
sudo -u
cd /opt
sudo wget http://downloads.zend.com/zray/0112/zray-php-102775-php5.6.15-linux-debian7-amd64.tar.gz
sudo tar xzf zray-php-102775-php5.6.15-linux-debian7-amd64.tar.gz -C /opt
mv /opt/zray-php-102775-php5.6.15-linux-debian7-amd64/zray /opt/zray
cp /opt/zray/zray-ui.conf /etc/apache2/sites-available
a2ensite zray-ui.conf
ln -sf /opt/zray/zray.ini /etc/php5/apache2/conf.d/zray.ini
ln -sf /opt/zray/zray.ini /etc/php5/cli/conf.d/zray.ini

# Note:  The exact location of the extensions may vary depending on the specific distro you're installing on.
ln -sf /opt/zray/lib/zray.so /usr/lib/php5/20131226/zray.so # Debian 8
#ln -sf /opt/zray/lib/zray.so /usr/lib/php5/20121212/zray.so # Ubuntu 14.04

chown -R www-data:www-data /opt/zray

echo "--- Restarting Apache ---"
sudo service apache2 restart

cd /var/www
php -v