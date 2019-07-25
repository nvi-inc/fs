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
a rl	'source ~/.login'
a rc	'source ~/.cshrc'
a rlxr	'xrdb -merge ~/.Xresources'
a psall 'ps -aux | egrep -v "^bin|^root"'
cd .
