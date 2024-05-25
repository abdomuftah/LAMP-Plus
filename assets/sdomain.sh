#!/bin/bash

# Function to display errors
display_error() {
    echo "Error: $1"
    exit 1
}
clear
echo ""
echo -e "\e[1;34m******************************************\e[0m"
echo -e "\e[1;34m*        Scar Naruto Add Domain           *\e[0m"
echo -e "\e[1;34m******************************************\e[0m"
echo -e "\e[1;34m*       Add New Domain To Server        *\e[0m"
echo -e "\e[1;34m*           with Lets Encrypt           *\e[0m"
echo -e "\e[1;34m******************************************\e[0m"
echo ""

# Prompt user for domain and email
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]): ' domain
read -p 'Email for Lets Encrypt SSL: ' email

# Generate random password for phpMyAdmin
phpmyadmin_password=$(openssl rand -base64 12)

# Validate domain format
if [[ ! $domain =~ ^[a-zA-Z0-9.-]+$ ]]; then
    display_error "Invalid domain format"
fi

# Validate email format
if [[ ! $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    display_error "Invalid email format"
fi

mkdir /var/www/html/$domain || display_error "Failed to create directory for domain"

# Download Apache virtual host configuration template
wget -P /etc/apache2/sites-available https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/Example.conf || display_error "Failed to download virtual host configuration template"
mv /etc/apache2/sites-available/Example.conf /etc/apache2/sites-available/$domain.conf || display_error "Failed to move virtual host configuration template"

# Replace placeholder with domain in Apache virtual host configuration
sed -i "s/example.com/$domain/g" /etc/apache2/sites-available/$domain.conf || display_error "Failed to replace domain in virtual host configuration template"

# Download index.php template
wget -P /var/www/html/$domain https://raw.githubusercontent.com/abdomuftah/LAMP-Plus/main/assets/index.php || display_error "Failed to download index.php template"
sed -i "s/example.com/$domain/g" /var/www/html/$domain/index.php || display_error "Failed to replace domain in index.php template"

a2ensite $domain || display_error "Failed to enable site configuration"
systemctl restart apache2 || display_error "Failed to restart Apache"

chown -R www-data:www-data /var/www/html/$domain/
chmod -R 755 /var/www/html/$domain/

certbot --noninteractive --agree-tos --no-eff-email --cert-name $domain --apache --redirect -d $domain -m $email || display_error "Failed to install Let's Encrypt SSL"
#certbot renew --dry-run || display_error "Failed to run Let's Encrypt SSL renewal dry run"
systemctl restart apache2.service || display_error "Failed to restart Apache after Let's Encrypt SSL renewal"

# Display success message
clear
echo -e "\e[1;35m##################################\e[0m"
echo -e "\e[1;35mYou can thank me on:\e[0m"
echo -e "\e[1;35mhttps://twitter.com/ScarNaruto\e[0m"
echo -e "\e[1;35mJoin my Discord Server:\e[0m"
echo -e "\e[1;35mhttps://discord.snyt.xyz\e[0m"
echo -e "\e[1;35m##################################\e[0m"
echo -e "\e[1;35m----------------------------------\e[0m"
echo -e "\e[1;35mCheck your web server by going to this link:\e[0m"
echo -e "\e[1;35mhttps://$domain\e[0m"
echo -e "\e[1;35m----------------------------------\e[0m"
exit
