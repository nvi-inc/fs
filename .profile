
# @(#) $Revision: 72.2 $      

# Default user .profile file (/usr/bin/sh initialization).

# Set up the terminal:
	if [ "$TERM" = "" ]
	then
		eval ` tset -s -Q -m ':?hp' `
	else
		eval ` tset -s -Q `
	fi
	stty erase "^H" kill "^U" intr "^C" eof "^D"
	stty hupcl ixon ixoff
	tabs

# Set up the search paths:
	PATH=$PATH:.

# Set up the shell environment:
	set -u
	trap "echo 'logout'" 0

# Set up the shell variables:
	EDITOR=vi
	export EDITOR
