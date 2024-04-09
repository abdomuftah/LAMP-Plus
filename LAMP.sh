#!/bin/bash

# Clear the screen
clear

# Display header
echo ""
echo -e "\e[1;34m******************************************\e[0m"
echo -e "\e[1;34m*      Ubuntu 22 LAMP Server Setup       *\e[0m"
echo -e "\e[1;34m******************************************\e[0m"
echo -e "\e[1;34m* This script will install a LAMP stack *\e[0m"
echo -e "\e[1;34m* with phpMyAdmin, Node.js, and secure  *\e[0m"
echo -e "\e[1;34m* your domain with Let's Encrypt SSL.   *\e[0m"
echo -e "\e[1;34m******************************************\e[0m"
echo ""

# Function to display error message and exit
display_error() {
    echo -e "\e[1;31mError: $1\e[0m"
    exit 1
}

# Function to prompt user for input and validate
get_user_input() {
    read -p "$1" input
    if [[ -z "$input" ]]; then
        display_error "Input cannot be empty"
    fi
    echo "$input"
}

# Prompt user for domain, email, and MySQL root password
domain=$(get_user_input "Set Web Domain (Example: example.com): ")
email=$(get_user_input "Email for Let's Encrypt SSL: ")
mysql_root_password=$(get_user_input "Enter MySQL root password: ")

# Update system packages
echo -e "\e[1;32mUpdating system packages...\e[0m"
sleep 3
apt update && apt upgrade -y || display_error "Failed to update system packages"
apt autoremove -y

# Install required packages and repositories
echo -e "\e[1;32mInstalling required packages and repositories...\e[0m"
sleep 3
apt-get install -y default-jdk software-properties-common || display_error "Failed to install packages"
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2 || display_error "Failed to add Apache2 repository"
add-apt-repository -y ppa:phpmyadmin/ppa || display_error "Failed to add phpMyAdmin repository"
add-apt-repository -y ppa:deadsnakes/ppa
add-apt-repository -y ppa:redislabs/redis
apt update && apt upgrade -y

# Install additional tools
echo -e "\e[1;32mInstalling additional tools...\e[0m"
sleep 3
apt install -y screen nano curl git zip unzip ufw certbot python3-certbot-apache || display_error "Failed to install additional tools"
apt install -y python3.11 libmysqlclient-dev python3-dev python3-pip
ln -s /usr/bin/python3.11 /usr/bin/python
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py || display_error "Failed to install Python pip"
python3 -m pip install Django
rm get-pip.py

# Install Apache2
echo -e "\e[1;32mInstalling Apache2...\e[0m"
apt install -y apache2 || display_error "Failed to install Apache2"

# Ensure Apache2 is running
echo -e "\e[1;32mChecking Apache2 service...\e[0m"
if ! systemctl is-active --quiet apache2; then
    display_error "Apache2 service is not running"
fi

# Configure firewall
echo -e "\e[1;32mConfiguring firewall...\e[0m"
ufw allow in 80
ufw allow in 443
ufw allow OpenSSH

# Install MySQL
echo -e "\e[1;32mInstalling MySQL...\e[0m"
apt -y install mariadb-server mariadb-client || display_error "Failed to install MySQL"

# Secure MariaDB installation
echo -e "\e[1;32mSecuring MariaDB installation...\e[0m"
sudo mysql_secure_installation <<EOF
Y
$mysql_root_password
$mysql_root_password
Y
Y
Y
Y
EOF

# Restart MariaDB service
sudo systemctl restart mariadb || display_error "Failed to restart MariaDB"
echo -e "\e[1;32mMariaDB has been successfully installed and secured.\e[0m"

# Continue with the rest of the installation process...

# Install PHP 8.1 and required modules
echo -e "\e[1;32mInstalling PHP 8.1 + modules...\e[0m"
apt -y install php8.1 php8.1-curl php8.1-common php8.1-cli php8.1-mysql php8.1-sqlite3 php8.1-intl php8.1-gd php8.1-mbstring php8.1-fpm php8.1-xml php8.1-zip php8.1-bcmath libapache2-mod-php8.1 php8.1-sqlite3 php8.1-gd php8.1-intl php8.1-xmlrpc php8.1-soap php8.1-bz2 php8.1-imagick php8.1-tidy tar redis-server sed composer
systemctl enable --now php8.1-fpm || display_error "Failed to enable PHP 8.1 FPM service"

# Install phpMyAdmin
echo -e "\e[1;32mInstalling phpMyAdmin...\e[0m"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $mysql_root_password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $mysql_root_password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
sleep 5
apt install -y phpmyadmin || display_error "Failed to install phpMyAdmin"

# Update PHP configuration
echo -e "\e[1;32mUpdating PHP configuration...\e[0m"
sleep 3
wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/php.ini || display_error "Failed to download PHP configuration file"
cp -f php.ini /etc/php/8.1/cli/ || display_error "Failed to copy PHP configuration file to CLI directory"
mv -f php.ini /etc/php/8.1/fpm/ || display_error "Failed to move PHP configuration file to FPM directory"
systemctl restart apache2
service php8.1-fpm reload

# Create Apache2 virtual host
echo -e "\e[1;32mConfiguring Apache2 virtual host...\e[0m"
sleep 3
mkdir /var/www/html/$domain
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/index.php || display_error "Failed to download index.php"
sed -i "s/example.com/$domain/g" /var/www/html/$domain/index.php || display_error "Failed to replace domain in index.php"
wget -P /etc/apache2/sites-available https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/Example.conf || display_error "Failed to download Apache2 configuration file"
mv /etc/apache2/sites-available/Example.conf /etc/apache2/sites-available/$domain.conf
sed -i "s/example.com/$domain/g" /etc/apache2/sites-available/$domain.conf
a2ensite $domain
systemctl restart apache2

# Install Node.js
echo -e "\e[1;32mInstalling Node.js...\e[0m"
sleep 3
apt-get install -y gcc g++ make nodejs npm || display_error "Failed to install Node.js"
apt update -y && apt upgrade -y
systemctl restart apache2
service php8.1-fpm reload

# Install Let's Encrypt SSL
echo -e "\e[1;32mInstalling Let's Encrypt SSL...\e[0m"
sleep 3
certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --apache --redirect -d $domain -m $email || display_error "Failed to install Let's Encrypt SSL"
certbot renew --dry-run
systemctl restart apache2

# Install glances
echo -e "\e[1;32mInstalling Glances...\e[0m"
sleep 3
wget  https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/glances.sh || display_error "Failed to download Glances script"
chmod +x glances.sh
./glances.sh || display_error "Failed to install Glances"
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/glances.service || display_error "Failed to download Glances service file"
systemctl start glances.service
systemctl enable glances.service
rm glances.sh

# Set PHP version
update-alternatives --set php /usr/bin/php8.1
systemctl restart apache2
service php8.1-fpm reload

# Additional configuration scripts
wget https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/sdomain.sh
chmod +x sdomain.sh

# Final messages
apt update && apt upgrade -y
clear
echo "========================================="
DISTRO=$(cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+")
echo "Your operating system is $DISTRO"
echo "========================================="
CURRENT=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
echo "Current PHP version of this system: PHP-$CURRENT"
#
echo -e "\e[1;35m##################################\e[0m"
echo -e "\e[1;35mYou can thank me on:\e[0m"
echo -e "\e[1;35mhttps://twitter.com/ScarNaruto\e[0m"
echo -e "\e[1;35mJoin my Discord Server:\e[0m"
echo -e "\e[1;35mhttps://discord.snyt.xyz\e[0m"
echo -e "\e[1;35m##################################\e[0m"
echo -e "\e[1;35mYou can add a new domain to your server\e[0m"
echo -e "\e[1;35mby typing: ./sdomain.sh in the terminal\e[0m"
echo -e "\e[1;35m----------------------------------\e[0m"
echo -e "\e[1;35mphpMyAdmin Credentials:\e[0m"
echo -e "\e[1;35mUsername: root\e[0m"
echo -e "\e[1;35mPassword: $mysql_root_password\e[0m"
echo -e "\e[1;35m----------------------------------\e[0m"
echo -e "\e[1;35mCheck your web server by going to this link:\e[0m"
echo -e "\e[1;35mhttps://$domain\e[0m"
#
rm ~/LAMP.sh
exit
