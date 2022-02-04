define  ifagc         00000000000x
ifa=*,agc
ifb=*,agc
ifc=*,agc
ifd=*,agc
ife=*,agc
iff=*,agc
ifg=*,agc
ifh=*,agc
enddef
define  ifman         00000000000x
ifa=*,man
ifb=*,man
ifc=*,man
ifd=*,man
ife=*,man
iff=*,man
ifg=*,man
ifh=*,man
enddef
define  bread         00000000000x
bbc001
bbc002
bbc003
bbc004
bbc005
bbc006
bbc007
bbc008
bbc009
bbc010
bbc011
bbc012
bbc013
bbc014
bbc015
bbc016
bbc017
bbc018
bbc019
bbc020
bbc021
bbc022
bbc023
bbc024
bbc025
bbc026
bbc027
bbc028
bbc029
bbc030
bbc031
bbc032
bbc033
bbc034
bbc035
bbc036
bbc037
bbc038
bbc039
bbc040
bbc041
bbc042
bbc043
bbc044
bbc045
bbc046
bbc047
bbc048
bbc049
bbc050
bbc051
bbc052
bbc053
bbc054
bbc055
bbc056
bbc057
bbc058
bbc059
bbc060
bbc061
bbc062
bbc063
bbc064
enddef
define  iread         00000000000x
ifa
ifb
ifc
ifd
ife
iff
ifg
ifh
enddef
define  caloff        00000000000
"turn cal off
enddef
define  calon         00000000000
"turn cal on
enddef
define  sched_initi   00000000000x
jive5ab=version?
" check ntp
check_ntp
enddef
define  sched_end     00000000000x
"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" comment on timing:
"- - - - - - - - - -
" we report 'maser-fmout' for each Core3H board of the DBBC3
" with the command 'pps_delay'
" we also report 'gps-maser' with the command 'clock'
" thus, 'gps-maser' + 'maser-fmout' = 'gps-fmout'
"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
enddef
define  initi         22033234428x
"welcome to the field system
"sy=run setcl &
check_ntp
enddef
define  midob         00000000000
onsource
wx
"sy=cdms_delay
clock
mcast_time
define  postob        00000000000x
enddef
define  preob         00000000000x
onsource
enddef
define  ready_disk    00000000000x
enddef
define  pcalon        22033234528
" Enable pcal signal
enddef
define  pcaloff       00000000000x
" Disable pcal signal
enddef
define  checkfb       00000000000x
scan_check
fb_status
enddef
define  clock         00000000000x
"gps-maser=cb
enddef
define  check_ntp     22033234428x
sy=popen 'uptime 2>&1' -n uptime &
sy=popen 'ntpq -np 2>&1|grep -v "^[- x]" 2>&1' -n ntpq &
enddef
define  fb_config     22033234617x
enddef
define  proc_library  00000000000x
" ONSA13SW default VGOS obs library
" Manually constructed outside DRUDG
"< DBBC3_DDC            rack >< FlexBuff recorder 1>
enddef
define  exper_initi   00000000000
proc_library
sched_initi
mk5=dts_id?
mk5=os_rev?
mk5_status
setupbb
enddef
define  setupvg       22033234528x
pcalon
tpicd=stop
core3hvg=$
fb_mode=vdif,,,64
fb_mode
fb_config
dbbcvg
ifdvg
cont_cal=on,2
tpicd=no,100
tpicd
enddef
define  dbbcvg        22033234617x9x
bbc001=3480.4,a,32.0
bbc002=3448.4,a,32.0
bbc003=3384.4,a,32.0
bbc004=3320.4,a,32.0
bbc005=3224.4,a,32.0
bbc006=3096.4,a,32.0
bbc007=3064.4,a,32.0
bbc008=3032.4,a,32.0
bbc009=3480.4,b,32.0
bbc010=3448.4,b,32.0
bbc011=3384.4,b,32.0
bbc012=3320.4,b,32.0
bbc013=3224.4,b,32.0
bbc014=3096.4,b,32.0
bbc015=3064.4,b,32.0
bbc016=3032.4,b,32.0
bbc017=1979.6,c,32.0
bbc018=2011.6,c,32.0
bbc019=2075.6,c,32.0
bbc020=2139.6,c,32.0
bbc021=2235.6,c,32.0
bbc022=2363.6,c,32.0
bbc023=2395.6,c,32.0
bbc024=2427.6,c,32.0
bbc025=1979.6,d,32.0
bbc026=2011.6,d,32.0
bbc027=2075.6,d,32.0
bbc028=2139.6,d,32.0
bbc029=2235.6,d,32.0
bbc030=2363.6,d,32.0
bbc031=2395.6,d,32.0
bbc032=2427.6,d,32.0
bbc033=859.6,e,32.0
bbc034=891.6,e,32.0
bbc035=955.6,e,32.0
bbc036=1019.6,e,32.0
bbc037=1115.6,e,32.0
bbc038=1243.6,e,32.0
bbc039=1275.6,e,32.0
bbc040=1307.6,e,32.0
bbc041=859.6,f,32.0
bbc042=891.6,f,32.0
bbc043=955.6,f,32.0
bbc044=1019.6,f,32.0
bbc045=1115.6,f,32.0
bbc046=1243.6,f,32.0
bbc047=1275.6,f,32.0
bbc048=1307.6,f,32.0
bbc049=919.6,g,32.0
bbc050=951.6,g,32.0
bbc051=1015.6,g,32.0
bbc052=1079.6,g,32.0
bbc053=1175.6,g,32.0
bbc054=1303.6,g,32.0
bbc055=1335.6,g,32.0
bbc056=1367.6,g,32.0
bbc057=919.6,h,32.0
bbc058=951.6,h,32.0
bbc059=1015.6,h,32.0
bbc060=1079.6,h,32.0
bbc061=1175.6,h,32.0
bbc062=1303.6,h,32.0
bbc063=1335.6,h,32.0
bbc064=1367.6,h,32.0
enddef
define  ifdvg       2122033234619x
ifa=1,agc,32000
ifb=1,agc,32000
ifc=2,agc,32000
ifd=2,agc,32000
ife=2,agc,32000
iff=2,agc,32000
ifg=2,agc,32000
ifh=2,agc,32000
lo=
lo=loa,0,usb,lcp
lo=lob,0,usb,rcp
lo=loc,7700,lsb,lcp
lo=lod,7700,lsb,rcp
lo=loe,7700,lsb,lcp
lo=lof,7700,lsb,rcp
lo=log,11600,lsb,lcp
lo=loh,11600,lsb,rcp
enddef
define  core3hvg      22033234529
core3h_mode=begin,$
core3h_mode=1,0xcccccccc,,64.0,$
core3h_mode=2,0xcccccccc,,64.0,$
core3h_mode=3,0x33333333,,64.0,$
core3h_mode=4,0x33333333,,64.0,$
core3h_mode=5,0x33333333,,64.0,$
core3h_mode=6,0x33333333,,64.0,$
core3h_mode=7,0x33333333,,64.0,$
core3h_mode=8,0x33333333,,64.0,$
core3h_mode=end,$
enddef
