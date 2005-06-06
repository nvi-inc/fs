define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
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
vcsx2
ifdsx
form=c1,4
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
lo= 
lo=lo1,7680.00,usb  
lo=lo2,1600.00,usb  
patch=  
patch=lo1,a1,a2,a3,a4,a5,a6,a7,a8 
patch=lo2,b1,b2,b3,b4,b5,b6 
enddef
define  initi         00000000000
"welcome to the pc field system
vlbainit
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
va
valo
vb
vblo
vabw
vbbw
form
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
cable
"caltsys
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
form
enddef
define  precond       00000000000
schedule=vprepass,#1
enddef
define  precondthin   00000000000
schedule=vprethin,#1
enddef
define  preob         00000000000
onsource
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
!+5s
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
"sxcts
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
form=c1,4.000
systracks=
vcsx2
ifdsx
enable=g0,g2
tape=low
repro=byp,8,20
enddef
define  setupb        00000000000
pcalon
tapeformc
pass=$
form=c2,4.000
systracks=
vcsx2
ifdsx
enable=g1,g3
tape=low
repro=byp,9,21
enddef
define  sxcts         00000000000
enddef
define  tapeformc     00000000000
tapeform=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform=13,0,14,0,15,55,16,55,17,110,18,110
tapeform=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  unlod         00000000000
check=*,-tp
unloader=$
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
rec=addr
enddef
define  rel           00000000000 
rec=release
!+3s
rec=release
enddef
define  check135r     000000000000
"Comment out the following line if you do _not_ have a mark III decoder
"decode=a,err,byte
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
"decode=a,err,byte
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
"decode=a,err,byte
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
"decode=a,err,byte
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
define  vcsx2         99181182900x
valo=1,530.99 
va=1,11  
valo=2,540.99 
va=2,10  
valo=3,570.99 
va=3,09  
valo=4,630.99 
va=4,09  
valo=5,740.99 
va=5,08  
valo=6,820.99 
va=6,08  
valo=7,870.99 
va=7,08  
valo=8,890.99 
va=8,07  
vblo=1,617.99 
vb=1,07  
vblo=2,622.99 
vb=2,07  
vblo=3,637.99 
vb=3,07  
vblo=4,667.99 
vb=4,06  
vblo=5,692.99 
vb=5,07  
vblo=6,702.99 
vb=6,06  
vabw=2.000  
vbbw=2.000  
enddef
define  change_pack   00000000000x
sy=fs.prompt "bank/vsn '$' should be changed"  &
xdisp=on
"the disk module that is not selected may now be replaced.
"
"the mark5 will not respond to commands from the fs
" for almost 20 seconds after the key is turned to "locked".
" turn the key to "locked" only when the FS will be
" idle for more than 20 seconds.
wakeup 
xdisp=off
enddef   
define  checkmk5a     00000000000 
scan_check
enddef
define  checkk5       00000000000 
enddef
define  ready_k5      00000000000 
enddef
