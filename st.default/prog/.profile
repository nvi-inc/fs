if ! (echo $PATH | fgrep /usr2/st/bin >/dev/null); then 
 PATH=${PATH}:/usr2/st/bin
fi
if ! (echo $PATH | fgrep /usr2/fs/bin >/dev/null); then 
 PATH=${PATH}:/usr2/fs/bin
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
EXPORT FC
