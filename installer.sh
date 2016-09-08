#!/bin/bash
echo "     _______   _______   _______"
echo "    / _____/  / _____/  / ___  /"
echo "   / /____   / /       / /__/ /"
echo "  / _____/  / /____   /  ____/"
echo " /_/       /______/  /_/"
echo " "
echo "> Installer"
                                                                                                  
echo "This software is released under the GPLv3 license. You may find a copy here: http://www.gnu.org/licenses/quick-guide-gplv3.en.html"

echo "Do you accept? (y/N)"

read accept

if [ "$accept" == "N" ]; then
echo "Installation aborted."
exit 1
else if [ ! "$accept" == "y" ]; then
echo "Invalid response. Installation aborted."
exit 1
fi
fi

sleep 1

echo "This installer will download and configure FlamesCP 2 for you. You have 3 seconds to abort."

sleep 3

echo "For your Minecraft server, how much memory do you want to allocate in megabytes (MB)? [Default: 512MB]"
read memory

if [ -z "$memory" ]; then
memory=512
fi

mkdir -p /SERVER
echo "eula=true" > /SERVER/eula.txt

mkdir -p /scripts
cat <<EOF > /scripts/start.sh
#!/bin/bash
cd /SERVER
java -Xms"$memory"M -Xmx"$memory"M -jar server.jar nogui
EOF

wget http://tcpr.ca/files/spigot/spigot-1.10.2-R0.1-SNAPSHOT-latest.jar -O /SERVER/server.jar &> /dev/null

sleep 1

echo "Configuring iptables..."

iptables -A INPUT -p tcp --dport 5555 -j ACCEPT
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT

service iptables save &> /dev/null
service iptables restart &> /dev/null

echo "Now installing dependencies..."

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum install screen nano httpd mysql-server php55w php55w-mysql php55w-pdo php55w-gd unzip gcc make sudo java7 git curl curl-devel vsftpd pam pam-devel pam_mysql -y &> /dev/null

echo "The required packages have been installed."
sleep 1

echo "Retrieving files from repository..."
cd /tmp
wget https://github.com/FlamesRunner/FlamesCP-2/archive/master.zip
unzip master.zip
cd FlamesCP-2-master
mkdir -p /usr/local/flamescp
cp -R /tmp/FlamesCP-2-master/web/* /usr/local/flamescp/

mkdir -p /scripts
cp -R /tmp/FlamesCP-2-master/scripts/* /scripts/

mkdir -p /usr/sbin
cp /tmp/FlamesCP-2-master/daemon/flamescpd /usr/sbin/flamescpd
chmod 755 /usr/bin/flamescpd

cp /tmp/FlamesCP-2-master/extra/init /etc/init.d/flamescpd
chmod 755 /etc/init.d/flamescpd

cat <<'EOG' > /etc/httpd/conf.d/flamescp.conf

Listen 5555
<VirtualHost *:5555>
        ServerName localhost:5555
        ServerAdmin user@localhost
        DocumentRoot /usr/local/flamescp
</VirtualHost>

EOG

echo "Configuring MySQL..."

mysqlpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

service mysqld start &> /dev/null

mysql -uroot -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$mysqlpass'); flush privileges;"

#echo "Please enter an alphanumeric password for the administrative user."
#read adminpass
#hashedpw=$(echo -n "$adminpass" | sha1sum | sed 's/  -//g')
mysql -uroot -p$mysqlpass -e "create database flamescp;"
mysql -uroot -p$mysqlpass -e "use flamescp; CREATE TABLE login (id int(10) NOT NULL AUTO_INCREMENT, username varchar(255) NOT NULL, password varchar(255) NOT NULL, status varchar(50), PRIMARY KEY (id));"
#mysql -uroot -p$mysqlpass -e "use flamescp; insert into login (id, username, password, status) VALUES(1, 'admin', '$hashedpw', 'admin');"

sleep 2

salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)

cat <<EON > /usr/local/flamescp/include/config.php

<?php

\$salt = "$salt";
\$mysql_password = "$mysqlpass";

?>

EON

echo "Configuring FTP..."

vsftpdpassword=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
mysql -uroot -p$mysqlpass -e "CREATE DATABASE vsftpd;"
mysql -uroot -p$mysqlpass -e "USE vsftpd; CREATE TABLE `accounts` (`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `username` VARCHAR(30) NOT NULL, `pass` VARCHAR(50) NOT NULL , UNIQUE(`username`)) ENGINE = MYISAM ;"
mysql -uroot -p$mysqlpass -e "use vsftpd; GRANT SELECT ON vsftpd.* TO 'vsftpd'@'localhost' IDENTIFIED BY '$vsftpdpassword'; flush privileges;"

useradd -G users -s /sbin/nologin -d /SERVER  
cp /etc/vsftpd/vsftpd.conf   /etc/vsftpd/vsftpd.conf-orig 
echo "" > /etc/vsftpd/vsftpd.conf
cp /tmp/FlamesCP-2-master/extra/vsftpd.conf /etc/vsftpd/vsftpd.conf
mkdir /etc/vsftpd/vsftpd_user_conf 
cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd-orig
cat /dev/null > /etc/pam.d/vsftpd
cat<<EOY > /etc/pam.d/vsftpd
 #%PAM-1.0
 session       optional        pam_keyinit.so       force revoke
 auth required pam_mysql.so user=vsftpd passwd=$vsftpdpassword  host=localhost db=vsftpd table=accounts usercolumn=username   passwdcolumn=pass crypt=3
 account required pam_mysql.so user=vsftpd passwd=$vsftpdpassword  host=localhost db=vsftpd table=accounts usercolumn=username  passwdcolumn=pass crypt=3
EOY

echo "Starting flamescpd..."

service flamescpd start &> /dev/null

sleep 2

echo "Cleaning up installation files..."

rm -rf /tmp/FlamesCP-2-master

sleep 3

clear

yourpubip=`curl -q -s icanhazip.com`

service httpd restart &> /dev/null

echo "-----------------------------------------------------------------------------"
echo "Congratulations! You have successfully installed FlamesCP 2."
echo " "
echo "Please finalize the installation at http://$yourpubip:5555/installer.php"
echo " "
echo "-----------------------------------------------------------------------------"
echo " "
echo "You may log in to the control panel via http://$yourpubip:5555"
echo " "
sleep 1

