#!/bin/bash

DATADIR=/var/lib/mysql/backup
MODE=$1

NUM_MONTHS=4
NUM_WEEKS=4
NUM_DAYS=7

OLDEST_MONTH=
OLDEST_WEEK=
OLDEST_DAY=

function get_oldest() {
    level=$1

    oldest=
    for i in $(seq $NUM_DAYS -1 0 ); do
        if [ -d "$DATADIR/$level.$i" ]; then
            oldest=$i;
            break;
        fi
    done

    echo $oldest;
}

function rotate() {
    level=$1
    max_num=$2
    oldest=$(get_oldest $level);
    echo "rotate $level $max_num $oldest"

    if [ ! -z $oldest ]; then
        if [ $oldest -ge $(( $max_num - 1 )) ]; then
            for i in $(seq $(( $max_num - 1 )) $oldest ); do
                if [ -d "$DATADIR/$level.$i" ]; then
                    rm -rf "$DATADIR/$level.$i"
                fi
            done
        fi

        for i in $oldest $(seq $oldest -1 0 ); do
            if [ -d "$DATADIR/$level.$i" ]; then
                new_num=$(( $i + 1 ));
                mv "$DATADIR/$level.$i" "$DATADIR/$level.$new_num";
            fi
        done
    fi
}

if [ ! -d "$DATADIR" ]; then
    mkdir -p "$DATADIR"
fi

if [ "$MODE" == "M" ]; then
    rotate monthly $NUM_MONTHS

    oldest_week=$(get_oldest 'weekly');
    [ -d "$DATADIR/weekly.$oldest_week" ] && mv $DATADIR/weekly.$oldest_week $DATADIR/monthly.0
elif [ "$MODE" == "W" ]; then
    rotate weekly $NUM_WEEKS

    oldest_day=$(get_oldest 'daily');
    [ -d "$DATADIR/daily.$oldest_day" ] && mv $DATADIR/daily.$oldest_day $DATADIR/weekly.0
elif [ "$MODE" == "D" ]; then
    rotate daily $NUM_DAYS

    mkdir $DATADIR/daily.0
    databases=();
    for dbname in $(echo "SHOW DATABASES" | mysql -uroot -proot|grep -v Database); do
        [ "$dbname" == 'mysql' ] && continue;
        [ "$dbname" == 'information_schema' ] && continue;
        [ "$dbname" == 'backup' ] && continue;
        [ "$dbname" == "performance_schema" ] && continue;
        [ "$dbname" == "setup" ] && continue;

        databases+=($dbname);
    done
    mysqldump -uroot -proot --all-tablespaces -R --databases ${databases[@]} > $DATADIR/daily.0/$(date +%Y%m%d)-backup.sql
else
    echo "Invalid backup mode" > /dev/stderr;
    exit 1
fi
