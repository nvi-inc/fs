if ! (echo $PATH | fgrep /usr2/st/bin >/dev/null); then
 PATH=${PATH}:/usr2/st/bin
fi
if ! (echo $PATH | fgrep /usr2/fs/bin >/dev/null); then
 PATH=${PATH}:/usr2/fs/bin
fi
EDITOR=vi
export EDITOR
LESS=-X
export LESS
