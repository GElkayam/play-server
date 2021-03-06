#!/bin/bash
#
# An init.d script for running a Node.js process as a service using Forever as
# the process monitor. For more configuration options associated with Forever,
# see: https://github.com/nodejitsu/forever


#
# play-server              This shell script takes care of starting and stopping a Kaltura play-server Service
#
# chkconfig: 2345 13 87
# description: Kaltura play-server

### BEGIN INIT INFO
# Provides:          kaltura-play-server
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Start/stop Kaltura play-server
# Description:       Control the Kaltura play-server.
### END INIT INFO
 
NAME="play_server"
PLAY_SERVER_PREFIX="@PLAY_SERVER_BASE_DIR@"
NODE_PATH="$PLAY_SERVER_PREFIX/node_modules"
APPLICATION_PATH="$PLAY_SERVER_PREFIX/main.js"
PIDFILE="@PID_DIR@/play_server.pid"
LOGFILE="@LOG_DIR@/play-server.log"
MIN_UPTIME="5000"
SPIN_SLEEP_TIME="2000"
export PATH=$PATH:$NODE_PATH/forever/bin

loadNvm() {
    # This loads nvm
    cd $PLAY_SERVER_PREFIX
    NVM_DIR="/root/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ] ; then
        source "$NVM_DIR/nvm.sh"
        if [ -s .nvmrc ] ; then
            nvm use || nvm install
        else
            echo "no .nvmrc in $PWD , Exiting"
            exit 1
        fi
    else
        echo "nvm not found in $NVM_DIR, this is a must, Exiting!"
        exit 1
    fi
}


start() {
    loadNvm
    if [ -f $PIDFILE ] ; then
       echo "Server Already Running..."
       RETVAL=1
    fi
    echo "Starting $NAME"
    forever \
      --pidFile $PIDFILE \
      -a \
      -l $LOGFILE \
      --minUptime $MIN_UPTIME \
      --spinSleepTime $SPIN_SLEEP_TIME \
      start $APPLICATION_PATH 2>&1 > /dev/null &
    RETVAL=$?
}
 
stop() {
    loadNvm
    if [ -f $PIDFILE ]; then
        echo "Shutting down $NAME"
        # Tell Forever to stop the process.
        forever stop $APPLICATION_PATH 2>&1 > /dev/null
        # Get rid of the pidfile, since Forever won't do that.
        rm -f $PIDFILE
        RETVAL=$?
    else
        echo "$NAME is not running."
        RETVAL=0
    fi
}
 
restart() {
    if [ -f $PIDFILE ]; then
        echo "Restarting  $NAME"
        # Tell Forever to restart the process.
        forever restart $APPLICATION_PATH 2>&1 > /dev/null
        RETVAL=$?
    else
	# if PID does not exsists start the server
	start
        RETVAL=0
    fi
}
 
status() {
    echo `forever list` | grep -q "$APPLICATION_PATH"
    if [ "$?" -eq "0" ]; then
        echo "$NAME is running."
        RETVAL=0
    else
        echo "$NAME is not running."
        RETVAL=3
    fi
}

logRotated() {
        if [ -f $PIDFILE ]; then
                echo "Notify log rotate for $NAME."
                kill -USR1 `cat $PIDFILE`
                RETVAL=1
        else
                echo "$NAME is not running."
                RETVAL=0
        fi
}
 
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    logRotated)
        logRotated
        ;;

    *)
        echo "Usage: {start|stop|status|restart|logRotated}"
        exit 1
        ;;
esac
exit $RETVAL
