#! /bin/sh
#
# metserver MET server for gathering weather information.
#
#	    Modified for Debian GNU/Linux
#
# Version:  @(#)metserver  1.0.0  07-Jul-2003  rgonzale@gemini.gsfc.nasa.gov
# Version:  @(#)metserver  1.0.1  04-May-2012  Ed.Himwich@nasa.gov
#
DAEMON=/usr2/st/metserver/metserver
NAME=metserver
DESC="MET Server"
MET=/dev/null
WIND=/dev/null
PORT=50001
REMOTE=local
DEVICE=MET4

test -x $DAEMON || exit 0
test -f $LFILE || exit 0

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        start-stop-daemon --start --quiet --exec $DAEMON $MET $WIND $PORT $REMOTE $DEVICE &
        echo "."
	;;
  stop)
        echo -n "Stopping $DESC: $NAME "
	start-stop-daemon --quiet --stop --exec $DAEMON
	echo "."
        ;;
  restart|force-reload)
        #
        #       If the "reload" option is implemented, move the "force-reload"
        #       option to the "reload" entry above. If not, "force-reload" is
        #       just the same as "restart".
        #
        echo -n "Restarting $DESC: $NAME"
	start-stop-daemon --quiet --stop --exec $DAEMON
	sleep 2
        start-stop-daemon --start --quiet --exec $DAEMON $MET $WIND $PORT $REMOTE $DEVICE &
	echo "."
	;;
  *)
        echo "Usage: /etc/init.d/metserver.sh {start|stop|restart|force-reload}" >&2
        exit 1
esac

exit 0
