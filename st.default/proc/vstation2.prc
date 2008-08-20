define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
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
define  dat           00000000000
bbcsx2
ifdsx
form=c,4
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
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
ifdab
ifdcd
bbc01
bbc05
bbc09
gps-fmout=c2
sy=run setcl &
enddef
define  midtp         00000000000
bbcman
ifdab=20,20,*,*
ifdcd=20,20,*,*
!+2s
tpzero=formbbc,formif
bbcagc
ifdab=0,0,*,*
ifdcd=0,0,*,*
"rxmon
enddef
define  min15         00000000000
"rxall
wx
cable
caltsys
enddef
define  overnite1     00000000000
log=overnite
setupa1=1
check=*,-r1
min15@!,15m
"rxmon@!+2m30s,5m
repro1=byp,8,14
dqa=1
dqa@!,1m
enddef
define  postob        00000000000
enddef
define  preob         00000000000
onsource
caltsys
enddef
define  caltsys       00000000000
bbcman
tpi=formbbc,formif
ifdab=20,20,*,*
ifdcd=20,20,*,*
!+2s
tpzero=formbbc,formif
ifdab=0,0,*,*
ifdcd=0,0,*,*
calon
!+2s
tpical=formbbc,formif
tpgain=formbbc,formif
bbcagc
caloff
caltemp=formbbc,formif
tsys=formbbc,formif
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
rec1=addr
rec2=addr
ifdab=addr
ifdcd=addr
enddef
define  rel1          00000000000 
rec1=release
!+3s
rec1=release
enddef
define  check135r1    000000000000
form=*,4
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
define  check135f1    00000000000 
form=*,4
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
define  check80r1     00000000000
form=*,4
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
define  check80f1     00000000000
form=*,4
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
define  tapeformv1    98222124704x
tapeform1=  1,-319,  2,  31,  3,-271,  4,  79,  5,-223,  6, 127
tapeform1=  7,-175,  8, 175,  9,-127, 10, 223, 11, -79, 12, 271
tapeform1= 13, -31, 14, 319
enddef
define  tapeforma1    00000000000
tapeform1=1,-350,2,  0,3,-295, 4, 55, 5, -240, 6,110
tapeform1=7,-185,8,165,9,-130,10,220,11,  -75,12,275
enddef
define  dqaeven1      00000000000
dqa=1
repro1=*,4,6,*,*
dqa
repro1=*,8,10,*,*
dqa
repro1=*,12,14,*,*
dqa
repro1=*,16,18,*,*
dqa
repro1=*,20,22,*,*
dqa
repro1=*,24,26,*,*
dqa
repro1=*,28,30,*,*
dqa
enddef
define  dqaodd1       00000000000
dqa=1
repro1=*,5,7,*,*
dqa
repro1=*,9,11,*,*
dqa
repro1=*,13,15,*,*
dqa
repro1=*,17,19,*,*
dqa
repro1=*,21,23,*,*
dqa
repro1=*,25,27,*,*
dqa
repro1=*,29,31,*,*
dqa
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
define  precond1      00000000000
schedule=vprepass1,#1
enddef
define  precondthin1  00000000000
schedule=vprethin1,#1
enddef
" on drive 1
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the label1=... command when finished
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
caltsys
"rxmon
newtape1
loader1
label1
check=*,r1
enddef
define  loader1       00000000000
rec1=load
!+10s
tape1=low,reset
st1=for,135,off
!+11s
et1
!+3s
rec1
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
tapeformc1
pass1=$
form=c,4.000
!*
systracks1=
bbcsx2
ifdsx
enable1=g0,g2
tape1=low
repro1=byp,8,20
!*+8s
enddef
define  setupb1       00000000000
pcalon
select=1
tapeformc1
pass1=$
form1=c,4.000
!*
systracks1=
bbcsx2
ifdsx
enable1=g1,g3
tape1=low
repro1=byp,9,21
!*+8s
enddef
define  tapeformc1    00000000000
tapeform1=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform1=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform1=13,0,14,0,15,55,16,55,17,110,18,110
tapeform1=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  unlod1        00000000000
check=*,-r1
unloader1
xdisp=on
"**dismount tape drive 1 now**"
wakeup
xdisp=off
enddef
define  unloader1     00000000000
!+5s
enable1=,
tape1=off
rec1=unload
enddef
define  prepass1      00000000000
wakeup
xdisp=on
" on drive 1
" mount the next tape without cleaning the tape drive.
" use the label1=... command when finished.
halt
xdisp=off
check=*,-r1
rec1=load
!+10s
tape1=low,reset
sff1
!+5m27s
et1
!+9s
wakeup
rec1=release
!+3s
rec1=release
xdisp=on
" on drive 1
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the cont command when finished.
halt
xdisp=off
rec1=load
!+10s
srw1
!+5m28s
et1
!+9s
rec1=unload
enddef
define  prepassthin1  00000000000
wakeup
xdisp=on
" on drive 1
" mount the next tape without cleaning the tape drive.
" use the label1=... command when finished
halt
xdisp=off
check=*,-r1
rec1=load
!+10s
tape1=low,reset
sff1
!+10m54s
et1
!+9s
wakeup
rec1=release
!+3s
rec1=release
xdisp=on
define  rel2          00000000000 
rec2=release
!+3s
rec2=release
enddef
define  check135r2    000000000000
form=*,4
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
define  check135f2    00000000000 
form=*,4
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
define  check80r2     00000000000
form=*,4
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
define  check80f2     00000000000
form=*,4
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
define  tapeformv2    98222124704x
tapeform2=  1,-319,  2,  31,  3,-271,  4,  79,  5,-223,  6, 127
tapeform2=  7,-175,  8, 175,  9,-127, 10, 223, 11, -79, 12, 271
tapeform2= 13, -31, 14, 319
enddef
define  tapeforma2    00000000000
tapeform2=1,-350,2,  0,3,-295, 4, 55, 5, -240, 6,110
tapeform2=7,-185,8,165,9,-130,10,220,11,  -75,12,275
enddef
define  dqaeven2      00000000000
dqa=1
repro2=*,4,6,*,*
dqa
repro2=*,8,10,*,*
dqa
repro2=*,12,14,*,*
dqa
repro2=*,16,18,*,*
dqa
repro2=*,20,22,*,*
dqa
repro2=*,24,26,*,*
dqa
repro2=*,28,30,*,*
dqa
enddef
define  dqaodd2       00000000000
dqa=1
repro2=*,5,7,*,*
dqa
repro2=*,9,11,*,*
dqa
repro2=*,13,15,*,*
dqa
repro2=*,17,19,*,*
dqa
repro2=*,21,23,*,*
dqa
repro2=*,25,27,*,*
dqa
repro2=*,29,31,*,*
dqa
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
define  precond2      00000000000
schedule=vprepass2,#1
enddef
define  precondthin2  00000000000
schedule=vprethin2,#1
enddef
" on drive 2
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the label2=... command when finished
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
define  ready2        00000000000
caltsys
"rxmon
newtape2
loader2
label2
check=*,r2
enddef
define  loader2       00000000000
rec2=load
!+10s
tape2=low,reset
st2=for,135,off
!+11s
et2
!+3s
rec2
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
tapeformc2
pass2=$
form=c,4.000
!*
systracks2=
bbcsx2
ifdsx
enable2=g0,g2
tape2=low
repro2=byp,8,20
!*+8s
enddef
define  setupb2       00000000000
pcalon
select=2
tapeformc2
pass2=$
form2=c,4.000
!*
systracks2=
bbcsx2
ifdsx
enable2=g1,g3
tape2=low
repro2=byp,9,21
!*+8s
enddef
define  tapeformc2    00000000000
tapeform2=1,-330,2,-330,3,-275,4,-275,5,-220,6,-220
tapeform2=7,-165,8,-165,9,-110,10,-110,11,-55,12,-55
tapeform2=13,0,14,0,15,55,16,55,17,110,18,110
tapeform2=19,165,20,165,21,220,22,220,23,275,24,275
enddef
define  unlod2        00000000000
check=*,-r2
unloader2
xdisp=on
"**dismount tape drive 2 now**"
wakeup
xdisp=off
enddef
define  unloader2     00000000000
!+5s
enable2=,
tape2=off
rec2=unload
enddef
define  prepass2      00000000000
wakeup
xdisp=on
" on drive 2
" mount the next tape without cleaning the tape drive.
" use the label2=... command when finished.
halt
xdisp=off
check=*,-r2
rec2=load
!+10s
tape2=low,reset
sff2
!+5m27s
et2
!+9s
wakeup
rec2=release
!+3s
rec2=release
xdisp=on
" on drive 2
"drop vacuum loop, clean the tape drive thoroughly.
"re-thread the tape
"use the cont command when finished.
halt
xdisp=off
rec2=load
!+10s
srw2
!+5m28s
et2
!+9s
rec2=unload
enddef
define  prepassthin2  00000000000
wakeup
xdisp=on
" on drive 2
" mount the next tape without cleaning the tape drive.
" use the label2=... command when finished
halt
xdisp=off
check=*,-r2
rec2=load
!+10s
tape2=low,reset
sff2
!+10m54s
et2
!+9s
wakeup
rec2=release
!+3s
rec2=release
xdisp=on
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
mk5=status?
enddef
define  checkk5       00000000000 
enddef
define  ready_k5      00000000000 
enddef
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef   
