* Put programs here that can be accessed with 
* "client="  FS client. 
* flags accepted are:
*      a  start attached to the calling client, ie exit with client
*      d  start detached, ie will not exit with client
erchk  a xterm -name erchk  -e erchk
fmset  d xterm -name fmset  -e fmset
pfmed  d xterm -name pfmed  -e pfmed
monit1 a xterm -name monit1 -e monit1
monit2 a xterm -name monit2 -e monit2
monit3 a xterm -name monit3 -e monit3
monit4 a xterm -name monit4 -e monit4
monit5 a xterm -name monit5 -e monit5
monit6 a xterm -name monit6 -e monit6
scnch  a xterm -name scnch  -e 'fsclient -n -w -s | grep \!scan_check'
xterm  d xterm
monan  a xterm -name monan  -e monan 
mona   a popen 'cd /tmp;rdbe30_mon.py -h 239.0.2.10 -p 20021 -H rdbea 2>&1' -n rdbemona
monb   a popen 'cd /tmp;rdbe30_mon.py -h 239.0.2.20 -p 20022 -H rdbeb 2>&1' -n rdbemonb
monc   a popen 'cd /tmp;rdbe30_mon.py -h 239.0.2.30 -p 20023 -H rdbec 2>&1' -n rdbemonc
mond   a popen 'cd /tmp;rdbe30_mon.py -h 239.0.2.40 -p 20024 -H rdbed 2>&1' -n rdbemond
