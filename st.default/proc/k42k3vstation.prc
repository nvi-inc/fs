define  exper_initi   00000000000
sched_initi
enddef
define  setupa        01138134726x
pcalon  
tapefsxc  
pass=$  
vcsx2 
ifdsx 
form=c,4.000  
bit_density=33333 
systracks=  
tape=low  
enable=g0,g2  
repro=byp,6,22  
enddef
define  setupb        01138143354x
pcalon  
tapefsxc  
pass=$  
vcsx2 
ifdsx 
form=c,4.000  
bit_density=33333 
systracks=  
tape=low  
enable=g1,g3  
repro=byp,7,23  
enddef
define  vcsx2         01138134726x
valo=1,630.99 
va=1,11,usb  
valo=2,640.99 
va=2,11,usb  
valo=3,670.99 
va=3,10,usb  
valo=4,730.99 
va=4,9,usb  
valo=5,840.99 
va=5,7,usb  
valo=6,920.99 
va=6,4,usb  
valo=7,970.99 
va=7,2,usb  
valo=8,990.99 
va=8,2,usb  
vblo=1,697.99 
vb=1,7,usb  
vblo=2,702.99 
vb=2,6,usb  
vblo=3,717.99 
vb=3,8,usb  
vblo=4,747.99 
vb=4,7,usb  
vblo=5,772.99 
vb=5,7,usb  
vblo=6,782.99 
vb=6,7,usb  
vabw=2.000  
vbbw=2.000  
enddef
define  ifdsx         01138134731x
lo= 
lo=lo1,7580.00,usb  
lo=lo2,1520.00,usb  
patch=  
patch=lo1,a1,a2,a3,a4,a5,a6,a7,a8 
patch=lo2,b1,b2,b3,b4,b5,b6 
enddef
define  tapefsxc      01138134726x
tapeform=  1,-330,  2,-330,  3,-275,  4,-275,  5,-220,  6,-220  
tapeform=  7,-165,  8,-165,  9,-110, 10,-110, 11, -55, 12, -55  
tapeform= 13,   0, 14,   0, 15,  55, 16,  55, 17, 110, 18, 110  
tapeform= 19, 165, 20, 165, 21, 220, 22, 220, 23, 275, 24, 275  
enddef
define  unloader      01139081443x
!+5s  
enable=   
tape=off  
rec=unload  
enddef
define  loader        01138134836x
rec=load  
!+10s 
tape=low,reset  
st=for,135,off  
!+11s 
et  
!+3s  
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
newtape
loader
label
rec
"check=*,tp
enddef
define  unlod         00000000000
check=*,-tp
unloader
xdisp=on
"**dismount this tape now**"
wakeup
xdisp=off
enddef
