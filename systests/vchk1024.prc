define  proc_library  04306203751
"proc_library - vchk1024.prc - dls - 07 Feb 2007
enddef               
define  trkchk64      04306205125x
trkchk32
mk5=track_set=102:103;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
enddef
define  auxerr64      04306204642x
auxerr32
mk5=track_set=102:103;
mk5=track_set?
auxerr
mk5=track_set=104:105;
mk5=track_set?
auxerr
mk5=track_set=106:107;
mk5=track_set?
auxerr
mk5=track_set=108:109;
mk5=track_set?
auxerr
mk5=track_set=110:111;
mk5=track_set?
auxerr
mk5=track_set=112:113;
mk5=track_set?
auxerr
mk5=track_set=114:115;
mk5=track_set?
auxerr
mk5=track_set=116:117;
mk5=track_set?
auxerr
mk5=track_set=118:119;
mk5=track_set?
auxerr
mk5=track_set=120:121;
mk5=track_set?
auxerr
mk5=track_set=122:123;
mk5=track_set?
auxerr
mk5=track_set=124:125;
mk5=track_set?
auxerr
mk5=track_set=126:127;
mk5=track_set?
auxerr
mk5=track_set=128:129;
mk5=track_set?
auxerr
mk5=track_set=130:131;
mk5=track_set?
auxerr
mk5=track_set=132:133;
mk5=track_set?
auxerr
decode4=time
enddef
define  bbc4f8        04306204639
bbc01=612.89,a,8.000,8.000
bbc02=652.89,a,8.000,8.000
bbc03=752.89,a,8.000,8.000
bbc04=912.89,a,8.000,8.000
bbc05=652.99,c,8.000,8.000
bbc06=772.99,c,8.000,8.000
bbc07=832.99,c,8.000,8.000
bbc08=852.99,c,8.000,8.000
bbc09=685.89,b,8.000,8.000
bbc10=705.89,b,8.000,8.000
bbc11=725.89,b,8.000,8.000
bbc12=755.89,b,8.000,8.000
bbc13=805.89,b,8.000,8.000
bbc14=825.89,b,8.000,8.000
enddef
define  setup1g       04306205603
"connect the set 1 mark 5a recorder input "
"to the headstack 1 output of the formatter"
"connect the set 2 mark 5a recorder input"
"to the headstack 2 output of the formatter"
form4=/aux 0 0
trkf64
tracks=v0,v1,v2,v3,v4,v5,v6,v7
bbc4fd
ifd4f
form=m,32.000,1:2
mk5=play_rate=data:16;
mk5=mode=mark4:64;
mk5=mode?
bank_check
enddef
define  trkf64        04306204639x
trackform=
trackform=2,1us,6,1um,10,1ls,14,1lm,18,2us,22,2um,26,3us,30,3um
trackform=3,4us,7,4um,11,5us,15,5um,19,6us,23,6um,27,7us,31,7um
trackform=102,8us,106,8um,110,8ls,114,8lm,118,9us,122,9um,126,10us
trackform=130,10um,103,11us,107,11um,111,12us,115,12um,119,13us
trackform=123,13um,127,14us,131,14um
enddef
define  auxerr32      04306203755x
mk5=track_set=2:3;
mk5=track_set?
decode4=time
auxerr
mk5=track_set=4:5;
mk5=track_set?
auxerr
mk5=track_set=6:7;
mk5=track_set?
auxerr
mk5=track_set=8:9;
mk5=track_set?
auxerr
mk5=track_set=10:11;
mk5=track_set?
auxerr
mk5=track_set=12:13;
mk5=track_set?
auxerr
mk5=track_set=14:15;
mk5=track_set?
auxerr
mk5=track_set=16:17;
mk5=track_set?
auxerr
mk5=track_set=18:19;
mk5=track_set?
auxerr
mk5=track_set=20:21;
mk5=track_set?
auxerr
mk5=track_set=22:23;
mk5=track_set?
auxerr
mk5=track_set=24:25;
mk5=track_set?
auxerr
mk5=track_set=26:27;
mk5=track_set?
auxerr
mk5=track_set=28:29;
mk5=track_set?
auxerr
mk5=track_set=30:31;
mk5=track_set?
auxerr
mk5=track_set=32:33;
mk5=track_set?
auxerr
decode4=time
enddef
define  setup512      04306204639
"connect the set 1 mark 5a recorder input "
"to the headstack 1 output of the formatter"
"connect the set 2 mark 5a recorder input"
"to the headstack 2 output of the formatter"
form4=/aux 0 0
trkf64
tracks=v0,v1,v2,v3,v4,v5,v6,v7
bbc4f8
"ifd4f
form=m,16.000,1:2
mk5=play_rate=data:8;
mk5=mode=mark4:64;
mk5=mode?
bank_check
enddef
define  trkchk32      04306204219x
mk5=track_set=2:3;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
mk5=track_set=inc;
mk5=track_check?
enddef
define  auxerr        04306203755x
decode4=aux
decode4=dqa clear
!+1s
decode4=dqa
enddef
define  recscan       04306203815x
"recscan=<duration>
mk5=play=off;
!*
disk_pos
disk_record=on
midob
!*+$
disk_pos
disk_record=off
!+1s
postob
enddef
define  get_stats8    04306210940x
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
mk5=get_stats?
"mk5=start_stats;
enddef
define  postob        04306204218
form
disk_pos
mk5=mode?
mk5=rtime?
scan_check
enddef
define  midob         04306203818
bread
form
sy=run setcl &
mk5=play_rate?
mk5=mode?
mk5=status?
disk_pos
enddef
define  exper_initi   04306203751
"exper_initi - dls - 2003 september 29
proc_library
sched_initi
mk5=dts_id?
mk5=os_rev1?
mk5=os_rev2?
mk5=ss_rev1?
mk5=ss_rev2?
mk5=status?
mk5=bank_set?
mk5=disk_size?
mk5=disk_model?
mk5=dir_info?
bank_check
disk_pos
!+1s
enddef
define  setup4f       04306203752
"connect the set 1 mark 5a recorder input "
"to the headstack 1 output of the formatter"
form4=/aux 0 0
trkf4f
tracks=v0,v1,v2,v3
bbc4fd
ifd4f
form=m,32.000,1:2
mk5=play_rate=data:16;
mk5=mode=mark4:32;
mk5=mode?
bank_check
enddef
define  bbc4fd        04306203752x
bbc01=612.99,a,16.000,16.000
bbc02=652.99,a,16.000,16.000
bbc03=752.99,a,16.000,16.000
bbc04=912.99,a,16.000,16.000
bbc05=632.99,c,16.000,16.000
bbc06=752.99,c,16.000,16.000
bbc07=812.99,c,16.000,16.000
bbc08=832.99,c,16.000,16.000
bbc09=732.99,b,16.000,16.000
bbc10=740.99,b,16.000,16.000
bbc11=756.99,b,16.000,16.000
bbc12=812.99,b,16.000,16.000
bbc13=844.99,b,16.000,16.000
bbc14=852.99,b,16.000,16.000
enddef
define  ifd4f         04306203753
"ifdab=0,0,nor,nor
"ifdcd=0,0,nor,nor
"lo=
"lo=loa,7600.00,usb,rcp,1
"lo=lob,1500.00,usb,rcp,1
"lo=loc,8100.00,usb,rcp,1
enddef
define  trkf4f        04306203752
trackform=
trackform=2,1us,6,1ls,10,2us,14,3us,18,4us,22,5us,26,6us,30,7us
trackform=3,8us,7,8ls,11,9us,15,10us,19,11us,23,12us,27,13us
trackform=31,14us
enddef
