define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
enddef
define  drive2        00000000000x
enddef
define  caloff        00000000000
"rx=*,*,*,*,*,*,off
enddef
define  calon         00000000000
"rx=*,*,*,*,*,*,on
enddef
define  caltemps      00000000000
caltemp5=x
caltemp6=x
enddef
define  dat           00000000000
vcsx2
ifdsx
form=c1,4
enddef
define  ifdsx         00000000000x
lo=
lo=lo1,7680.00,usb
lo=lo2,1600.00,usb
patch=
patch=lo1,a1,a2,a3,a4,a5,a6,a7,a8
patch=lo2,b1,b2,b3,b4,b5,b6
ifatt=15,28,25,28
enddef
define  initi         99346012650
"welcome to the pc field system
rec1=addr
rec2=addr
sy=run setcl &
enddef
define  midob         00000000000x
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
gps-fmout=c2
clockoff
sy=run setcl &
enddef
define  midtp         00000000000x
"rxmon
enddef
define  min15         00000000000x
wx
cable
gps-fmout=c2
enddef
define  overnite1     00000000000x
log=overnite
setupa1=1
min15@!,1m
enddef
define  postob        00000000000
enddef
define  preob         00000000000
onsource
enddef
define  loader1       00000000000
rec1=load
!+10s
tape1=low,reset
st1=for,135,off
!+11s
et1
!+3s
enddef
define  unloader1     00000000000x
!+5s
enable1=
tape1=off
rec1=unload
enddef
define  fastf1        00000000000
ff1
!+$
et1
enddef
define  fastr1        00000000000
rw1
!+$
et1
enddef
define  precondthin1  00000000000
schedule=vprethin1,#1
enddef
define  prepassthin1  00000000000
wakeup
xdisp=on
" on drive 1
" mount the next tape without cleaning the tape drive.
" use the label1=... command when finished.
halt
xdisp=off
check=*,-r1,-h1
tape1=low
rec1=load
!+10s
sff1
!+10m54s
et1
!+9s
wakeup
xdisp=on
"on drive 1
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the label1=... command when finished.
halt
xdisp=off
rec1=load
!+10s
srw1
!+10m54s
et1
!+9s
rec1=unload
enddef
define  ready1        00000000000
"rxmon
newtape1=$
loader1
label1
check=*,r1
enddef
define  sfastf1       00000000000
sff1
!+$
et1
enddef
define  sfastr1       00000000000
srw1
!+$
et1
enddef
define  setupa1       00000000000
pcalon
select=1
drive1
tapefrmsxc1
pass1=$
vcsx2
ifdsx
form=c1,4.000
systracks1=
tape1=low
enable1=g0,g2
repro1=byp,6,22
enddef
define  setupb1       00000000000
pcalon
select=1
drive1
tapefrmsxc1
pass1=$
vcsx2
ifdsx
form=c2,4.000
systracks1=
tape1=low
enable1=g1,g3
repro1=byp,7,23
enddef
define  tapefrmsxc1   00000000000x
tapeform1=  1,-330,  2,-330,  3,-275,  4,-275,  5,-220,  6,-220
tapeform1=  7,-165,  8,-165,  9,-110, 10,-110, 11, -55, 12, -55
tapeform1= 13,   0, 14,   0, 15,  55, 16,  55, 17, 110, 18, 110
tapeform1= 19, 165, 20, 165, 21, 220, 22, 220, 23, 275, 24, 275
enddef
define  unlod1        00000000000
check=*,-r1
unloader1
xdisp=on
"**************dismount this tape now************"
wakeup
xdisp=off
enddef
define  tapeforma1    00000000000
tapeform1=1,-350,2,  0,3,-295, 4, 55, 5,-240, 6,110
tapeform1=7,-185,8,165,9,-130,10,220,11, -75,12,275
enddef
define  tapeformc1    00000000000
tapeform1=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform1=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform1=13,  0,14,  0,15, 55,16, 55,17,110,18,110
tapeform1=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  check135r1    00000000000x
parity1=,,ab,off
sfastf1=18.41s
!+6s
repro1=read,4,6
!*
st1=rev,135,off
!+3s
parity1
!*+45s
et1
!+3s
repro1=byp,4,6
enddef
define  check135f1    00000000000x
parity1=,,ab,off
sfastr1=18.41s
!+6s
repro1=read,4,6
!*
st1=for,135,off
!+3s
parity1
!*+45s
et1
!+3s
repro1=byp,4,6
enddef
define  check80r1     00000000000x
parity1=,,ab,off
sfastf1=10.66s
!+6s
repro1=read,4,6
!*
st1=rev,80,off
!+2s
parity1
!*+44s
et1
!+2s
repro1=byp,4,6
enddef
define  check80f1     00000000000x
parity1=,,ab,off
sfastr1=10.66s
!+6s
repro1=read,4,6
!*
st1=for,80,off
!+2s
parity1
!*+44s
et1
!+2s
repro1=byp,4,6
enddef
define  loader2       00000000000x
rec2=load
!+10s
tape2=low,reset
st2=for,135,off
!+11s
et2
!+3s
enddef
define  unloader2     00000000000x
!+5s
enable2=
tape2=off
rec2=unload
enddef
define  fastf2        00000000000
ff2
!+$
et2
enddef
define  fastr2        00000000000
rw2
!+$
et2
enddef
define  precondthin2  00000000000
schedule=vprethin2,#1
enddef
define  prepassthin2  00000000000
wakeup
xdisp=on
" on drive 2
" mount the next tape without cleaning the tape drive.
" use the label2=... command when finished.
halt
xdisp=off
check=*,-r2,-h2
tape2=low
rec2=load
!+10s
sff2
!+10m54s
et2
!+9s
wakeup
xdisp=on
"on drive 2
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape, establish vacuum.
"use the label2=... command when finished.
halt
xdisp=off
rec2=load
!+10s
srw2
!+10m54s
et2
!+9s
rec2=unload
enddef
define  ready2        00000000000x
caltsys
"rxmon
newtape2=$
loader2
label2
check=*,r2
enddef
define  sfastf2       00000000000
sff2
!+$
et2
enddef
define  sfastr2       00000000000
srw2
!+$
et2
enddef
define  setupa2       00000000000
pcalon
select=2
drive2
tapefrmsxc2
pass2=$
vcsx2
ifdsx
form=c1,4.000
systracks2=
tape2=low
enable2=g0,g2
repro2=byp,6,22
enddef
define  setupb2       00000000000x
pcalon
select=2
drive2
tapefrmsxc2
pass2=$
vcsx2
ifdsx
form=c2,4.000
systracks2=
tape2=low
enable2=g1,g3
repro2=byp,7,23
enddef
define  tapefrmsxc2   00000000000x
tapeform2=  1,-330,  2,-330,  3,-275,  4,-275,  5,-220,  6,-220
tapeform2=  7,-165,  8,-165,  9,-110, 10,-110, 11, -55, 12, -55
tapeform2= 13,   0, 14,   0, 15,  55, 16,  55, 17, 110, 18, 110
tapeform2= 19, 165, 20, 165, 21, 220, 22, 220, 23, 275, 24, 275
enddef
define  unlod2        00000000000x
check=*,-r2
unloader2
xdisp=on
"**************dismount this tape now************"
wakeup
xdisp=off
enddef
define  tapeforma2    00000000000
tapeform2=1,-350,2,  0,3,-295, 4, 55, 5,-240, 6,110
tapeform2=7,-185,8,165,9,-130,10,220,11, -75,12,275
enddef
define  tapeformc2    00000000000
tapeform2=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform2=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform2=13,  0,14,  0,15, 55,16, 55,17,110,18,110
tapeform2=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  check135r2    00000000000x
parity2=,,ab,off
sfastf2=18.41s
!+6s
repro2=read,4,6
!*
st2=rev,135,off
!+3s
parity2
!*+45s
et2
!+3s
repro2=byp,4,6
enddef
define  check135f2    00000000000x
parity2=,,ab,off
sfastr2=18.41s
!+6s
repro2=read,4,6
!*
st2=for,135,off
!+3s
parity2
!*+45s
et2
!+3s
repro2=byp,4,6
enddef
define  check80r2     00000000000x
parity2=,,ab,off
sfastf2=10.66s
!+6s
repro2=read,4,6
!*
st2=rev,80,off
!+2s
parity2
!*+44s
et2
!+2s
repro2=byp,4,6
enddef
define  check80f2     00000000000x
parity2=,,ab,off
sfastr2=10.66s
!+6s
repro2=read,4,6
!*
st2=for,80,off
!+2s
parity2
!*+44s
et2
!+2s
repro2=byp,4,6
enddef
define  vcsx2         00000000000
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
define  rel1          00000000000x
rec1=release
!+3s
rec1=release
enddef
define  rel2          00000000000x
rec2=release
!+3s
rec2=release
enddef
define  drive1        00000000000
enddef
