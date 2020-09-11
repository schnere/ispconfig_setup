#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  if [ "$CFG_SQLSERVER" == "MySQL" ]; then
    echo -n "Installing Database server (MySQL)... "
    echo "mysql-server-8.0 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server-8.0 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mysql-client mysql-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/my.cnf
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting MySQL... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  
  elif [ "$CFG_SQLSERVER" == "MariaDB" ]; then
  
   echo -n "Installing Database server (MariaDB)... "
    echo "mariadb-server-10.3 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mariadb-server-10.3 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mariadb-client mariadb-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root
    CFG_MYSQL_ROOT_PWD_ESCAPED=$(printf '%s\n' "$CFG_MYSQL_ROOT_PWD" | sed -e 's/[\/&]/\\&/g')
    sed -i 's/password \=.*/password = $CFG_MYSQL_ROOT_PWD_ESCAPED/' /etc/mysql/debian.cnf
    echo -e "mysql soft nofile 65535\nmysql hard nofile 65535" >> /etc/security/limits.conf
    mkdir /etc/systemd/system/mysql.service.d/
    echo -e "[Service]\nLimitNOFILE=infinity" > /etc/systemd/system/mysql.service.d/limits.conf
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting MariaDB... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  fi	
}
