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
setenv EDITOR vim
#
setenv LESS -nR
# 'n' is suppress line numbers,
#     which speeds things up a lot when going to the bottom of a large file
# 'R' is color escape sequences in 'raw' form,
#     particularly for git
#
# other LESS options to consider making the default:
# 'X' is no initialization/de-initialization,
#     keeps output visible after end (you could 'cat' the file instead)
# 'F' is quit if one screen,
#     you might like if you use 'X' so you don't have to quit
#
# All of them:
#setenv LESS -nRXF
#
#check for mail on login
test ! -f /var/mail/oper || from 
#setenv FS_CHECK_NTP
#
