define  onsample      00000000000x
wx
"comment out next command if you don't have a cable command
cable
"modify next command if you have a different procedure or command to sample
" all receiver monitor points, comment out if you have no facility for this 
rxall
"replace next command with your local fmout-gps or gps-fmout proc or command,
"  comment out if you have no facility for this 
fmoutgps
"comment out next command if you don't have a Mark IV decoder
pcsample
bbcmanx
caltsys
bbcagcx
enddef
define  stsample      00000000000x
"comment out next command if you don't have a cable command
cable
"comment out next command if you don't have a Mark IV decoder
pcsample
enddef
define  pcsample      00000000000x
xlog=on
pcalports=1,5
xlog=off
decode4=pcal usbx 10000 32
!+1.5s
decode4=pcal
decode4=pcal usby 10000 32
!+1.5s
decode4=pcal
xlog=on
pcalports=4,8
xlog=off
decode4=pcal usbx 10000 32
!+1.5s
decode4=pcal
decode4=pcal usby 10000 32
!+1.5s
decode4=pcal
xlog=on
pcalports=9,14
xlog=off
decode4=pcal usbx 10000 32
!+1.5s
decode4=pcal
decode4=pcal usby 10000 32
!+1.5s
decode4=pcal
enddef
define  rapid         00000000000
stsample@!,10s
enddef
define  overnite      00000000000
onsample@!,5m
enddef
