#! /bin/sh
#
# metclient	MET client for logging weather information.
#
#		Modified for Debian GNU/Linux
#
# Version:	@(#)metc  1.0.0  07-Jul-2003  rgonzale@gemini.gsfc.nasa.gov
# Version:	@(#)metc  1.0.1  04-May-2012  Ed.Himwich@nasa.gov
#
DAEMON=/usr2/st/metclient/metclient
NAME=metclient
DESC="MET Client"
LFILE=/usr2/st/metclient/metlog.ctl || exit 0
PORT=50001
HOST=localhost

test -x $DAEMON || exit 0
test -f $LFILE || exit 0

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        start-stop-daemon --start --quiet --exec $DAEMON $LFILE $PORT $HOST &
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
        start-stop-daemon --start --quiet --exec $DAEMON $LFILE $PORT $HOST &
	echo "."
	;;
  *)
        echo "Usage: /etc/init.d/metclient.sh {start|stop|restart|force-reload}" >&2
        exit 1
esac

exit 0
