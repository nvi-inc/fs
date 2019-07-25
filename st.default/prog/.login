#
set path = ($path ~/bin ~oper/bin /usr2/st/bin /usr2/fs/bin)
set tty=`tty`
stty echoe kill ^X erase ^H intr ^C
if($term == xterm) then
else 
	echo -n "Enter TERM: " 
	set term=$<
endif
set history = 50
set savehist = 50
set autologout = 15
umask 022
set ignoreeof
set noclobber


