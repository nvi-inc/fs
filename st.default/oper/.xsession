#!/bin/sh
# If tcsh is the login shell with gdm (FSL8 and maybe earlier):
#  make sure your environment variables are also set in .profile.
#  .profile uses a different syntax than .login.
# If tcsh is the login shell with gdm3 (FSL9/10/11 and maybe later):
#  change the #!/bin/sh line above to #!/bin/tcsh (for documentation
#  purposes only) and uncomment the next line.
#source .login
#set blanking time to 1h5m
xset s 3900 -dpms
#adjusts bell if uncommented
#xset b 100 2500 50
# mask off Scroll Lock
xmodmap -e "clear Mod5"
xsetroot -solid SlateGrey
fvwm &
xterm -C -name login_sh
