#Most login shell commands go here in ~/.profile
#bash specifc login shell commands go in ~/.bashrc_profile
#Per shell, not just login shell, commands go in ~/.bashrc
#
#export GOPATH=~/go
#if ! (echo $PATH | fgrep $GOPATH/bin >/dev/null); then 
# PATH=$GOPATH/bin:${PATH}
#fi
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
#if ! (echo $PATH | fgrep /usr2/oper/bin >/dev/null); then 
# PATH=/usr2/oper/bin:${PATH}
#fi
if ! (echo $PATH | fgrep /usr2/prog/bin >/dev/null); then 
 PATH=/usr2/prog/bin:${PATH}
fi
#if ! (echo $PATH | fgrep /usr2/fs/bin >/dev/null); then 
# PATH=/usr2/fs/bin:${PATH}
#fi
#if ! (echo $PATH | fgrep /usr2/st/bin >/dev/null); then 
# PATH=/usr2/st/bin:${PATH}
#fi
if ! (echo $PATH | fgrep /usr/bin/X11 >/dev/null); then 
 PATH=${PATH}:/usr/bin/X11
fi
if ! (echo $PATH | fgrep /usr/games >/dev/null); then 
 PATH=${PATH}:/usr/games
fi
export EDITOR=vim
export LESS=-XR
export FC=f95
#export FS_CHECK_NTP=
export FS_SERIAL_CLOCAL=1
#export FS_TINFO_LIB=1
#
