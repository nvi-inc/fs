define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
enddef
define  caloff        00000000000
"turn cal off
"rx=*,*,*,*,*,*,off
enddef
define  calon         00000000000
"turn cal on
"rx=*,*,*,*,*,*,on
enddef
define  dat           00000000000
form=reset
vc15=200
vcsx2
vc15=alarm
ifdsx
form=c1,4
form=alarm
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
ifd=x,x,nor,nor
if3=x,out,1,1
if3=alarm
lo=
lo=lo1,8080.00,usb,rcp,1
lo=lo2,2020.00,usb,rcp,1
lo=lo3,8080.00,usb,rcp,1
patch=
patch=lo1,1l,2l,3l,4h
patch=lo2,9l,10l,11l,12h,13h,14h
patch=lo3,5h,6h,7h,8h
enddef
define  initi         00000000000
"welcome to the pc field system
rec=addr
sy=run setcl &
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
vcsx2
form=c1,4.000
form=reset
systracks=
ifdsx
tapeformc
pass=$,same
enable=g0,g2
tape=low
repro=byp,8,20
decode=a,crc
decode
enddef
define  setupb        00000000000
pcalon
vcsx2
form=c2,4.000
form=reset
systracks=
ifdsx
tapeformc
pass=$,same
enable=g1,g3
tape=low
repro=byp,9,21
decode=a,crc
decode
enddef
define  tapeforma     00000000000
tapeform=1,-350,2,  0,3,-295, 4, 55, 5,-240, 6,110
tapeform=7,-185,8,165,9,-130,10,220,11, -75,12,275
enddef
define  tapeformc     00000000000
tapeform=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform=13,  0,14,  0,15, 55,16, 55,17,110,18,110
tapeform=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  unlod         00000000000
!+5s
enable=,
check=*,-tp
tape=off
rec=unload
xdisp=on
"**************dismount this tape now************"
wakeup
xdisp=off
enddef
define  valarm        00000000000
vc01=alarm
vc02=alarm
vc03=alarm
vc04=alarm
vc05=alarm
vc06=alarm
vc07=alarm
vc08=alarm
vc09=alarm
vc10=alarm
vc11=alarm
vc12=alarm
vc13=alarm
vc14=alarm
enddef
define  vcsx2         00000000000
vc01=130.99,2.000
vc02=140.99,2.000
vc03=170.99,2.000
vc04=230.99,2.000
vc05=340.99,2.000
vc06=420.99,2.000
vc07=470.99,2.000
vc08=490.99,2.000
vc09=197.99,2.000
vc10=202.99,2.000
vc11=217.99,2.000
vc12=247.99,2.000
vc13=272.99,2.000
vc14=282.99,2.000
!+1s
valarm
enddef
define  vread         00000000000
vc01
vc02
vc03
vc04
vc05
vc06
vc07
vc08
vc09
vc10
vc11
vc12
vc13
vc14
enddef
define  check135r     000000000000
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
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
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
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
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
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
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
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
define  ready         00000000000
caltsys
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
define  midtp         00000000000
"rxmon
enddef
define  midob         00000000000
onsource
wx
cable
ifd
if3
vc01
vc05
vc09
tpi=formvc,formif
caltemp=formvc,formif
tsys=formvc,formif
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
sy=run setcl &
enddef
define  preob         00000000000
onsource
caltsys
enddef
define  precond       00000000000
schedule=vprepass,#1
enddef
define  precondthin   00000000000
schedule=vprethin,#1
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
"use the cont command when finished.
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
define  rel           00000000000 
rec=release
!+3s
rec=release
enddef
define  overnite      00000000000
log=overnite
setupa=1
check=*,-tp
min15@!,15m
"rxmon@!+2m30s,5m
"pcal=0,60,by,25,0,5,11
"pcal
enddef
define  min15         00000000000
"rxall
wx
"sy=brk pcalr &
!+15s
cable
caltsys
"pcal
enddef
define  caltsys       00000000000
tpi=formvc,formif
ifd=max,max,*,*
if3=max,*,*,*,*,*
!+2s
tpzero=formvc,formif
ifd=old,old,*,*
if3=old,*,*,*,*,*
calon
!+2s
tpical=formvc,formif
tpdiff=formvc,formif
caloff
caltemp=formvc,formif
tsys=formvc,formif
enddef
