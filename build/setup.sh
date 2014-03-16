#!/usr/bin/env sh

# Start MySQL
/usr/bin/mysqld_safe > /dev/null 2>&1 &

# Create Database
mysql -uroot -proot -e "CREATE DATABASE a_database"

# Create (unsafe) HelpSpot user, who can connect remotely
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* to 'a_user'@'%' IDENTIFIED BY 'a_password';"

# Shutdown MySQL
mysqladmin -uroot -proot shutdown