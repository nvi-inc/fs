#!/bin/sh
# if tcsh is the login shell with gdm3 (FSL9, FLS10, and maybe later):
#  change the #!/bin/sh line above to #!/bin/tcsh
#  and source .login instead of .profile in the next line.
source .profile
#set blanking time to 1h5m
xset s 3900 -dpms
#adjusts bell if uncommented
#xset b 100 2500 50
# mask off Scroll Lock
xmodmap -e "clear Mod5"
xsetroot -solid SlateGrey
fvwm &
xterm -C -ls  -name login_sh
