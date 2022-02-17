define  ifagc         00000000000x
if=ifa,ifa=*\,agc
if=ifb,ifb=*\,agc
if=ifc,ifc=*\,agc
if=ifd,ifd=*\,agc
if=ife,ife=*\,agc
if=iff,iff=*\,agc
if=ifg,ifg=*\,agc
if=ifh,ifh=*\,agc
enddef
define  ifman         00000000000x
if=ifa,ifa=*\,man
if=ifb,ifb=*\,man
if=ifc,ifc=*\,man
if=ifd,ifd=*\,man
if=ife,ife=*\,man
if=iff,iff=*\,man
if=ifg,ifg=*\,man
if=ifh,ifh=*\,man
enddef
define  bread         00000000000x
if=bbc001,bbc001
if=bbc002,bbc002
if=bbc003,bbc003
if=bbc004,bbc004
if=bbc005,bbc005
if=bbc006,bbc006
if=bbc007,bbc007
if=bbc008,bbc008
if=bbc009,bbc009
if=bbc010,bbc010
if=bbc011,bbc011
if=bbc012,bbc012
if=bbc013,bbc013
if=bbc014,bbc014
if=bbc015,bbc015
if=bbc016,bbc016
if=bbc017,bbc017
if=bbc018,bbc018
if=bbc019,bbc019
if=bbc020,bbc020
if=bbc021,bbc021
if=bbc022,bbc022
if=bbc023,bbc023
if=bbc024,bbc024
if=bbc025,bbc025
if=bbc026,bbc026
if=bbc027,bbc027
if=bbc028,bbc028
if=bbc029,bbc029
if=bbc030,bbc030
if=bbc031,bbc031
if=bbc032,bbc032
if=bbc033,bbc033
if=bbc034,bbc034
if=bbc035,bbc035
if=bbc036,bbc036
if=bbc037,bbc037
if=bbc038,bbc038
if=bbc039,bbc039
if=bbc040,bbc040
if=bbc041,bbc041
if=bbc042,bbc042
if=bbc043,bbc043
if=bbc044,bbc044
if=bbc045,bbc045
if=bbc046,bbc046
if=bbc047,bbc047
if=bbc048,bbc048
if=bbc049,bbc049
if=bbc050,bbc050
if=bbc051,bbc051
if=bbc052,bbc052
if=bbc053,bbc053
if=bbc054,bbc054
if=bbc055,bbc055
if=bbc056,bbc056
if=bbc057,bbc057
if=bbc058,bbc058
if=bbc059,bbc059
if=bbc060,bbc060
if=bbc061,bbc061
if=bbc062,bbc062
if=bbc063,bbc063
if=bbc064,bbc064
if=bbc065,bbc065
if=bbc066,bbc066
if=bbc067,bbc067
if=bbc068,bbc068
if=bbc069,bbc069
if=bbc070,bbc070
if=bbc071,bbc071
if=bbc072,bbc072
if=bbc073,bbc073
if=bbc074,bbc074
if=bbc075,bbc075
if=bbc076,bbc076
if=bbc077,bbc077
if=bbc078,bbc078
if=bbc079,bbc079
if=bbc080,bbc080
if=bbc081,bbc081
if=bbc082,bbc082
if=bbc083,bbc083
if=bbc084,bbc084
if=bbc085,bbc085
if=bbc086,bbc086
if=bbc087,bbc087
if=bbc088,bbc088
if=bbc089,bbc089
if=bbc090,bbc090
if=bbc091,bbc091
if=bbc092,bbc092
if=bbc093,bbc093
if=bbc094,bbc094
if=bbc095,bbc095
if=bbc096,bbc096
if=bbc097,bbc097
if=bbc098,bbc098
if=bbc099,bbc099
if=bbc100,bbc100
if=bbc101,bbc101
if=bbc102,bbc102
if=bbc103,bbc103
if=bbc104,bbc104
if=bbc105,bbc105
if=bbc106,bbc106
if=bbc107,bbc107
if=bbc108,bbc108
if=bbc109,bbc109
if=bbc110,bbc110
if=bbc111,bbc111
if=bbc112,bbc112
if=bbc113,bbc113
if=bbc114,bbc114
if=bbc115,bbc115
if=bbc116,bbc116
if=bbc117,bbc117
if=bbc118,bbc118
if=bbc119,bbc119
if=bbc120,bbc120
if=bbc121,bbc121
if=bbc122,bbc122
if=bbc123,bbc123
if=bbc124,bbc124
if=bbc125,bbc125
if=bbc126,bbc126
if=bbc127,bbc127
if=bbc128,bbc128
enddef
define  iread         00000000000x
if=ifa,ifa
if=ifb,ifb
if=ifc,ifc
if=ifd,ifd
if=ife,ife
if=iff,iff
if=ifg,ifg
if=ifh,ifh
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
