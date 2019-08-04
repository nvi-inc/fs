define  checkmk5      000000000000
scan_check
mk5_status
mk5=net_protocol?
mk5=mtu?
mk5=rtime?
chk_vgos_ddc
enddef
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
define  inputwidth    00000000000
dbbc3=core3h=1,vsi_inputwidth
dbbc3=core3h=2,vsi_inputwidth
dbbc3=core3h=3,vsi_inputwidth
dbbc3=core3h=4,vsi_inputwidth
dbbc3=core3h=5,vsi_inputwidth
dbbc3=core3h=6,vsi_inputwidth
dbbc3=core3h=7,vsi_inputwidth
dbbc3=core3h=8,vsi_inputwidth
enddef
define  bitmask       00000000000
dbbc3=core3h=1,vsi_bitmask
dbbc3=core3h=2,vsi_bitmask
dbbc3=core3h=3,vsi_bitmask
dbbc3=core3h=4,vsi_bitmask
dbbc3=core3h=5,vsi_bitmask
dbbc3=core3h=6,vsi_bitmask
dbbc3=core3h=7,vsi_bitmask
dbbc3=core3h=8,vsi_bitmask
enddef
define  caltsys       00000000000x
ifman
bbc_gain=all,man
!+2s
tpi=all
calon
!+2s
tpical=all
caloff
tpdiff=all
caltemp=all
tsys=all
ifagc
bbc_gain=all,agc
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
iftpa
iftpb
iftpc
iftpd
iftpe
iftpf
iftpg
iftph
enddef
define  bbcall        19136134334x
bbc001=3480.4,a,32,1
bbc002=3448.4,a,32,1
bbc003=3384.4,a,32,1
bbc004=3320.4,a,32,1
bbc005=3224.4,a,32,1
bbc006=3096.4,a,32,1
bbc007=3064.4,a,32,1
bbc008=3032.4,a,32,1
bbc009=3480.4,b,32,1
bbc010=3448.4,b,32,1
bbc011=3384.4,b,32,1
bbc012=3320.4,b,32,1
bbc013=3224.4,b,32,1
bbc014=3096.4,b,32,1
bbc015=3064.4,b,32,1
bbc016=3032.4,b,32,1
bbc017=1979.6,c,32,1
bbc018=2011.6,c,32,1
bbc019=2075.6,c,32,1
bbc020=2139.6,c,32,1
bbc021=2235.6,c,32,1
bbc022=2363.6,c,32,1
bbc023=2395.6,c,32,1
bbc024=2427.6,c,32,1
bbc025=1979.6,d,32,1
bbc026=2011.6,d,32,1
bbc027=2075.6,d,32,1
bbc028=2139.6,d,32,1
bbc029=2235.6,d,32,1
bbc030=2363.6,d,32,1
bbc031=2395.6,d,32,1
bbc032=2427.6,d,32,1
bbc033=859.6,e,32,1
bbc034=891.6,e,32,1
bbc035=955.6,e,32,1
bbc036=1019.6,e,32,1
bbc037=1115.6,e,32,1
bbc038=1243.6,e,32,1
bbc039=1275.6,e,32,1
bbc040=1307.6,e,32,1
bbc041=859.6,f,32,1
bbc042=891.6,f,32,1
bbc043=955.6,f,32,1
bbc044=1019.6,f,32,1
bbc045=1115.6,f,32,1
bbc046=1243.6,f,32,1
bbc047=1275.6,f,32,1
bbc048=1307.6,f,32,1
bbc049=919.6,g,32,1
bbc050=951.6,g,32,1
bbc051=1015.6,g,32,1
bbc052=1079.6,g,32,1
bbc053=1175.6,g,32,1
bbc054=1303.6,g,32,1
bbc055=1335.6,g,32,1
bbc056=1367.6,g,32,1
bbc057=919.6,h,32,1
bbc058=951.6,h,32,1
bbc059=1015.6,h,32,1
bbc060=1079.6,h,32,1
bbc061=1175.6,h,32,1
bbc062=1303.6,h,32,1
bbc063=1335.6,h,32,1
bbc064=1367.6,h,32,1
enddef
define  ifall         19142173057x
lo=
lo=loa,0,usb,lcp
lo=lob,0,usb,rcp
lo=loc,7700,lsb,lcp
lo=lod,7700,lsb,rcp
lo=loe,7700,lsb,lcp
lo=lof,7700,lsb,rcp
lo=log,11600,lsb,lcp
lo=loh,11600,lsb,rcp
ifa=2,agc
ifb=2,agc
ifc=2,agc
ifd=2,agc
ife=2,agc
iff=2,agc
ifg=2,agc
ifh=2,agc
enddef
define  setuppnt      19136134334x
bbcall
ifall
enddef
define  caloff        19136134409
sy=popen 'noise_force 0 2>&1' -n noise
enddef
define  calon         19136134414
sy=popen 'noise_force 1 2>&1' -n noise
enddef
define  cont_enable   00000000000
sy=popen 'ncal_en 1 2>&1' -n noise
sy=popen 'noise_force 0 2>&1' -n noise
sy=popen 'noise_gate_en 1 2>&1' -n noise
cont_cal=on,2,80,0
tpicd=stop
tpicd=no,100
tpicd
enddef
define  cal_enable    19136133814
sy=popen 'ncal_en 1 2>&1' -n noise
sy=popen 'noise_gate_en 0 2>&1' -n noise
sy=popen 'noise_force 0 2>&1' -n noise
cont_cal=off
tpicd=stop
tpicd=no,100
tpicd
enddef
define  exper_initi   19142124123
sched_initi
enddef
define  sched_initi   19142173034
dbbc3=version
dbbc3=core3h=1,version
dbbc3=core3h=2,version
dbbc3=core3h=3,version
dbbc3=core3h=4,version
dbbc3=core3h=5,version
dbbc3=core3h=6,version
dbbc3=core3h=7,version
dbbc3=core3h=8,version
enddef
define  sched_end     19137155951x
"fila10g=stop
"!+3s
"sy=exec lgput `lognm`.log od &
enddef
define  initi         19136133814x
"welcome to the pc field system
"sy=run setcl &
"azeloff=0d,0d
"dbbc=time_raw=1
"uncomment to default to continuous cal and comment out non-continuous
"cont_enable
"uncomment to default to non-continuous cal and comment out continuous
cal_enable
"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" comment on timing:
"- - - - - - - - - -
" we report 'maser-fmout' for each core3h board of the dbbc3
" with the command 'pps_delay'
" we also report 'gps-maser' with the command 'clock'
" thus, 'gps-maser' + 'maser-fmout' = 'gps-fmout'
"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
enddef
define  midob         19142180000
onsource
wx
sy=cdms_delay
cable
" the shown order of the commands from here to the end of this procedure is
" strongly recommended
"add your station command to measure the gps to fm output clock offset
"gps-fmout=c2
"----------
"iread
"bread
"samplerate
"bitmask
"inputwidth
"----------
dbbc3=time
clock
dbbc3=pps_delay
!+1s
mk5=record?
mk5=evlbi?
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
define  postob        19142180031x
wx
mk5=evlbi?
mk5=rtime?
dbbc3=time
clock
dbbc3=pps_delay
sy=cdms_delay
enddef
define  preob         19142175956
sy=cdms_delay
wx
onsource
enddef
define  ready_disk    00000000000x
enddef
define  pcalon        00000000000
"no phase cal control is implemented here
enddef
define  pcaloff       00000000000x
"no phase cal control is implemented here
enddef
define  greplog       00000000000x
sy=xterm -name greplog -e sh -c 'grep -i $ /usr2/log/`lognm`.log|less' &
enddef
define  fb_dbbc3      00000000000x
mk5=mode = vdif_8000-data_rate_mbps-channels-bits_per_channel :
mk5=mtu = 8192 ;
mk5=net_protocol = udps : 32000000 : 256000000 : 4 ;
enddef
define  dbbc_ifall    00000000000x
ifa
ifb
ifc
ifd
ife
iff
ifg
ifh
enddef
define  dbbc_collect  00000000000x
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
define  chk_vgos_ddc  19142175340x
mk5=scan_set?
mk5=scan_set=:-0.2s:+0.2s
mk5=disk2file=/data/check_data/ott-n/vgos_ddc_8_8.dat:::w
"mk5=disk2file=/data/check_data/vgos_ddc_8_8.dat:::w
!+5s
mk5=disk2file?
"disk2file=abort
sy=/usr2/oper/bin/check_vgos_ddc &
enddef
define  dbbcstress    00000000000x
dbbc_ifall@!,15s
dbbc_collect@!,15s
dbbc3=time@!,15s
dbbc3=pps_delay@!,15s
enddef
define  samplerate    00000000000
dbbc3=core3h=1,vsi_samplerate
dbbc3=core3h=2,vsi_samplerate
dbbc3=core3h=3,vsi_samplerate
dbbc3=core3h=4,vsi_samplerate
dbbc3=core3h=5,vsi_samplerate
dbbc3=core3h=6,vsi_samplerate
dbbc3=core3h=7,vsi_samplerate
dbbc3=core3h=8,vsi_samplerate
enddef
define  stresstest    00000000000x
dbbc3=pps_delay
dbbc3=time
dbbc_ifall
dbbc_collect
wx
enddef
