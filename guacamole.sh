#!/bin/bash
if [ ! -f /var/tmp/startup-script-executed ]; then

# Install required packages
sudo add-apt-repository ppa:remmina-ppa-team/remmina-next -y
sudo apt-get update -y
sudo apt-get install freerdp2-dev freerdp2-x11 gnupg2 wget curl htop -y
        
# Get the Guacamole Server Install Script
sudo wget https://raw.githubusercontent.com/itiligent/Guacamole-Setup/main/1-setup.sh
sudo chmod +x 1-setup.sh

# Modify the script parameters
sudo sed -i 's/SERVER_NAME=""/SERVER_NAME="bastion3.n4k.at"/g' 1-setup.sh
sudo sed -i 's/LOCAL_DOMAIN=""/LOCAL_DOMAIN="n4k.at"/g' 1-setup.sh
sudo sed -i 's/INSTALL_MYSQL=""/INSTALL_MYSQL="true"/g' 1-setup.sh
sudo sed -i 's/SECURE_MYSQL=""/SECURE_MYSQL="true"/g' 1-setup.sh
sudo sed -i 's/MYSQL_HOST=""/MYSQL_HOST=""/g' 1-setup.sh
sudo sed -i 's/MYSQL_PORT=""/MYSQL_PORT=""/g' 1-setup.sh
sudo sed -i 's/GUAC_DB=""/GUAC_DB=""/g' 1-setup.sh
sudo sed -i 's/GUAC_USER=""/GUAC_USER=""/g' 1-setup.sh
sudo sed -i 's/GUAC_PWD=""/GUAC_PWD="12345678"/g' 1-setup.sh
sudo sed -i 's/MYSQL_ROOT_PWD=""/MYSQL_ROOT_PWD="12345678"/g' 1-setup.sh
sudo sed -i 's/INSTALL_TOTP=""/INSTALL_TOTP="true"/g' 1-setup.sh
sudo sed -i 's/INSTALL_DUO=""/INSTALL_DUO="false"/g' 1-setup.sh
sudo sed -i 's/INSTALL_LDAP=""/INSTALL_LDAP="false"/g' 1-setup.sh
sudo sed -i 's/INSTALL_NGINX=""/INSTALL_NGINX="true"/g' 1-setup.sh
sudo sed -i 's/PROXY_SITE=""/PROXY_SITE="bastion3.n4k.at"/g' 1-setup.sh
sudo sed -i 's/SELF_SIGN=""/SELF_SIGN="false"/g' 1-setup.sh
sudo sed -i 's/CERT_COUNTRY="AU"/CERT_COUNTRY="LI"/g' 1-setup.sh
sudo sed -i 's/CERT_STATE="Victoria"/CERT_STATE="LI"/g' 1-setup.sh
sudo sed -i 's/CERT_LOCATION="Melbourne"/CERT_LOCATION="Triesen"/g' 1-setup.sh
sudo sed -i 's/CERT_ORG="Itiligent"/CERT_ORG="N4K"/g' 1-setup.sh
sudo sed -i 's/CERT_OU="I.T."/CERT_OU="IT"/g' 1-setup.sh
sudo sed -i 's/CERT_DAYS="3650"/CERT_DAYS="3650"/g' 1-setup.sh
sudo sed -i 's/LETS_ENCRYPT=""/LETS_ENCRYPT="true"/g' 1-setup.sh
sudo sed -i 's/LE_DNS_NAME=""/LE_DNS_NAME="bastion3.n4k.at"/g' 1-setup.sh
sudo sed -i 's/LE_EMAIL=""/LE_EMAIL="info@n4k.at"/g' 1-setup.sh
sudo sed -i 's/BACKUP_EMAIL=""/BACKUP_EMAIL="info@n4k.at"/g' 1-setup.sh
sudo sed -i 's/EMAIL_DOMAIN=""/EMAIL_DOMAIN="n4k.at"/g' 1-setup.sh
sudo sed -i 's/BACKUP_RETENTION="30"/BACKUP_RETENTION="30"/g' 1-setup.sh

# Run the script now
sudo ./1-setup.sh
  
# create the file to indicate that the script has been executed
touch /var/tmp/startup-script-executed
fi
