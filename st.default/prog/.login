#
if (! { (echo $PATH |fgrep /usr2/prog/bin >/dev/null) } ) then
  setenv PATH ${PATH}:/usr2/prog/bin
endif
if (! { (echo $PATH |fgrep /usr2/oper/bin >/dev/null) } ) then
  setenv PATH ${PATH}:/usr2/oper/bin
endif
if (! { (echo $PATH |fgrep /usr2/st/bin >/dev/null) } ) then
  setenv PATH ${PATH}:/usr2/st/bin
endif
if (! { (echo $PATH |fgrep /usr2/fs/bin >/dev/null) } ) then
  setenv PATH ${PATH}:/usr2/fs/bin
endif
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
setenv PAGER "less -i"
setenv EDITOR emacs
setenv LESS -X
if (-X fort77) then
 setenv FC fort77
else
 setenv FC f77
endif
#







