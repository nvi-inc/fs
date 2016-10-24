define  time          00000000000 
rdbe=pps_offset?;
rdbe=dot?;
rdbe=gps_offset?;
enddef
define  initi         00000000000 
"welcome to the pc field system
"sy=run setcl &
sy=xterm -name monit2 -e monit2 &
sy=xterm -name monit6 -e monit6 &
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
define  pcalon        00000000000 
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000 
"no phase cal control is implemented here
enddef
define  change_pack   00000000000 
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
"scan_check
"mk5=get_stats?
mk5c=status?;
enddef
define  greplog       00000000000 
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef
define  ready_disk    00000000000 
enddef
define  ifdpnt        00000000000 
lo=
lo=loa0,2472.4,usb,lcp,5
lo=loa1,2472.4,usb,rcp,5
lo=lob0,4712.4,usb,lcp,5
lo=lob1,4712.4,usb,rcp,5
lo=loc0,5832.4,usb,lcp,5
lo=loc1,5832.4,usb,rcp,5
lo=lod0,9672.4,usb,lcp,5
lo=lod1,9672.4,usb,rcp,5
enddef
define  rdbepnt       00000000000 
rdbe=dbe_chsel_en=2:chsel_enable:psn_enable;
rdbe=dbe_chsel=0:1:2:4:6:9:13:14:15;
rdbe=dbe_chsel=1:1:2:4:6:9:13:14:15;
"offset= mod(lo+1024),5)
"loa is 2472.4
"lob is 4712.4
"loa is 5832.4
"loa is 9672.4
rdbe=pcal=1.4e6;
enddef
define  setuppnt      00000000000 
pcalon
"tpicd=off
ifdpnt
rdbepnt
"mk6bb
"tpicd=no,0
"tpicd
enddef
define  postob        00000000000 
enddef
define  exper_initi   00000000000 
sched_initi
enddef
define  sched_initi   00000000000 
"test
enddef
define  sched_end     00000000000 
"test
enddef
define  ready_disk    00000000000 
xdisp=on
"starting new schedule"
xdisp=off
wakeup
"make sure mark 6 group is open and mounted`
enddef
define  rdbe_status   00000000000 
rdbe=dbe_status?;
enddef
define  auto          00000000000 
rdbe_atten=
enddef
define  max           00000000000 
rdbe_atten=31.5,31.5
enddef
define  mk6in         00000000000 
sy=popen -n mk6in 'ssh oper\@mark6a bin/mk6in 2>&1' &
enddef
