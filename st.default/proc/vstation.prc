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
"turn the cal off
"rx=*,*,*,*,*,*,off
enddef
define  calon         00000000000
"turn the cal on
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
define  dqaeven       00000000000
dqa=1
repro=*,4,6,*,*
dqa
repro=*,8,10,*,*
dqa
repro=*,12,14,*,*
dqa
repro=*,16,18,*,*
dqa
repro=*,20,22,*,*
dqa
repro=*,24,26,*,*
dqa
repro=*,28,30,*,*
dqa
enddef
define  dqaodd        00000000000
dqa=1
repro=*,5,7,*,*
dqa
repro=*,9,11,*,*
dqa
repro=*,13,15,*,*
dqa
repro=*,17,19,*,*
dqa
repro=*,21,23,*,*
dqa
repro=*,25,27,*,*
dqa
repro=*,29,31,*,*
dqa
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
vlbainit
vform=c,4
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
bbc01
bbc05
bbc09
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
setupa=1
check=*,-tp
min15@!,15m
"rxmon@!+2m30s,5m
repro=byp,8,14
dqa=1
dqa@!,1m
enddef
define  postob        00000000000
enddef
define  precond       00000000000
schedule=vprepass,#1
enddef
define  precondthin   00000000000
schedule=vprethin,#1
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
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label=... command when finished.
halt
xdisp=off
check=*,-tp
rec=load
!+10s
tape=low,reset
sff
!+5m27s
et
!+9s
wakeup
rec=release
!+3s
rec=release
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the label=... command when finished.
halt
xdisp=off
rec=load
!+10s
srw
!+5m28s
et
!+9s
rec=unload
enddef
define  prepassthin   00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label=... command when finished
halt
xdisp=off
check=*,-tp
rec=load
!+10s
tape=low,reset
sff
!+10m54s
et
!+9s
wakeup
rec=release
!+3s
rec=release
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the label=... command when finished
halt
xdisp=off
rec=load
!+10s
srw
!+10m54s
et
!+9s
rec=unload
enddef
define  ready         00000000000
sxcts
"rxmon
newtape
loader
label
rec
check=*,tp
enddef
define  loader        00000000000
rec=load
!+10s
tape=low,reset
st=for,135,off
!+11s
et
!+3s
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
define  setupa        00000000000
pcalon
tapeformc
pass=$
form=c,4.000
!*
systracks=
bbcsx2
ifdsx
enable=g0,g2
tape=low
repro=byp,8,20
!*+8s
enddef
define  setupb        00000000000
pcalon
tapeformc
pass=$
form=c,4.000
!*
systracks=
bbcsx2
ifdsx
enable=g1,g3
tape=low
repro=byp,9,21
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
define  tapeformc     00000000000
tapeform=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform=13,0,14,0,15,55,16,55,17,110,18,110
tapeform=19,165,20,165,21,220,22,220,23,275,24,275
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
!+5s
enable=,
tape=off
rec=unload
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
rec=addr
ifdab=addr
ifdcd=addr
enddef
define  rel           00000000000 
rec=release
!+3s
rec=release
enddef
define  check135r     000000000000
vform=*,4
parity=,,ab,off
sfastf=18.41s
!+6s
repro=read,4,6
!*
st=rev,135,off
!+3s
parity
!*+45s
et
!+3s
repro=byp,4,6
enddef
define  check135f     00000000000 
vform=*,4
parity=,,ab,off
sfastr=18.41s
!+6s
repro=read,4,6
!*
st=for,135,off
!+3s
parity
!*+45s
et
!+3s
repro=byp,4,6
enddef
define  check80r      00000000000
vform=*,4
parity=,,ab,off
sfastf=10.66s
!+6s
repro=read,4,6
!*
st=rev,80,off
!+2s
parity
!*+44s
et
!+2s
repro=byp,4,6
enddef
define  check80f      00000000000
vform=*,4
parity=,,ab,off
sfastr=10.66s
!+6s
repro=read,4,6
!*
st=for,80,off
!+2s
parity
!*+44s
et
!+2s
repro=byp,4,6
enddef
define  tapeformv     98222124704x
tapeform=  1,-319,  2,  31,  3,-271,  4,  79,  5,-223,  6, 127
tapeform=  7,-175,  8, 175,  9,-127, 10, 223, 11, -79, 12, 271
tapeform= 13, -31, 14, 319
enddef
define  tapeforma     00000000000
tapeform=1,-350,2,  0,3,-295, 4, 55, 5, -240, 6,110
tapeform=7,-185,8,165,9,-130,10,220,11,  -75,12,275
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
