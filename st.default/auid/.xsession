#!/bin/sh
source .profile
#set blanking time to 1 hour
xset s 3600
#adjusts bell if uncommented
#xset b 100 2500 50
# mask off Scroll Lock
xmodmap -e "clear Mod5"
xsetroot -solid SlateGrey
fvwm &
xterm -C -ls  -name login_sh
