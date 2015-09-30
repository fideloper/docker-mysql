#!/usr/bin/env sh

if [ ! -d /var/lib/mysql/mysql ]; then
    echo 'Rebuilding mysql data dir'
        
    chown -R mysql.mysql /var/lib/mysql
    mysql_install_db > /dev/null

    rm -rf /var/run/mysqld/*

    echo 'Starting mysqld'
    mysqld_safe &

    echo 'Waiting for mysqld to come online'
    while [ ! -x /var/run/mysqld/mysqld.sock ]; do
        sleep 1
    done
    
    echo 'Setting root password to root'
    /usr/bin/mysqladmin -u root password 'root'
    /usr/bin/mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY 'root';"
    /usr/bin/mysqladmin -uroot -proot reload

    if [ -d /var/lib/mysql/setup ]; then
        echo 'Found /var/lib/mysql/setup - scanning for SQL scripts'
        for sql in $(ls /var/lib/mysql/setup/*.sql 2>/dev/null | sort); do
            echo 'Running script:' $sql
            mysql -uroot -proot -e "\. $sql"
            mv $sql $sql.processed
        done
    else
        echo 'No setup directory with extra sql scripts to run'
    fi

    echo 'Shutting down mysqld'
    mysqladmin -uroot -proot shutdown

fi
