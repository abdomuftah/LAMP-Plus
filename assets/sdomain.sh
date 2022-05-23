#!/bin/bash
#
echo ""
echo "******************************************"
echo "*  	  Scar Naruto add Domain		   *"
echo "******************************************"
echo "*       Add New Domain To Server         *"
echo "*          with Let's Encrypt            *"
echo "******************************************"
echo ""
#
read -p 'Set Web Domain (Example: 127.0.0.1 [Not trailing slash!]) : ' sdomain
read -p 'Email for Lets Encrypt SSL : ' semail
#
mkdir /var/www/html/$sdomain
wget -P /etc/apache2/sites-available https://raw.githubusercontent.com/abdomuftah/UbuntuServer/main/assets/Example.conf
mv /etc/apache2/sites-available/Example.conf /etc/apache2/sites-available/$sdomain.conf
sed -i "s/example.com/$sdomain/g" /etc/apache2/sites-available/$sdomain.conf
wget -P /var/www/html/$sdomain https://raw.githubusercontent.com/abdomuftah/UbuntuServer/main/assets/index.php
a2ensite $sdomain
systemctl restart apache2
certbot --noninteractive --agree-tos --no-eff-email --cert-name $sdomain --apache --redirect -d $sdomain -m $semail
systemctl restart apache2.service
certbot renew --dry-run
systemctl restart apache2.service
clear
echo "##################################"
echo "You Can Thank Me On :) "
echo "https://twitter.com/Scar_Naruto"
echo "Join My Discord Server "
echo "https://discord.snyt.xyz"
echo "##################################"
echo " ypur Domain is now ready  : "
echo "https://$sdomain 	"
#
exit
