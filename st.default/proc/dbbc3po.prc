define  caltsys1      00000000000x
ifman
!+2s
tpi=ifa,ifb,ifc,ifd,ife,iff,ifg,ifh
calon
!+2s
tpical=ifa,ifb,ifc,ifd,ife,iff,ifg,ifh
caloff
tpdiff=ifa,ifb,ifc,ifd,ife,iff,ifg,ifh
caltemp=ifa,ifb,ifc,ifd,ife,iff,ifg,ifh
tsys=ifa,ifb,ifc,ifd,ife,iff,ifg,ifh
ifagc
enddef
define  ifagc         18336194801x
ifa=*,agc
ifb=*,agc
ifc=*,agc
ifd=*,agc
ife=*,agc
iff=*,agc
ifg=*,agc
ifh=*,agc
enddef
define  cal_enable    00000000000x
sy=popen 'ncal_en 1 2>&1' -n noise
sy=popen 'noise_gate_en 0 2>&1' -n noise
"sy=popen 'noise_force 1 2>&1' -n noise
cont_cal=off
tpicd=stop
tpicd=no,100
tpicd
enddef
define  reps          00000000000x
fivept=*,$,*,*,*,*
enddef
define  device        00000000000x
fivept=*,*,*,*,*,$
enddef
define  caltsys       18336194740x
ifman
bbc_gain=all,man
!+2s
"tpi=ia,1u,ib,9u,ic,17u,id,25u,ie,33u,if,41u,ig,49u,ih,57u
tpi=all
calon
!+2s
"tpical=ia,1u,ib,9u,ic,17u,id,25u,ie,33u,if,41u,ig,49u,ih,57u
tpical=all
caloff
"tpdiff=ia,1u,ib,9u,ic,17u,id,25u,ie,33u,if,41u,ig,49u,ih,57u
tpdiff=all
"caltemp=ia,1u,ib,9u,ic,17u,id,25u,ie,33u,if,41u,ig,49u,ih,57u
caltemp=all
"tsys=ia,1u,ib,9u,ic,17u,id,25u,ie,33u,if,41u,ig,49u,ih,57u
tsys=all
ifagc
bbc_gain=all,agc
enddef
define  bread         00000000000
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
define  ifman         18336194740
ifa=*,man
ifb=*,man
ifc=*,man
ifd=*,man
ife=*,man
iff=*,man
ifg=*,man
ifh=*,man
enddef
define  caloff        18336194758
"sy=ncal_en 0
"sy=noise_gate_en 0
sy=popen 'noise_force 0 2>&1' -n noise
enddef
define  bbcall        00000000000x
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
define  ifall         00000000000
lo=
lo=loa,0,usb,lcp
lo=lob,0,usb,rcp
lo=loc,7000,lsb,lcp
lo=lod,7000,lsb,rcp
lo=loe,7000,lsb,lcp
lo=lof,7000,lsb,rcp
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
define  dbbc3all      00000000000x
bbcall
ifall
enddef
define  calon         18336194752
"sy=ncal_en 1
"sy=noise_gate_en 0
sy=popen 'noise_force 1 2>&1' -n noise
enddef
define  initp         00000000000x
ifall
bbcall
fivept=azel,1,9,0.4,1,036u
onoff=2,1,,,,,all
enddef
define  calonfp       00000000000
calon
sy=go fivpt &
!+1s
sy=go fivpt &
enddef
define  calofffp      00000000000
caloff
sy=go fivpt &
!+1s
sy=go fivpt &
enddef
define  caloffnf      00000000000
caloff
sy=go onoff &
!+1s
sy=go onoff &
enddef
define  calonnf       00000000000
calon
sy=go onoff &
!+1s
sy=go onoff &
enddef
define  cont_enable   18336194838
sy=popen 'ncal_en 1 2>&1' -n noise
sy=popen 'noise_force 0 2>&1' -n noise
sy=popen 'noise_gate_en 1 2>&1' -n noise
cont_cal=on,2,80,0
tpicd=no,100
tpicd
enddef
define  iread         18336194934x
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
