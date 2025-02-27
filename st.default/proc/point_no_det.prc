define  kill          00000000000
sy=brk aquir &
sy=brk fivpt &
sy=brk onoff &
log=station
enddef
define  prep          00000000000
track
sy=rte_go aquir &
enddef
define  presun        00000000000
prep
enddef
define  postsun       00000000000
postp
enddef
define  premoon       00000000000
prep
enddef
define  postmoon      00000000000
postp
enddef
define  postp         00000000000
sy=rte_go aquir &
enddef
define  termp         00000000000
sy=rte_go aquir &
enddef
define  initp         25058203547x
fivept=azel,1,9,.4,1,none,120
onoff=2,1,75,3,,120,none
check=
sy=rte_go aquir &
enddef
define  acquire       00000000000
sy=run aquir /usr2/control/ctlpo_no_det.ctl $ &
log=point_no_det
enddef
define  calonfp       00000000000
sy=rte_go fivpt &
!+1s
sy=rte_go fivpt &
enddef
define  calofffp      00000000000
sy=rte_go fivpt &
!+1s
sy=rte_go fivpt &
enddef
define  caloffnf      00000000000
sy=rte_go onoff &
!+1s
sy=rte_go onoff &
enddef
define  calonnf       00000000000
sy=rte_go onoff &
!+1s
sy=rte_go onoff &
enddef
define  axis          00000000000
fivept=$,*,*,*,*,*
enddef
define  reps          00000000000
fivept=*,$,*,*,*,*
enddef
define  points        00000000000
fivept=*,*,$,*,*,*
enddef
define  step          00000000000
fivept=*,*,*,$,*,*
enddef
define  intp          00000000000
fivept=*,*,*,*,$,*
enddef
define  device        00000000000
fivept=*,*,*,*,*,$
enddef
define  sun           00000000000
source=sun
enddef
define  moon          00000000000
source=moon
enddef
define  cygnusa       00000000000
source=cygnusa,195928.4,+404402.,2000.
enddef
define  casa          00000000000
source=casa,232324.8,+584859.,2000.
enddef
define  3c84          00000000000
source=3c84,031948.16,+413042.1,2000.
enddef
define  3c454d3       00000000000
source=3c454.3,225357.75,+160853.6,2000.
enddef
define  taurusa       00000000000
source=taurusa,053432.,+220058,2000.
enddef
define  oriona        00000000000
source=oriona,053516.,-052322.,2000.
enddef
define  virgoa        00000000000
source=virgoa,123049.42,+122328.0,2000.
enddef
define  3c273b        00000000000
source=3c273b,122906.70,+020308.6,2000.0
enddef
define  1921m293      00000000000
source=1921-293,192451.06,-291430.1,2000.
enddef
define  3c345         00000000000
source=3c345,164258.81,+394837.0,2000.
enddef
define  3c353         00000000000
source=3c353,172028.2,-005848.,2000.
enddef
define  2134p004      00000000000
source=2134+004,213638.59,+004154.2,2000.
enddef
define  3c279         00000000000
source=3c279,125611.17,-054721.5,2000.
enddef
define  3c123         00000000000
source=3c123,043704.17,+294015.1,2000.
enddef
define  3c147         00000000000
source=3c147,054236.14,+495107.2,2000.
enddef
define  3c161         00000000000
source=3c161,062710.10,-055304.8,2000.
enddef
define  3c218         00000000000
source=3c218,091805.7,-120544.,2000.
enddef
define  3c286         00000000000
source=3c286,133108.29,+303033.0,2000.
enddef
define  3c295         00000000000
source=3c295,141120.65,+521209.1,2000.
enddef
define  3c348         00000000000
source=3c348,165108.2,+045933.,2000.
enddef
define  3c380         00000000000
source=3c380,182931.72,+484447.0,2000.
enddef
define  3c391         00000000000
source=3c391,184923.4,-005529.,2000.
enddef
define  0521m365      00000000000
source=0521m365,052257.98,-362730.9,2000.
enddef
define  0552p398      00000000000
source=0552+398,055530.8,+394849.,2000.
enddef
define  oj287         00000000000
source=oj287,085448.9,+200631.,2000.
enddef
define  4c39d25       00000000000
source=4c39.25,092703.0,+390221.,2000.
enddef
