define  kill          00000000000x
sy=brk aquir
sy=brk fivpt
sy=brk onoff
log=station
enddef
define  sband         00000000000
device=i2
fivept
enddef
define  prep          00000000000x
wx
xyoff=0d,0d
!+2s
track
sy=run aquir &
enddef
define  presun        00000000000
ifd=+18,+23
step=1
onoff=2,4,i1,i2,60,6
prep
enddef
define  postsun       00000000000
onoff=2,4,i1,i2,60,3
step=.4
ifd=-18,-23
postp
enddef
define  premoon       00000000000
ifd=+7,+7
step=1
onoff=2,4,i1,i2,60,10
prep
enddef
define  postmoon      00000000000x
onoff=2,4,i1,i2,60,3
step=.4
ifd=-7,-7
postp
enddef
define  postp         00000000000x
sy=run aquir &
enddef
define  termp         00000000000x
sy=run aquir &
enddef
define  initp         00000000000
setup
caloff
caltemps
beam1=
beam2=
beam3=
fivept=xyns,-2,9,.4,1,i1
onoff=2,4,i1,v9,60,3
check=
sy=run aquir &
enddef
define  acquire       00000000000x
sy=aquir /usr2/control/ctlpo.ctl &
log=point
enddef
define  xband         00000000000x
device=i1
fivept
enddef
define  calonfp       00000000000
calon
sy=run fivpt &
enddef
define  calofffp      00000000000x
caloff
sy=run fivpt &
enddef
define  caloffnf      00000000000
caloff
sy=run onoff &
enddef
define  calonnf       00000000000x
calon
sy=run onoff &
enddef
define  axis          00000000000x
fivept=$,*,*,*,*,*
enddef
define  reps          00000000000x
fivept=*,$,*,*,*,*
enddef
define  points        00000000000x
fivept=*,*,$,*,*,*
enddef
define  step          00000000000x
fivept=*,*,*,$,*,*
enddef
define  intp          00000000000x
fivept=*,*,*,*,$,*
enddef
define  device        00000000000x
fivept=*,*,*,*,*,$
enddef
define  sun           00000000000
source=sun
flux1=disk,2500000,0.52d
flux2=disk,0400000,0.52d
flux3=disk,2500000,0.52d
enddef
define  moon          00000000000x
source=moon
flux1=disk,31000,0.52d
flux2=disk,02250,0.52d
flux3=disk,31000,0.52d
enddef
define  cygnusa       00000000000x
source=cygnus-a,195744.4,403546,1950.
flux1=twopoints,190,1m55s
flux2=twopoints,966,1m55s
flux3=twopoints,190,1m55s
enddef
define  casa          00000000000
source=cas-a,232109.,583230,1950.
"flux 1992.0 from dbs table a1.1
"size from        dbs appendix 2
flux1=disk,500,4m
flux2=disk,1304,4m
flux3=disk,500,4m
enddef
define  3c84          00000000000x
source=3c84,031629.54,411951.7,1950.0
enddef
define  3c454d3       00000000000x
source=3c454.3,225129.53,+155254.2,1950.0
enddef
define  taurusa       00000000000x
source=taurus-a,053131,215900,1950.0
"size from dbs appendix 2
flux1=gaussian,552,4.2m,2.6m
flux2=gaussian,815,4.2m,2.6m
flux3=gaussian,552,4.2m,2.6m
enddef
define  oriona        92128144624x
source=orion-a,053249.,-052515,1950.0
flux1=gaussian,340,4m
flux2=gaussian,440,4m
flux3=gaussian,340,4m
enddef
define  virgoa        00000000000x
source=virgo-a,122817.57,124002.0,1950.
"total flux from dbs memo appendix 1
"size of core and halo and split of flux from dbs 880901
flux1=gaussian,044.75,40s,20s,01.25,10m,10m
flux2=gaussian,114,40s,20s,27,10m,10m
flux3=gaussian,044.75,40s,20s,01.25,10m,10m
enddef
define  3c273b        00000000000x
source=3c273b,122633.25,021943.5,1950.
enddef
define  1921m293      00000000000x
source=1921-293,192142.18,-292024.9,1950.0
enddef
define  3c345         00000000000x
source=3c345,164117.64,395411.0,1950.0
enddef
define  3c353         00000000000x
source=3c353,171753.3,-005550.,1950.0
flux1=gaussian,13.6,2m30s
flux2=gaussian,39.9,2m30s
flux3=gaussian,13.6,2m30s
enddef
define  2134p004      00000000000x
source=2134+004,213405.23,002825.0,1950.
enddef
define  3c279         00000000000x
source=3c279,125335.83,-053107.9,1950.
enddef
define  3c123         00000000000x
source=3c123,043355.2,293414.,1950.
flux1=gaussian,10.1,20s
flux2=gaussian,32.9,20s
flux3=gaussian,10.1,20s
enddef
define  3c147         00000000000x
source=3c147,053843.52,+494942.2,1950.
flux1=gaussian,04.9,1s
flux2=gaussian,15.6,1s
flux3=gaussian,04.9,1s
enddef
define  3c161         00000000000x
source=3c161,062443.2,-055112.,1950.
flux1=gaussian,04.0,3s
flux2=gaussian,13.1,3s
flux3=gaussian,04.0,3s
enddef
define  3c218         00000000000x
source=3c218,091541.2,-115305.,1950.
flux1=gaussian,08.4,3m20s
flux2=gaussian,27.7,3m20s
flux3=gaussian,08.4,3m20s
enddef
define  3c286         00000000000x
source=3c286,132849.66,+304558.7,1950.
flux1=gaussian,05.2,1s
flux2=gaussian,11.6,1s
flux3=gaussian,05.2,1s
enddef
define  3c295         00000000000x
source=3c295,140933.5,+522613.,1950.
flux1=gaussian,03.4,4s
flux2=gaussian,14.4,4s
flux3=gaussian,03.4,4s
enddef
define  3c348         00000000000x
source=3c348,164840.0,+050435.,1950.
flux1=gaussian,06.8,1m55s
flux2=gaussian,27.0,1m55s
flux3=gaussian,06.8,1m55s
enddef
define  3c380         00000000000x
source=3c380,182813.47,+484241.0,1950.
flux1=gaussian,05.2,1s
flux2=gaussian,11.0,1s
flux3=gaussian,05.2,1s
enddef
define  3c391         00000000000x
source=3c391,184648.5,-005858.,1950.
flux1=gaussian,07.5,4.5m
flux2=gaussian,16.0,4.5m
flux3=gaussian,07.5,4.5m
enddef
define  0521m365      00000000000
source=0521m365,052113.2,-363019.,1950.
flux1=gaussian,05.5,15s
flux2=gaussian,13.5,15s
flux3=gaussian,05.5,15s
enddef
define  0552p398      00000000000x
source=0552+398,055201.4,394822,1950.0
enddef
define  oj287         00000000000x
source=oj287,085157.2,201759,1950.0
enddef
