#
set path = ($path ~/bin ~oper/bin /usr2/st/bin /usr2/fs/bin)
set tty=`tty`
stty echoe kill ^X erase '^?' intr ^C
if($?term == 1) then
else 
	echo -n "Enter TERM: " 
	set term=$<
endif
set history = 50
set savehist = 50
umask 022
set ignoreeof
set noclobber
setenv PAGER "less -i"
setenv EDITOR emacs
#







