define  ifdas         00000000000
ifdab=0,0,nor,nor
ifdcd=0,0,nor,nor
lo=8080.00,2020.00
upconv=479.9,479.9
enddef
define  as4c2         00000000000
form=c,8.000
!*
bbcas4
ifdas
!*+8s
enddef
define  as4c1         00000000000
form=c,8.000
!*
bbcas4
ifdas
!*+8s
enddef
define  as4a1         00000000000
form=a,8.000
!*
bbcas4
ifdas
!*+8s
enddef
define  as2c2         00000000000
form=c,4.000
!*
bbcas2
ifdas
!*+8s
enddef
define  as2c1         00000000000
form=c,4.000
!*
bbcas2
ifdas
!*+8s
enddef
define  as2a1         00000000000
form=a,4.000
!*
bbcas2
ifdas
!*+8s
enddef
define  bbcas4        00000000000
bbc01=610.89,a,4.0,4.0
bbc02=620.89,a,4.0,4.0
bbc03=650.89,a,4.0,4.0
bbc04=700.89,a,4.0,4.0
bbc05=820.89,a,4.0,4.0
bbc06=940.89,a,4.0,4.0
bbc07=950.89,a,4.0,4.0
bbc08=970.89,a,4.0,4.0
bbc09=680.89,b,4.0,4.0
bbc10=690.89,b,4.0,4.0
bbc11=710.89,b,4.0,4.0
bbc12=770.89,b,4.0,4.0
bbc13=800.89,b,4.0,4.0
bbc14=805.89,b,4.0,4.0
enddef
define  bbcas2        00000000000
bbc01=610.89,a,2.0,2.0
bbc02=620.89,a,2.0,2.0
bbc03=650.89,a,2.0,2.0
bbc04=700.89,a,2.0,2.0
bbc05=820.89,a,2.0,2.0
bbc06=940.89,a,2.0,2.0
bbc07=950.89,a,2.0,2.0
bbc08=970.89,a,2.0,2.0
bbc09=680.89,b,2.0,2.0
bbc10=690.89,b,2.0,2.0
bbc11=710.89,b,2.0,2.0
bbc12=770.89,b,2.0,2.0
bbc13=800.89,b,2.0,2.0
bbc14=805.89,b,2.0,2.0
enddef
define  wb4a1         00000000000
form=a,8.000
!*
bbcwb4
ifdwb
!*+8s
enddef
define  wb2a1         00000000000
form=a,4.000
!*
bbcwb2
ifdwb
!*+8s
enddef
define  rxmon         00000000000
rx=lo,*,*,*,*,*,*
rx
rx=dcal,*,*,*,*,*,*
rx
rx=lo5mhz,*,*,*,*,*,*
rx
rx=pres,*,*,*,*,*,*
rx
rx=20k,*,*,*,*,*,*
rx
rx=70k,*,*,*,*,*,*
rx
enddef
define  rxall         00000000000
rx=00,*,*,*,*,*,*
rx
rx=01,*,*,*,*,*,*
rx
rx=02,*,*,*,*,*,*
rx
rx=03,*,*,*,*,*,*
rx
rx=04,*,*,*,*,*,*
rx
rx=05,*,*,*,*,*,*
rx
rx=06,*,*,*,*,*,*
rx
rx=07,*,*,*,*,*,*
rx
rx=08,*,*,*,*,*,*
rx
rx=09,*,*,*,*,*,*
rx
rx=0a,*,*,*,*,*,*
rx
rx=0b,*,*,*,*,*,*
rx
rx=0c,*,*,*,*,*,*
rx
rx=0d,*,*,*,*,*,*
rx
rx=0e,*,*,*,*,*,*
rx
rx=0f,*,*,*,*,*,*
rx
rx=10,*,*,*,*,*,*
rx
rx=11,*,*,*,*,*,*
rx
rx=12,*,*,*,*,*,*
rx
rx=13,*,*,*,*,*,*
rx
rx=14,*,*,*,*,*,*
rx
rx=15,*,*,*,*,*,*
rx
rx=16,*,*,*,*,*,*
rx
rx=17,*,*,*,*,*,*
rx
rx=18,*,*,*,*,*,*
rx
rx=19,*,*,*,*,*,*
rx
rx=1a,*,*,*,*,*,*
rx
rx=1b,*,*,*,*,*,*
rx
rx=1c,*,*,*,*,*,*
rx
rx=1d,*,*,*,*,*,*
rx
rx=1e,*,*,*,*,*,*
rx
enddef
define  bbcagc        00000000000
bbc01=*,*,*,*,*,agc
bbc02=*,*,*,*,*,agc
bbc03=*,*,*,*,*,agc
bbc04=*,*,*,*,*,agc
bbc05=*,*,*,*,*,agc
bbc06=*,*,*,*,*,agc
bbc07=*,*,*,*,*,agc
bbc08=*,*,*,*,*,agc
bbc09=*,*,*,*,*,agc
bbc10=*,*,*,*,*,agc
bbc11=*,*,*,*,*,agc
bbc12=*,*,*,*,*,agc
bbc13=*,*,*,*,*,agc
bbc14=*,*,*,*,*,agc
enddef
define  bbcman        00000000000
bbc01=*,*,*,*,*,man
bbc02=*,*,*,*,*,man
bbc03=*,*,*,*,*,man
bbc04=*,*,*,*,*,man
bbc05=*,*,*,*,*,man
bbc06=*,*,*,*,*,man
bbc07=*,*,*,*,*,man
bbc08=*,*,*,*,*,man
bbc09=*,*,*,*,*,man
bbc10=*,*,*,*,*,man
bbc11=*,*,*,*,*,man
bbc12=*,*,*,*,*,man
bbc13=*,*,*,*,*,man
bbc14=*,*,*,*,*,man
enddef
define  bread         00000000000
bbc01
bbc02
bbc03
bbc04
bbc05
bbc06
bbc07
bbc08
bbc09
bbc10
bbc11
bbc12
bbc13
bbc14
enddef
define  bbcsx2        00000000000
bbc01=610.89,a,2.0,2.0
bbc02=620.89,a,2.0,2.0
bbc03=650.89,a,2.0,2.0
bbc04=710.89,a,2.0,2.0
bbc05=820.89,a,2.0,2.0
bbc06=900.89,a,2.0,2.0
bbc07=950.89,a,2.0,2.0
bbc08=970.89,a,2.0,2.0
bbc09=677.89,b,2.0,2.0
bbc10=682.89,b,2.0,2.0
bbc11=697.89,b,2.0,2.0
bbc12=727.89,b,2.0,2.0
bbc13=752.89,b,2.0,2.0
bbc14=762.89,b,2.0,2.0
enddef
define  bbcsx4        00000000000
bbc01=610.89,a,4.0,4.0
bbc02=620.89,a,4.0,4.0
bbc03=650.89,a,4.0,4.0
bbc04=710.89,a,4.0,4.0
bbc05=820.89,a,4.0,4.0
bbc06=900.89,a,4.0,4.0
bbc07=950.89,a,4.0,4.0
bbc08=970.89,a,4.0,4.0
bbc09=677.89,b,4.0,4.0
bbc10=682.89,b,4.0,4.0
bbc11=697.89,b,4.0,4.0
bbc12=727.89,b,4.0,4.0
bbc13=752.89,b,4.0,4.0
bbc14=762.89,b,4.0,4.0
enddef
define  bbcwb2        00000000000
bbc01=612.89,a,2.0,2.0
bbc02=652.89,a,2.0,2.0
bbc03=752.89,a,2.0,2.0
bbc04=912.89,a,2.0,2.0
bbc05=652.99,c,2.0,2.0
bbc06=772.99,c,2.0,2.0
bbc07=832.99,c,2.0,2.0
bbc08=852.99,c,2.0,2.0
bbc09=680.89,b,2.0,2.0
bbc10=690.89,b,2.0,2.0
bbc11=710.89,b,2.0,2.0
bbc12=765.89,b,2.0,2.0
bbc13=800.89,b,2.0,2.0
bbc14=805.89,b,2.0,2.0
enddef
define  bbcwb4        00000000000
bbc01=612.89,a,4.0,4.0
bbc02=652.89,a,4.0,4.0
bbc03=752.89,a,4.0,4.0
bbc04=912.89,a,4.0,4.0
bbc05=652.99,c,4.0,4.0
bbc06=772.99,c,4.0,4.0
bbc07=832.99,c,4.0,4.0
bbc08=852.99,c,4.0,4.0
bbc09=680.89,b,4.0,4.0
bbc10=690.89,b,4.0,4.0
bbc11=710.89,b,4.0,4.0
bbc12=765.89,b,4.0,4.0
bbc13=800.89,b,4.0,4.0
bbc14=805.89,b,4.0,4.0
enddef
define  caloff        00000000000
rx=*,*,*,*,*,*,off
enddef
define  calon         00000000000
rx=*,*,*,*,*,*,on
enddef
define  caltemps      00000000000
caltempa=20.8
caltempb=21.4
caltempc=20.8
enddef
define  check2a1      00000000000
check2c1
enddef
define  check2a2      00000000000
check2c2
enddef
define  check2c1      00000000000
enddef
define  check2c2      00000000000
enddef
define  dat           00000000000
bbcsx2
ifdsx
form=c,4
enddef
define  dqaeven       00000000000
enddef
define  dqaodd        00000000000
enddef
define  fastf         00000000000
ff
!+$
et
enddef
define  fastr         00000000000
rw
!+$
et
enddef
define  ifdsx         00000000000
ifdab=0,0,nor,nor
ifdcd=0,0,nor,nor
lo=8080.00,2020.00
upconv=479.9,479.9
enddef
define  ifdwb         00000000000
ifdab=0,0,nor,nor
ifdcd=0,0,nor,nor
lo=8080.00,2020.00,8080.0
upconv=479.9,479.9,0
enddef
define  initi         00000000000
"welcome to the pc field system
vlbainit
sy=run setcl &
enddef
define  midob         00000000000
tpi=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpi=9u,10u,11u,12u,13u,14u,ifb
bbcagc
caltemps
tsys1=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tsys2=9u,10u,11u,12u,13u,14u,ifb
onsource
wx
cable
ifdab
ifdcd
bbc02
bbc06
bbc11
sy=run setcl &
enddef
define  midtp         00000000000
bbcman
ifdab=20,20,*,*
ifdcd=20,20,*,*
!+2s
tpzero=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpzero=9u,10u,11u,12u,13u,14u,ifb
bbcagc
ifdab=0,0,*,*
ifdcd=0,0,*,*
rxmon
enddef
define  min15         00000000000
rxall
wx
cable
sxcts
enddef
define  overnite      00000000000
log=overnite
setup
check=*,-tp
min15@!,15m
rxmon@!+2m30s,5m
enddef
define  postob        00000000000
enddef
define  precond       00000000000
schedule=prepass,#1
enddef
define  preob         00000000000
onsource
bbcman
calon
!+2s
tpical=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpical=9u,10u,11u,12u,13u,14u,ifb
caloff
enddef
define  prepass       00000000000
enddef
define  ready         00000000000
sxcts
rxmon
newtape
loader
label
check=*,tp
enddef
define  loader        00000000000
rw
!+20s
et
tape=reset
enddef
define  rxx           00000000000
rx=$,*,*,*,*,*,*
enddef
define  setup         00000000000
dat
enddef
define  sfastf        00000000000
sff
!+$
et
enddef
define  sfastr        00000000000
srw
!+$
et
enddef
define  sx2a1         00000000000
form=a,4.000
!*
bbcsx2
ifdsx
!*+8s
enddef
define  sx2c1         00000000000
form=c,4.000
!*
bbcsx2
ifdsx
!*+8s
enddef
define  sx2c2         00000000000
form=c,4.000
!*
bbcsx2
ifdsx
!*+8s
enddef
define  sx4a1         00000000000
form=a,8.000
!*
bbcsx4
ifdsx
!*+8s
enddef
define  sx4c1         00000000000
form=c,8.000
!*
bbcsx4
ifdsx
!*+8s
enddef
define  sx4c2         00000000000
form=c,8.000
!*
bbcsx4
ifdsx
!*+8s
enddef
define  sxcts         00000000000
bbcman
tpi=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpi=9u,10u,11u,12u,13u,14u,ifb
ifdab=20,20,*,*
ifdcd=20,20,*,*
!+2s
tpzero=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpzero=9u,10u,11u,12u,13u,14u,ifb
ifdab=0,0,*,*
ifdcd=0,0,*,*
calon
!+2s
tpical=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tpical=9u,10u,11u,12u,13u,14u,ifb
bbcagc
caloff
caltemps
tsys1=1u,2u,3u,4u,5u,6u,7u,8u,ifa,ifc
tsys2=9u,10u,11u,12u,13u,14u,ifb
enddef
define  unlod         00000000000
check=*,-tp
unloader
xdisp=on
"**dismount this tape now**"
wakeup
xdisp=off
enddef
define  unloader      00000000000
rec_mode=16x81-1,0
rec=eject
enddef
define  wb2c1         00000000000
form=c,4.000
!*
bbcwb2
ifdwb
!*+8s
enddef
define  wb2c2         00000000000
form=c,4.000
!*
bbcwb2
ifdwb
!*+8s
enddef
define  wb4c1         00000000000
form=c,8.000
!*
bbcwb4
ifdwb
!*+8s
enddef
define  wb4c2         00000000000
form=c,8.000
!*
bbcwb4
ifdwb
!*+8s
enddef
define  vlbainit      00000000000
bbc01=addr
bbc02=addr
bbc03=addr
bbc04=addr
bbc05=addr
bbc06=addr
bbc07=addr
bbc08=addr
bbc09=addr
bbc10=addr
bbc11=addr
bbc12=addr
bbc13=addr
bbc14=addr
form=addr
ifdab=addr
ifdcd=addr
enddef

