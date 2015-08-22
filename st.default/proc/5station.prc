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
vsi=geo
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
" the shown order of the commands from here to the end of this procedure is
" strongly recommended
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
mk5b_mode
!+1s
mk5=dot?
mk5=bank_set?
sy=run setcl adapt &
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
enddef
define  preob         00000000000
onsource
caltsys
enddef
define  setupa        00000000000
pcalon
vcsx2
vsi4=geo
mk5b_mode=ext;0x55555555;
ifdsx
enddef
define  setupb        00000000000
pcalon
vcsx2
vsi4=geo
mk5b_mode=ext;0x55555555;
ifdsx
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
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef   
" and when the fs will be idle for at least 20 more seconds.
wakeup 
xdisp=off
enddef   
define  ready_disk    00000000000
mk5close
xdisp=on
"mount the mark5 disks for this experiment now
"recording will begin at current position
"enter 'mk5relink' when ready or
"if you can't get the mk5 going then
"enter 'cont' to continue without the mk5
xdisp=off
halt
disk_serial
disk_pos
bank_check
"uncomment the following for Mark 5A
"mk5=DTS_id?
"mk5=OS_rev1?
"mk5=OS_rev2?
"mk5=SS_rev1?
"mk5=SS_rev2?
"mk5_status
"uncomment the following for Mark 5B
"mk5=DTS_id?
"mk5=OS_rev?
"mk5=SS_rev?
"mk5_status
"uncomment the following if your station uses in2net transfers
"mk5=net_protocol=tcp:4194304:2097152;
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
define  mk5panic      000000000000
"mk5panic - dls - 5 december 2003
disk_record=off
mk5=bank_set=inc;
!+3s
disk_serial
mk5=bank_set?
mk5=vsn?
enddef   
