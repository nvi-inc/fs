define  sched_initi   00000000000
enddef
define  sched_end     00000000000
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
define  caloff        00000000000
"turn cal off
"rx=*,*,*,*,*,*,off
enddef
define  calon         00000000000
"turn cal on
"rx=*,*,*,*,*,*,on
enddef
define  caltemps      00000000000
caltempa=x
caltempb=x
caltempc=x
enddef
define  dat           00000000000
bbcsx2
ifdsx
form=c,4
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
lo=
lo=loa,7600.10,usb,rcp,1
lo=lob,1540.10,usb,rcp,1
enddef
define  initi         00000000000
"welcome to the pc field system
vlbas2init
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
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
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
"rxmon
enddef
define  min15         00000000000
"rxall
wx
cable
sxcts
enddef
define  overnite      00000000000
log=overnite
setup
check=*,-tp
min15@!,15m
"rxmon@!+2m30s,5m
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
"rxmon
newtape
loader
label
check=*,tp
enddef
define  loader        00000000000
rw
!+20s
et
!+10s
tape=reset
enddef
define  setup         00000000000
dat
enddef
define  sx2ca         00000000000
form=c,4.000
!*
bbcsx2
ifdsx
!*+8s
enddef
define  sx2cb         00000000000
form=c,4.000
!*
bbcsx2
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
et
rec=eject
enddef
define  vlbas2init    00000000000
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
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000 
"no phase cal control is implemented here
enddef
define  checkcrc      00000000000 
"comment out the following lines if you do _not_ have a mark iii decoder
"decode=a,crc
"decode
enddef
