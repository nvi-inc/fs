* Put programs here that can be accessed with 
* "client="  FS client. 
* flags accepted are:
*      a  start attached to the calling client, ie exit with client
*      d  start detached, ie will not exit with client
erchk  a xterm -name ERRORS -title ERRORS -e erchk
fmset  d xterm -name fmset  -title fmset  -e fmset
pfmed  d xterm -name pfmed  -title pfmed  -e pfmed
monit1 a xterm -name monit1 -title monit1 -e monit1
monit2 a xterm -name monit2 -title monit2 -e monit2
monit3 a xterm -name monit3 -title monit3 -e monit3
monit4 a xterm -name monit4 -title monit4 -e monit4
monit5 a xterm -name monit5 -title monit5 -e monit5
monit6 a xterm -name monit6 -title monit6 -e monit6
