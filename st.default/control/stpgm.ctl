* Put site-specific programs here that should
* be started by the Field System. 
* antcn should not be here. 
erchk x xterm -name erchk -e erchk &
mont2 x xterm -name monit2 -e monit2 &
scnch x xterm -name scnch  -e 'fsclient -n -w -s | grep /!\*scan_check..' &
