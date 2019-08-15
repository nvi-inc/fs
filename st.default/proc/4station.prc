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
if3=20,out,1,1
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
sy=run setcl &
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
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
sy=run setcl &
enddef
define  midtp         00000000000
"rxmon
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
define  overnite      00000000000
log=overnite
setupa=1
check=*,-tp
min15@!,15m
"rxmon@!+2m30s,5m
"pcal=0,60,by,25,0,5,11
"pcal
enddef
define  postob        00000000000
form
enddef
define  precond       00000000000
schedule=prepass,#1
enddef
define  precondthin   00000000000
schedule=prethin,#1
enddef
define  preob         00000000000
onsource
caltsys
enddef
define  prepass       00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label=... command when finished.
halt
xdisp=off
check=*,-tp,-hd
tape=low
sff
!+5m27s
et
!+9s
wakeup
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the cont command when finished.
halt
xdisp=off
srw
!+5m28s
et
!+9s
enddef
define  prepassthin   00000000000
wakeup
xdisp=on
" mount the next tape without cleaning the tape drive.
" use the label=... command when finished.
halt
xdisp=off
check=*,-tp,-hd
tape=low
sff
!+10m54s
et
!+9s
wakeup
xdisp=on
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the cont command when finished.
halt
xdisp=off
srw
!+10m54s
et
!+9s
enddef
define  ready         00000000000
caltsys
"rxmon
newtape
loader
label
check=*,tp
enddef
define  loader        00000000000
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
vcsx2
form=c1,4.000
ifdsx
tapeformc
pass=$,same
enable=s1
tape=low
repro=byp,8,20
st=for,0,on
checkcrc
enddef
define  setupb        00000000000
pcalon
vcsx2
form=c2,4.000
ifdsx
tapeformc
pass=$,same
enable=s1
tape=low
repro=byp,9,21
st=for,0,on
checkcrc
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
check=*,-tp
unloader
xdisp=on
"**************dismount this tape now************"
wakeup
xdisp=off
enddef
define  unloader      00000000000
!+5s
enable=,
tape=off
st=rev,80,off
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
define  check80r      00000000000x
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
parity=,,ab,on
sfastf=13.61s
!+6s
repro=raw,5,7
!*
st=rev,80,off
!+3s
parity
!*+53s
et
!+2s
repro=byp,5,7
enddef
define  check80f      00000000000
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
parity=,,ab,on
sfastr=13.61s
!+6s
repro=raw,6,8
!*
st=for,80,off
!+3s
parity
!*+53s
et
!+2s
repro=byp,6,8
enddef
define  check135r     00000000000
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
parity=,,ab,on
sfastf=22.68s
!+6s
repro=raw,5,7
!*
st=rev,135,off
!+4s
parity
!*+54s
et
!+3s
repro=byp,5,7
enddef
define  check135f     97355220523
"Comment out the following line if you do _not_ have a mark III decoder
decode=a,err,byte
parity=,,ab,on
sfastr=22.68s
!+6s
repro=raw,6,8
!*
st=for,135,off
!+4s
parity
!*+54s
et
!+3s
repro=byp,6,8
enddef
define  tapeformv     98222124704x
tapeform=  1,-319,  2,  31,  3,-271,  4,  79,  5,-223,  6, 127
tapeform=  7,-175,  8, 175,  9,-127, 10, 223, 11, -79, 12, 271
tapeform= 13, -31, 14, 319
enddef
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000 
"no phase cal control is implemented here
enddef
define  checkcrc      00000000000 
"comment out the following lines if you do _not_ have a mark iii decoder
st=*,*,on
decode=a,crc
decode
enddef
define  change_pack   00000000000x
sy=fs.prompt "bank/vsn '$' should be changed"  &
xdisp=on
"the disk module that is not selected may now be replaced.
"
"the mark5 will stop recording momentarily when the key is turned to
" either "locked" or "unlocked" and it will not respond to commands
" from the fs for almost 20 seconds after the key is turned to
" "locked". turn the key to "unlocked" only when not recording.
" turn the key to "locked" only when the mark5 is not recording
" and when the fs will be idle for at least 20 more seconds.
wakeup 
xdisp=off
enddef   
define  checkmk5      00000000000 
scan_check
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5_status
enddef
define  checkk5       00000000000 
enddef
define  ready_k5      00000000000 
enddef
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef   
