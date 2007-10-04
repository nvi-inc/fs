define  dat           04210151519x
fs=stop
bbc1=230.99,i1,16.0,16.0,1.0
bbc2=197.99,i4,16.0,16.0,1.0
agc=on
encode=vlba
mode=32x4-2-u
tonedet=0.01,usb,8.01,usb,1.0
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
define  ifdsx         04210151519
ifx=auto,,,auto,dir,,,dir,1.0
enddef
define  initi         04210151519x
"welcome to the field system (s2 mode)
s2version=da
s2version=r1
sy=run setcl &
sy=run setcl s2das &
dat
ifdsx
enddef
define  midob         00000000000
onsource
monpcalseq
sy=run setcl &
sy=run setcl s2das &
fs
"wx
"cable
"fmout-gps
enddef
define  min15         00000000000
status
monpcalseq
enddef
define  overnite      00000000000
log=overnite
dat
check=*,-all
min15@!,15m
enddef
define  postob        00000000000
enddef
define  preob         00000000000
enddef
define  ready         00000000000
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
define  unlod         00000000000
check=*,-tp
unloader
xdisp=on
"**************dismount this tape now************"
wakeup
xdisp=off
enddef
define  unloader      00000000000
et
rec=eject
enddef
define  pcalon        00000000000x
" no phase-cal control
enddef
define  pcaloff       00000000000x
" no phase-cal control
enddef
define  sched_initi   00000000000
"put procedures to be run at startup here
enddef
define  sched_end     00000000000
"place procedures to run at the end of experiment here
enddef
define  monpcal       00000000000x
tonemeas=1,$
tonemeas=2,$
enddef
define  monpcalseq    00000000000x
monpcal=1
monpcal=2
monpcal=3
monpcal=4
monpcal=5
monpcal=6
monpcal=7
monpcal=8
monpcal=9
monpcal=10
monpcal=11
monpcal=12
monpcal=13
monpcal=14
monpcal=15
monpcal=16
monpcal=17
monpcal=18
enddef
define  setupe3ivs    00000000000x
fs=start,e3-ivs
mode=32x4-2-u,yes
encode=vlba
agc=on
enddef
define  loade3ivs     00000000000x
fs=init,18,1.0
fs=state,01,1,132.99,i1,2,852.99,i1
fs=state,02,1,209.99,i4,2,334.99,i4
fs=state,03,1,852.99,i1,2,132.99,i1
fs=state,04,1,334.99,i4,2,209.99,i4
fs=state,05,1,602.99,i1,2,382.99,i1
fs=state,06,1,284.99,i4,2,259.99,i4
fs=state,07,1,382.99,i1,2,602.99,i1
fs=state,08,1,259.99,i4,2,284.99,i4
fs=state,09,1,142.99,i1,2,842.99,i1
fs=state,10,1,214.99,i4,2,329.99,i4
fs=state,11,1,842.99,i1,2,142.99,i1
fs=state,12,1,329.99,i4,2,214.99,i4
fs=state,13,1,752.99,i1,2,232.99,i1
fs=state,14,1,324.99,i4,2,219.99,i4
fs=state,15,1,232.99,i1,2,752.99,i1
fs=state,16,1,219.99,i4,2,324.99,i4
fs=state,17,1,162.99,i1,2,822.99,i1
fs=state,18,1,822.99,i1,2,162.99,i1
fs=start
fs=save,e3-ivs
enddef
define  checkmk5a     00000000000 
scan_check
enddef
define  checkk5       00000000000 
enddef
define  ready_k5      00000000000 
enddef
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef   
