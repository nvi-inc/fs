#!/bin/sh
source .profile

#set blanking time to 1 hour
xset s 3600
# start some nice programs
xsetroot -solid SlateGrey
fvwm &
xterm -C -ls  -name login_sh -fn 10x20 -geometry 99x24+0+0






