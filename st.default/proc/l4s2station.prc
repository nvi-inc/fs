define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
enddef
define  caloff        00000000000
"turn cal off
enddef
define  calon         00000000000
"turn cal on
enddef
define  caltsys       00000000000
tpi=formvc,formif
ifd=max,max,*,*
if3=max,*,*,*,*
!+2s
tpzero=formvc,formif
ifd=old,old,*,*
if3=old,*,*,*,*
calon
!+2s
tpical=formvc,formif
tpdiff=formvc,formif
caloff
caltemp=formvc,formif
tsys=formvc,formif
enddef
define  dat           00000000000
ifp01=reset
ifp02=reset
ifpxxf
ifdxx
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
define  ifdxx         00000000000
lo=
lo=lo1,8265.00,usb,lcp,1
lo=lo2,8265.00,usb,rcp,1
enddef
define  ifdvc         00000000000
lo=
lo=lo1,4656.00,usb,lcp,1
enddef
define  ifpxxf        00000000000
ifp01=160.00,16.0,scb,nat
ifp02=160.00,16.0,scb,nat
vc01=152.00,16,u,0,0
vc02=152.00,16,u,0,0
patch=lo1,1l
patch=lo2,2l
4trackform=3,1us,4,1um,5,2us,6,2um
4tracks=3,4,5,6
4form=m,16.000,1:1,16
enddef
define  ifpvcf        00000000000
ifp01=160.00,16.0,dsb,nat,flip,vlba
vc01=144.00,16,u,0,0
vc03=160.00,16,u,0,0
patch=lo1,1l,3l
4trackform=3,1us,4,1um,5,3us,6,3um
4tracks=3,4,5,6
4form=m,16.000,1:1,16
enddef
define  initi         01312084428
"welcome to the pc field system
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
ifp01
ifp02
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
sy=run setcl &
enddef
define  midtp         00000000000
enddef
define  min15         00000000000
wx
cable
enddef
define  overnite      00000000000
log=overnite
setupa=0
check=*,-tp
min15@!,15m
enddef
define  postob        00000000000
enddef
define  preob         00000000000
onsource
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
define  setupa        00000000000
pcalon
ifpxxf
ifdxx
trackforma
rec_mode=32x4-2,$
user_info=1,label,station
user_info=2,label,source
user_info=3,label,experiment
user_info=3,field,<none>
user_info=1,field,,auto
user_info=2,field,,auto
data_valid=off
enddef
define  setupv        00000000000
pcalon
ifpvcf
ifdvc
trackformv
rec_mode=32x4-2,$
user_info=1,label,station
user_info=2,label,source
user_info=3,label,experiment
user_info=3,field,<none>
user_info=1,field,,auto
user_info=2,field,,auto
data_valid=off
enddef
define  trackforma    00000000000
trackform=
trackform=0,1us,1,1um,2,2us,3,2um
enddef
define  trackformv    00000000000
trackform=
trackform=0,1ls,1,1lm,2,1us,3,1um
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
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000x
"no phase cal control is implemented here
enddef
define  checkcrc      00000000000x
"comment out the following lines if you do _not_ have a mark iii decoder
"decode=a,crc
"decode
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
