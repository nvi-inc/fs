#! /bin/sh
#
# tacdclient	TAC client for logging GPS information.
#
#		Modified for Debian GNU/Linux
#
# Version:	@(#)metc  1.0.0  23-Jul-2003  rgonzale@gemini.gsfc.nasa.gov
#
DAEMON=/usr2/st/tacdclient/tacdclient
NAME=tacdclient
DESC="TACD Client"
LFILE=/usr2/st/tacdclient/tacdlog.ctl || exit 0

test -x $DAEMON || exit 0
test -f $LFILE || exit 0

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        start-stop-daemon --start --quiet --exec $DAEMON $LFILE &
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
        start-stop-daemon --start --quiet --exec $DAEMON $LFILE &
	echo "."
	;;
  *)
        echo "Usage: /etc/init.d/tacdclient.sh {start|stop|restart|force-reload}" >&2
        exit 1
esac

exit 0
