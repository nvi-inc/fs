
# @(#) $Revision: 72.3 $     


# Default user .login file ( /usr/bin/csh initialization )

# Set up the default search paths:
set path=( $path )

#set up the terminal
#eval `tset -s -Q -m ':?hp' `
#stty erase "^H" kill "^U" intr "^C" eof "^D" susp "^Z" hupcl ixon ixoff tostop
#tabs	
if($?VUE == 0) then
set tty=`tty`
if($tty =~ /dev/console) then
	set term=hd
else if($?term == 1) then
	if ($term =~ xterm || $term =~ con* ) then
		set term=vt100
	endif
else if($tty =~ /dev/tty0p? && $tty !~ /dev/tty0p2) then
	set term=hp
else 
	echo -n 'Enter TERM: '
	set term=$<
endif
if ($term =~ vt100) then
	stty echoe kill ^X erase "^?" susp ^Z dsusp ^Y intr ^C
else
	stty echoe kill ^X erase ^H susp ^Z dsusp ^Y intr ^C
	stty echoe kill ^X erase "^?" susp ^Z dsusp ^Y intr ^C
endif
endif

# Set up shell environment:
set noclobber
set history=20
