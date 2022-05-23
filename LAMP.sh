#!/bin/bash
#
clear
echo ""
echo "******************************************"
echo "*   Scar Naruto UBUNTU 18 + Script       *"
echo "******************************************"
echo "*       this script well install         *"
echo "*      LAMP server and phpMyAdmin        *"
echo "*     With node js and secure your       *"
echo "*      Domain with Let's Encrypt         *"
echo "******************************************"
echo ""
#
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]) : ' domain
read -p 'Email for Lets Encrypt SSL : ' email
read -p 'mySql Password  : ' sqpass
clear
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
apt dist-upgrade
apt autoremove -y
apt-get install default-jdk -y
apt-get install software-properties-common -y
apt-add-repository ppa:webupd8team/java -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:phpmyadmin/ppa -y
add-apt-repository ppa:deadsnakes/ppa -y
add-apt-repository ppa:certbot/certbot -y
add-apt-repository -y ppa:chris-lea/redis-server
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
#
echo "=================================="
echo " install some tools to help you more :) "
echo "=================================="
apt-get install -y screen nano curl git zip unzip ufw certbot python3-certbot-apache
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
apt-get install -y python3.7 libmysqlclient-dev python3-dev python3-pip 
python3 get-pip.py
python3 -m pip install Django
#
echo "=================================="
echo "installing Apache2"
echo "=================================="
apt install apache2
#
systemctl stop apache2.service
systemctl start apache2.service
systemctl enable apache2.service
#
ufw app list
ufw allow in 80
ufw allow in 443
#
echo "=================================="
echo "installing mySQL :"
echo "=================================="
apt-get -y install mariadb-server mariadb-client
#
systemctl stop mariadb.service
systemctl start mariadb.service
systemctl enable mariadb.service
#
mysql_secure_installation
#wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/mysql_secure_installation.sh
#sed -i "s/complex_password/$sqpass/g" /root/mysql_secure_installation.sh
#chmod +x mysql_secure_installation.sh
#./mysql_secure_installation.sh
#rm mysql_secure_installation.sh
#
systemctl restart mysql.service
#
echo "=================================="
echo "installing PHP 8.1 + modules"
echo "=================================="
apt -y install php8.1 php8.1-curl php8.1-common php8.1-cli php8.1-mysql php8.1-sqlite3 php8.1-intl php8.1-gd php8.1-mbstring php8.1-fpm php8.1-xml php8.1-zip php8.1-bcmath php8.1-sqlite3 php8.1-gd php8.1-intl php8.1-xmlrpc php8.1-soap php8.1-bz2 php8.1-imagick php8.1-tidy tar redis-server sed composer
systemctl restart apache2.service
#
echo "=================================="
echo "Install and Secure phpMyAdmin"
echo "=================================="
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
apt-get install -y phpmyadmin php8.1-gettext
#
echo "=================================="
echo "Update php.ini file "
echo "=================================="
wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/php.ini && cp -f php.ini /etc/php/8.1/apache2/ && mv -f php.ini /etc/php/8.1/fpm/
#
a2enmod rewrite
systemctl restart apache2.service
systemctl restart apache2
#
mkdir /var/www/html/$domain
wget -P /etc/apache2/sites-available https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/Example.conf
mv /etc/apache2/sites-available/Example.conf /etc/apache2/sites-available/$domain.conf
sed -i "s/example.com/$domain/g" /etc/apache2/sites-available/$domain.conf
rm /etc/apache2/sites-available/000-default.conf
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/index.php
a2ensite $domain
systemctl restart apache2
#
echo "=================================="
echo "Installing nodeJS"
echo "=================================="
apt-get install -y gcc g++ make nodejs npm 
#
apt update -y && apt upgrade -y
apt-get update && apt-get upgrade -y
systemctl restart apache2.service
#
echo "=================================="
echo "Fixing MySQL And phpMyAdmin"
echo "=================================="
wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/fix.sql
#mysql -u root < fix.sql 
service mysql restart
systemctl restart apache2.service
rm fix.sql 
#
echo "=================================="
echo "Installing Let's Encrypt "
echo "=================================="
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --apache --redirect -d $domain -m $email
systemctl restart apache2.service
certbot renew --dry-run
systemctl restart apache2.service
#
echo "=================================="
echo "Installing glances "
echo "=================================="
wget  https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/glances.sh
chmod +x glances.sh
./glances.sh
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/glances.service
systemctl start glances.service
systemctl enable glances.service
rm glances.sh
#
add-apt-repository -r ppa:ondrej/php -y
add-apt-repository -r ppa:phpmyadmin/ppa -y
add-apt-repository -r ppa:webupd8team/java -y
add-apt-repository -r ppa:chris-lea/redis-server -y
add-apt-repository -r ppa:deadsnakes/ppa -y
add-apt-repository -r ppa:certbot/certbot -y
#
wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/sdomain.sh
chmod +x sdomain.sh
#
apt update
apt upgrade -y
apt-get update 
apt-get upgrade -y
clear
#
echo "your PHP Ver is :"
php -v 
#
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/Scar_Naruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo "you can add new domain to your server  "
echo "by typing : ./sdomain.sh in the terminal  "
echo "##################################"
echo "to cheack your server status go to : "
echo " http://$domain:61208  "
#
exit
