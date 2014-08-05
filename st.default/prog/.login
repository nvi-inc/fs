#
if (! { (echo $PATH |fgrep /usr/local/bin >/dev/null) } ) then
  setenv PATH /usr/local/bin:${PATH}
endif
if (! { (echo $PATH |fgrep /sbin >/dev/null) } ) then
  setenv PATH /sbin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr/sbin >/dev/null) } ) then
  setenv PATH /usr/sbin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr/local/sbin >/dev/null) } ) then
  setenv PATH /usr/local/sbin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr2/oper/bin >/dev/null) } ) then
  setenv PATH /usr2/oper/bin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr2/prog/bin >/dev/null) } ) then
  setenv PATH /usr2/prog/bin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr2/fs/bin >/dev/null) } ) then
  setenv PATH /usr2/fs/bin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr2/st/bin >/dev/null) } ) then
  setenv PATH /usr2/st/bin:${PATH}
endif
if (! { (echo $PATH |fgrep /usr/bin/X11 >/dev/null) } ) then
  setenv PATH ${PATH}:/usr/bin/X11
endif
if (! { (echo $PATH |fgrep /usr/games >/dev/null) } ) then
  setenv PATH ${PATH}:/usr/games
endif
if (! { (echo $PATH |fgrep . >/dev/null) } ) then
  setenv PATH ${PATH}:.
endif
#
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
#check for mail on login
test ! -f /var/mail/prog || from
#setenv FS_CHECK_NTP
#setenv FS_SERIAL_CLOCAL 1
#
