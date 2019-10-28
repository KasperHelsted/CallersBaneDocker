#!/bin/bash

if [[ ! -v MYSQL_HOST ]] || [[ ! -v MYSQL_USER ]] || [[ ! -v MYSQL_PASS ]] || [[ ! -v MYSQL_DB ]] ; then
    echo "[CallersBane] Environment variables not set"
else
    if [[ ! -v SKIP_DATABASE_SETUP ]] && [ ! -f /setup-file ]; then
        echo "[CallersBane] First run detected, setting up database"

        while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
            echo "[CallersBane] Waiting for mariadb to be online"
            sleep 1
        done


        SQL="./callersbane/callersbane_database.sql"

        # Yeah we need to remove this to use other databases
        sed -i -e '14d' ${SQL}
        sed -i -e '14d' ${SQL}

        echo "[CallersBane] Database up, importing data"
        mysql --user=${MYSQL_USER} --password=${MYSQL_PASS} --host=${MYSQL_HOST} -D ${MYSQL_DB} < ${SQL}

        echo "[CallersBane] Database successfully setup"

        echo "[CallersBane] Setting up config file"

        CONFIG="./callersbane/CallersBane-Server/cfg/hibernate.cfg.xml"

        sed -i 's/127.0.0.1:3306\/scrolls/'"$MYSQL_HOST"'\/'"$MYSQL_DB"'/g' ${CONFIG}
        sed -i 's/username">root/username">'"$MYSQL_USER"'/g' ${CONFIG}
        sed -i 's/password">/password">'"$MYSQL_PASS"'/g' ${CONFIG}

        echo "[CallersBane] Successfully modified config file"
        touch /setup-file
    fi
    echo "[CallersBane] Starting server"

    java -Dio.netty.epollBugWorkaround=true -Dscrolls.mode=PROD -Dscrolls.node.id=$SERVER_ID -jar ./callersbane/CallersBane-Server/Server.jar
fi
