define  exper_initi   00000000000
sched_initi
enddef
define  sched_initi   00000000000
enddef
define  sched_end     00000000000
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
define  preob         00000000000
onsource
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
mk5=status?
"uncomment the following if your station uses in2net transfers
"mk5=net_protocol=tcp:4194304:2097152;
enddef
define  setupa        00000000000
pcalon
bbcsx8
cont_cal=on
form=geo
mk5b_mode=ext,0x55555555,2
ifdsx
enddef
define  caltsys       00000000000
tpicd=tsys
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
ifa
ifb
ifc
ifd
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
mk5=status?
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
