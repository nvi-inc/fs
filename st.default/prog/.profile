if ! (echo $PATH | fgrep /usr/local/bin >/dev/null); then 
 PATH=/usr/local/bin:${PATH}
fi
if ! (echo $PATH | fgrep /sbin >/dev/null); then 
 PATH=/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/sbin >/dev/null); then 
 PATH=/usr/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/local/sbin >/dev/null); then 
 PATH=/usr/local/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr2/oper/bin >/dev/null); then 
 PATH=/usr2/oper/bin:${PATH}
fi
if ! (echo $PATH | fgrep /usr2/prog/bin >/dev/null); then 
 PATH=/usr2/prog/bin:${PATH}
fi
if ! (echo $PATH | fgrep /usr2/fs/bin >/dev/null); then 
 PATH=/usr2/fs/bin:${PATH}
fi
if ! (echo $PATH | fgrep /usr2/st/bin >/dev/null); then 
 PATH=/usr2/st/bin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/bin/X11 >/dev/null); then 
 PATH=${PATH}:/usr/bin/X11
fi
if ! (echo $PATH | fgrep /usr/games >/dev/null); then 
 PATH=${PATH}:/usr/games
fi
if ! (echo $PATH | fgrep . >/dev/null); then 
 PATH=${PATH}:.
fi
EDITOR=emacs
export EDITOR
LESS=-X
export LESS
if [ x`which fort77 2>/dev/null` == x ]; then
# No fort77 command, use f77.
 FC=f77
else
 FC=fort77
fi
export FC
#FS_CHECK_NTP=
#export FS_CHECK_NTP
