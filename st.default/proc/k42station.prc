define  exper_initi   00000000000
sched_initi
enddef
define  setupa        00000000000x
pcalon  
rec=synch_on  
rec_mode=64  
!*  
vcsx2 
ifdsx 
!*+20s  
enddef
define  vcsx2         00000000000x
valo=1,629.99 
va=1,11,usb  
valo=2,639.99 
va=2,11,usb  
valo=3,669.99 
va=3,11,usb  
valo=4,729.99 
va=4,10,usb  
valo=5,839.99 
va=5,8,usb  
valo=6,919.99 
va=6,4,usb  
valo=7,969.99 
va=7,3,usb  
valo=8,989.99 
va=8,4,usb  
vblo=1,649.99 
vb=1,9,usb  
vblo=2,979.99 
vb=2,2,usb  
vblo=3,699.99 
vb=3,9,usb  
vblo=4,704.99 
vb=4,9,usb  
vblo=5,719.99 
vb=5,8,usb  
vblo=6,749.99 
vb=6,8,usb  
vblo=7,774.99 
vb=7,8,usb  
vblo=8,784.99 
vb=8,8,usb  
vabw=wide 
vbbw=wide 
enddef
define  ifdsx         00000000000x
lo= 
lo=lo1,7580.00,usb  
lo=lo2,1520.00,usb  
patch=  
patch=lo1,a1,a2,a3,a4,a5,a6,a7,a8,b1,b2 
patch=lo2,b3,b4,b5,b6,b7,b8 
enddef
define  unloader      01290030607x
rec=eject 
!+10s 
oldtape=$ 
!+20s 
enddef
define  loader        01290030524x
!+25s 
tape=reset  
!+6s  
enddef
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
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
enddef
define  initi         00000000000
"welcome to the pc field system
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
va
vb
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
enddef
define  overnite      00000000000
log=overnite
setupa
"check=*,-tp
min15@!,15m
"rxmon@!+2m30s,5m
define  postob        00000000000
enddef
define  ready         00000000000
"caltsys
"rxmon
newtape=$
loader
label
rec
"check=*,tp
enddef
define  unlod         00000000000
check=*,-tp
unloader=$
xdisp=on
"**dismount this tape now**"
wakeup
xdisp=off
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
