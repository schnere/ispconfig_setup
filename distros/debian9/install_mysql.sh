#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
    echo -n "Installing MariaDB... "
    echo "maria-db-10.1 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "maria-db-10.1 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt-get -y install mariadb-client mariadb-server > /dev/null 2>&1
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1\nsql-mode="NO_ENGINE_SUBSTITUTION"/' /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root
	sed -i 's/password =/password = '$CFG_MYSQL_ROOT_PWD'/' /etc/mysql/debian.cnf
	mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
	echo -n "Fix Mysql security"
	# Kill the anonymous users
	mysql -e "DROP USER ''@'localhost'"
	# Because our hostname varies we'll use some Bash magic here.
	mysql -e "DROP USER ''@'$(hostname)'"
	# Kill off the demo database
	mysql -e "DROP DATABASE test"
	# Make our changes take effect
	mysql -e "FLUSH PRIVILEGES"
	service mysql restart > /dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
}