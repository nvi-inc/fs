if ! (echo $PATH | fgrep ~/bin >/dev/null); then 
 PATH=~/bin:${PATH}
fi
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
if ! (echo $PATH | fgrep /usr/bin/X11 >/dev/null); then 
 PATH=${PATH}:/usr/bin/X11
fi
if ! (echo $PATH | fgrep /usr/games >/dev/null); then 
 PATH=${PATH}:/usr/games
fi
#
umask 022
export EDITOR=vim
export LESS=-XR
