define  acquire       00000000000
sy=run aquir /usr2/control/ctlpo.ctl &
log=point
enddef
define  kill          00000000000
sy=brk aquir &
sy=brk fivpt &
sy=brk onoff &
log=station
enddef
define  sband         00000000000
device=ib
fivept
enddef
define  prep          00000000000
wx
xyoff=0d,0d
!+2s
track
sy=go aquir &
enddef
define  presun        00000000000
ifdab=20,20,*,*
ifdcd=20,20,*,*
step=1
onoff=2,4,ia,ib,60,6
prep
enddef
define  postsun       00000000000
onoff=2,4,ia,ib,60,3
step=.4
ifdab=0,0,*,*
ifdcd=0,0,*,*
postp
enddef
define  premoon       00000000000
ifdab=20,20,*,*
ifdcd=20,20,*,*
step=1
onoff=2,4,ia,ib,60,10
prep
enddef
define  postmoon      00000000000
onoff=2,4,ia,ib,60,3
step=.4
ifdab=0,0,*,*
ifdcd=0,0,*,*
postp
enddef
define  postp         00000000000
sy=go aquir &
enddef
define  termp         00000000000
sy=go aquir &
enddef
define  initp         00000000000
setup
caloff
caltemps
beama=
beamb=
beamc=
fivept=xyns,-2,9,.4,1,ia
onoff=2,4,ia,ib,60,3
check=
sy=go aquir &
enddef
define  xband         00000000000
device=ia
fivept
enddef
define  calonfp       00000000000
calon
sy=go fivpt &
enddef
define  calofffp      00000000000
caloff
sy=go fivpt &
enddef
define  caloffnf      00000000000
caloff
sy=go onoff &
enddef
define  calonnf       00000000000
calon
sy=go onoff &
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
fluxa=disk,2500000,0.52d
fluxb=disk,0400000,0.52d
fluxc=disk,2500000,0.52d
enddef
define  moon          00000000000
source=moon
fluxa=disk,31000,0.52d
fluxb=disk,02250,0.52d
fluxc=disk,31000,0.52d
enddef
define  cygnusa       00000000000
"source=cygnus-a,195744.4,403546,1950.
source=cygnus-a,195928.4,+404402.,2000.
fluxa=twopoints,190,1m55s
fluxb=twopoints,966,1m55s
fluxc=twopoints,190,1m55s
enddef
define  casa          00000000000
"source=cas-a,232109.,583230,1950.
source=cas-a,232324.8,+584859.,2000.
"flux 1998.0 from dbs table a1.1
"size from        dbs appendix 2
flux1=disk,480,4m
flux2=disk,1338,4m
flux3=disk,480,4m
enddef
define  3c84          00000000000
"source=3c84,031629.54,411951.7,1950.0
source=3c84,031948.16,+413042.1,2000.
enddef
define  3c454d3       00000000000
"source=3c454.3,225129.53,+155254.2,1950.0
source=3c454.3,225357.75,+160853.6,2000.
enddef
define  taurusa       00000000000
"source=taurus-a,053131,215900,1950.0
source=taurus-a,053432.,+220058,2000.
"size from dbs appendix 2
fluxa=gaussian,552,4.2m,2.6m
fluxb=gaussian,815,4.2m,2.6m
fluxc=gaussian,552,4.2m,2.6m
enddef
define  oriona        00000000000
"source=orion-a,053249.,-052515,1950.0
source=orion-a,053516.,-052322.,2000.
fluxa=gaussian,340,4m
fluxb=gaussian,440,4m
fluxc=gaussian,340,4m
enddef
define  virgoa        00000000000
"source=virgo-a,122817.57,124002.0,1950.
source=virgo-a,123049.42,+122328.0,2000.
"total flux from dbs memo appendix 1
"size of core and halo and split of flux from dbs 880901
fluxa=gaussian,044.75,40s,20s,01.25,10m,10m
fluxb=gaussian,114,40s,20s,27,10m,10m
fluxc=gaussian,044.75,40s,20s,01.25,10m,10m
enddef
define  3c273b        00000000000
"source=3c273b,122633.25,021943.5,1950.
source=3c273b,122906.70,+020308.6,2000.0
enddef
define  1921m293      00000000000
"source=1921-293,192142.18,-292024.9,1950.0
source=1921-293,192451.06,-291430.1,2000.
enddef
define  3c345         00000000000
"source=3c345,164117.64,395411.0,1950.0
source=3c345,164258.81,+394837.0,2000.
enddef
define  3c353         00000000000
"source=3c353,171753.3,-005550.,1950.0
source=3c353,172028.2,-005848.,2000.
fluxa=gaussian,13.6,2m30s
fluxb=gaussian,39.9,2m30s
fluxc=gaussian,13.6,2m30s
enddef
define  2134p004      00000000000
"source=2134+004,213405.23,002825.0,1950.
source=2134+004,213638.59,+004154.2,2000.
enddef
define  3c279         00000000000
"source=3c279,125335.83,-053107.9,1950.
source=3c279,125611.17,-054721.5,2000.
enddef
define  3c123         00000000000
"source=3c123,043355.2,293414.,1950.
source=3c123,043704.17,+294015.1,2000.
fluxa=gaussian,10.1,20s
fluxb=gaussian,32.9,20s
fluxc=gaussian,10.1,20s
enddef
define  3c147         00000000000
"source=3c147,053843.52,+494942.2,1950.
source=3c147,054236.14,+495107.2,2000.
fluxa=gaussian,04.9,1s
fluxb=gaussian,15.6,1s
fluxc=gaussian,04.9,1s
enddef
define  3c161         00000000000
"source=3c161,062443.2,-055112.,1950.
source=3c161,062710.10,-055304.8,2000.
fluxa=gaussian,04.0,3s
fluxb=gaussian,13.1,3s
fluxc=gaussian,04.0,3s
enddef
define  3c218         00000000000
"source=3c218,091541.2,-115305.,1950.
source=3c218,091805.7,-120544.,2000.
fluxa=gaussian,08.4,3m20s
fluxb=gaussian,27.7,3m20s
fluxc=gaussian,08.4,3m20s
enddef
define  3c286         00000000000
"source=3c286,132849.66,+304558.7,1950.
source=3c286,133108.29,+303033.0,2000.
fluxa=gaussian,05.2,1s
fluxb=gaussian,11.6,1s
fluxc=gaussian,05.2,1s
enddef
define  3c295         00000000000
"source=3c295,140933.5,+522613.,1950.
source=3c295,141120.65,+521209.1,2000.
fluxa=gaussian,03.4,4s
fluxb=gaussian,14.4,4s
fluxc=gaussian,03.4,4s
enddef
define  3c348         00000000000
"source=3c348,164840.0,+050435.,1950.
source=3c348,165108.2,+045933.,2000.
fluxa=gaussian,06.8,1m55s
fluxb=gaussian,27.0,1m55s
fluxc=gaussian,06.8,1m55s
enddef
define  3c380         00000000000
"source=3c380,182813.47,+484241.0,1950.
source=3c380,182931.72,+484447.0,2000.
fluxa=gaussian,05.2,1s
fluxb=gaussian,11.0,1s
fluxc=gaussian,05.2,1s
enddef
define  3c391         00000000000
"source=3c391,184648.5,-005858.,1950.
source=3c391,184923.4,-005529.,2000.
fluxa=gaussian,07.5,4.5m
fluxb=gaussian,16.0,4.5m
fluxc=gaussian,07.5,4.5m
enddef
define  0521m365      00000000000
"source=0521m365,052113.2,-363019.,1950.
source=0521m365,052257.98,-362730.9,2000.
fluxa=gaussian,05.5,15s
fluxb=gaussian,13.5,15s
fluxc=gaussian,05.5,15s
enddef
define  0552p398      00000000000
"source=0552+398,055201.4,394822,1950.0
source=0552+398,055530.8,+394849.,2000.
enddef
define  oj287         00000000000
"source=oj287,085157.2,201759,1950.0
source=oj287,085448.9,+200631.,2000.
enddef
define  4c39d25       00000000000
"source=4c39.25,092355.3,+391524.,1950.0
source=4c39.25,092703.0,+390221.,2000.
enddef
