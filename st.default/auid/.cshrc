# Set aliases
alias a alias
a una	unalias
a cls	'clear'
a cd 	'cd \!*;set prompt="`hostname`:`pwd`/:> "'
a h	history
a lo	logout
a lower	'tr "[A-Z]" "[a-z]"'
a lsf	'ls -CF'
a ll	'ls -l'
a lt	'ls -lt \!*|less'
a last	'ls -lt \!*|head'
a pu	'pushd \!*;set prompt="`hostname`:`pwd`/:> "'
a po	'popd \!*;set prompt="`hostname`:`pwd`/:> "'
a d	dirs
a j	jobs
a rm	'rm -i'
a mv	'mv -i'
a cp	'cp -i'
a rl	'source ~/.login'
a rc	'source ~/.cshrc'
a rlxr	'xrdb -merge ~/.Xresources'
a psall 'ps aux | egrep -v "^bin|^root"'
set noclobber
cd .
a dj    'date -u +"%a %Y.%j.%T %Z (%b %e)"'
a lj    'ls -l --time-style=+"%Y.%j.%H:%M:%S"'
