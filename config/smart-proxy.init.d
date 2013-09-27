#!/bin/bash -l
# smart-proxy daemon
# chkconfig: 345 20 80
# description: smart-proxy daemon
# processname: smart-proxy

DAEMON_PATH="/opt/smart-proxy/current"
DAEMON="${DAEMON_PATH}/bin/unicorn"
DAEMONOPTS=" -c ${DAEMON_PATH}/config/unicorn.rb -D"

NAME=smart-proxy
DESC="Webhook endpoint for gitlab post receive hook to deploy puppet code"
PIDFILE="/opt/smart-proxy/shared/unicorn.pid"
SCRIPTNAME=/etc/init.d/$NAME
RUNUSER=puppet-deployer



case "$1" in
    start)

        export RBENV_ROOT=/usr/local/rbenv
        export PATH="$RBENV_ROOT/bin:$PATH"
        eval "$(rbenv init -)"

        printf "%-50s" "Starting $NAME..."
        sudo su - $RUNUSER
        `$DAEMON $DAEMONOPTS`
        PID=`cat $PIDFILE`
        #echo "Saving PID" $PID " to " $PIDFILE
        if [ -z $PID ]; then
            printf "%s\n" "Fail"
        else
            echo $PID > $PIDFILE
            printf "%s\n" "Ok"
        fi
        ;;
    status)
        printf "%-50s" "Checking $NAME..."
        if [ -f $PIDFILE ]; then
            PID=`cat $PIDFILE`
            if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
                printf "%s\n" "Process dead but pidfile exists"
            else
                echo "Running"
            fi
        else
            printf "%s\n" "Service not running"
        fi
        ;;
    stop)
        printf "%-50s" "Stopping $NAME"
        cd $DAEMON_PATH
        if [ -f $PIDFILE ]; then
            PID=`cat $PIDFILE`
            kill -QUIT $PID
            printf "%s\n" "Ok"
            rm -f $PIDFILE
        else
            printf "%s\n" "pidfile not found"
        fi
        ;;

    restart)
        $0 stop
        $0 start
        ;;

    *)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
