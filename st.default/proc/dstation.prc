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
define  ifdsx         00000000000
ifa=,agc,1
ifb=,agc,4
ifc=,agc,2
ifd=,agc,2
lo=
lo=loa,7600.00,usb,rcp,1
lo=lob,7600.00,usb,rcp,1
lo=loc,1900.00,usb,rcp,1
lo=lod,1900.00,usb,rcp,1
enddef
define  initi         00000000000
"welcome to the pc field system
sy=run setcl &
enddef
define  midob         00000000000
onsource
wx
cable
ifa
ifb
ifc
ifd
bbc01
bbc05
bbc09
bbc13
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
setupa
min15@!,15m
"rxmon@!+2m30s,5m
"pcal=0,60,by,25,0,5,11
"pcal
enddef
define  postob        00000000000
enddef
define  ifman         00000000000
if=ifa,ifa=*\,man\,*\,*
if=ifb,ifb=*\,man\,*\,*
if=ifc,ifc=*\,man\,*\,*
if=ifd,ifd=*\,man\,*\,*
enddef
define  ifagc         00000000000
if=ifa,ifa=*\,agc\,*\,*
if=ifb,ifb=*\,agc\,*\,*
if=ifc,ifc=*\,agc\,*\,*
if=ifd,ifd=*\,agc\,*\,*
enddef
define  preob         00000000000
if=cont_cal,tpicd=tsys,!*
onsource
"more commands can be added until total execution times between first two if's is just under four seconds
if=cont_cal,,!*+4s
if=cont_cal,,caltsys_man
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
"uncomment the following for Mark 5B
mk5=DTS_id?
mk5=OS_rev?
mk5=SS_rev?
mk5_status
"uncomment the following if your station uses in2net transfers
"mk5=net_protocol=tcp:4194304:2097152;
enddef
define  setupa        00000000000
pcalon
bbcsx8
cont_cal=off
"cont_cal=on
form=geo
mk5b_mode=ext,0x55555555,2
ifdsx
bbc_gain=all,agc
enddef
define  caltsys       00000000000
if=cont_cal,tpicd=tsys,caltsys_man
if=cont_cal,,ifagc
if=cont_cal,,if=ddc,bbc_gain=all\\\,agc
enddef
define  caltsys_man   00000000000
ifman
bbc_gain=all,man
!+2s
tpi=formbbc,formif
calon
!+2s
tpical=formbbc,formif
caloff
tpdiff=formbbc,formif
caltemp=formbbc,formif
tsys=formbbc,formif
enddef
define  bbcsx8        00000000000
bbc01=612.990000,a,8,1
bbc02=652.990000,a,8,1
bbc03=752.990000,a,8,1
bbc04=912.990000,a,8,1
bbc05=1132.990000,b,8,1
bbc06=1252.990000,b,8,1
bbc07=1312.990000,b,8,1
bbc08=1332.990000,b,8,1
bbc09=325.990000,c,8,1
bbc10=345.990000,c,8,1
bbc11=365.990000,c,8,1
bbc12=395.990000,c,8,1
bbc13=445.990000,d,8,1
bbc14=465.990000,d,8,1
bbc15=300.000000,d,8,1
bbc16=300.000000,d,8,1
enddef
define  iread         00000000000
if=ifa,ifa
if=ifb,ifb
if=ifc,ifc
if=ifd,ifd
enddef
define  bread         00000000000
if=bbc01,bbc01
if=bbc02,bbc02
if=bbc03,bbc03
if=bbc04,bbc04
if=bbc05,bbc05
if=bbc06,bbc06
if=bbc07,bbc07
if=bbc08,bbc08
if=bbc09,bbc09
if=bbc10,bbc10
if=bbc11,bbc11
if=bbc12,bbc12
if=bbc13,bbc13
if=bbc14,bbc14
if=bbc15,bbc15
if=bbc16,bbc16
if=pfb,if=core1\\\,pfb1
if=pfb,if=core2\\\,pfb2
if=pfb,if=core3\\\,pfb3
if=pfb,if=core4\\\,pfb4
enddef
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000 
"no phase cal control is implemented here
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
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
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
define  bbc_level     13179000745x
bbc_gain=1,30,30
!+1s
bbc_gain=2,30,30
!+1s
bbc_gain=3,30,30
!+1s
bbc_gain=4,30,30
!+1s
bbc_gain=5,30,30
!+1s
bbc_gain=6,30,30
!+1s
bbc_gain=7,30,30
!+1s
bbc_gain=8,30,30
!+1s
bbc_gain=9,30,30
!+1s
bbc_gain=10,30,30
!+1s
bbc_gain=11,30,30
!+1s
bbc_gain=12,30,30
!+1s
bbc_gain=13,30,30
!+1s
bbc_gain=14,30,30
!+1s
bbc_gain=15,30,30
!+1s
bbc_gain=16,30,30
!+1s
bbc_gain=all,agc,$
enddef
