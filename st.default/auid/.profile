# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
#
if ! (echo $PATH | fgrep /usr/local/bin >/dev/null); then 
 PATH=/usr/local/bin:${PATH}
fi
if ! (echo $PATH | fgrep /sbin >/dev/null); then 
 PATH=/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/sbin >/dev/null); then 
 PATH=/usr/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/local/sbin >/dev/null); then 
 PATH=/usr/local/sbin:${PATH}
fi
if ! (echo $PATH | fgrep /usr/bin/X11 >/dev/null); then 
 PATH=${PATH}:/usr/bin/X11
fi
if ! (echo $PATH | fgrep /usr/games >/dev/null); then 
 PATH=${PATH}:/usr/games
fi
#
export EDITOR=vim
export LESS=-XR
