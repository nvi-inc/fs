#!/bin/sh
# For FSL11, only bash is supported as the login shell for AUID accounts.
#  That is, 'source .login' is not useful here for AUID accounts in FSL11.
# If tcsh is the login shell for an AUID account with FSL10 (gdm3):
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
xterm -C -ls -name login_sh
