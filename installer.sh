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
java -Xms$memoryM -Xmx$memoryM -jar server.jar nogui
EOF

sleep 1

echo "Configuring iptables..."

iptables -A INPUT -p tcp --dport 5555 -j ACCEPT
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT

service iptables save &> /dev/null
service iptables restart &> /dev/null

echo "Now installing dependencies..."

yum install epel-release -y &> /dev/null
yum install screen nano httpd mysql-server php php-mysql php-pdo php-gd unzip gcc make sudo java7 git -y &> /dev/null

echo "The required packages have been installed.
sleep 1

echo "Configuring MySQL..."

mysqlpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

service mysqld start &> /dev/null

mysql -uroot -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$mysqlpass'); flush privileges;"

echo "Retrieving files from repository..."
cd /tmp
wget https://github.com/FlamesRunner/FlamesCP-2/archive/master.zip
unzip master.zip
cd FlamesCP-2
mkdir -p /usr/local/flamescp
cp -R /tmp/FlamesCP-2/web/* /usr/local/flamescp/

mkdir -p /scripts
cp -R /tmp/FlamesCP-2/scripts/* /scripts/

mkdir -p /usr/sbin
cp /tmp/FlamesCP-2/daemon/flamescpd /usr/sbin/flamescpd
chmod 755 /usr/bin/flamescpd

echo "Starting flamescpd..."




