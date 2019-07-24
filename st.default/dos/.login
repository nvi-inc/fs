#
set path = (. /bin /usr/bin /usr/ucb ~/bin /usr2/st/bin /usr2/fs/bin)
set tty=`tty`
stty echoe kill ^X erase ^H
if($tty == /dev/console) then
	set term=AT386
else if($tty == /dev/vt01) then
	set term=AT386
else if($tty == /dev/vt02) then
	set term=AT386
else if($term == xterm) then
else 
	echo -n "Enter TERM: " 
	set term=$<
endif
stty intr 
set prompt="`hostname`:`pwd`/:>"
set history = 50
set savehist = 50
set autologout = 15
umask 022
set ignoreeof
set noclobber
setenv TZ 'UT '
setenv MBOX ~/Mail/received
setenv TERM $term
#users
setenv	DISPLAY	unix:0
setenv  DOSPATH /usr/vpix/dosbin
setenv  VPIXCNF $home/vpix/vpix.cnf
set path = ( $path /usr/bin/X11 $DOSPATH)
