*command     seg sbpa bo eq
form         qkr 0101 01 001FFFFFF
form4        qkr 0102 01 FFFFFFFFF
decode4      qkr 0103 01 FFFFFFFFF
vc01         qkr 0201 01 205FFFFFF
vc02         qkr 0202 01 205FFFFFF
vc03         qkr 0203 01 205FFFFFF
vc04         qkr 0204 01 205FFFFFF
vc05         qkr 0205 01 205FFFFFF
vc06         qkr 0206 01 205FFFFFF
vc07         qkr 0207 01 205FFFFFF
vc08         qkr 0208 01 205FFFFFF
vc09         qkr 0209 01 205FFFFFF
vc10         qkr 0210 01 205FFFFFF
vc11         qkr 0211 01 205FFFFFF
vc12         qkr 0212 01 205FFFFFF
vc13         qkr 0213 01 205FFFFFF
vc14         qkr 0214 01 205FFFFFF
vc15         qkr 0215 01 205FFFFFF
ifd          qkr 0301 01 205FFFFFF
if3          qkr 0302 01 205FFFFFF
mat          qkr 0401 01 FFFFFFFFF
hpib         qkr 0402 01 FFFFFFFFF
wx           qkr 0404 01 FFFFFFFFF
wakeup       qkr 0405 01 FFFFFFFFF
check        qkr 0406 01 FFFFFFFFF
cal          qkr 0407 01 FFFFFFFFF
antenna      qkr 0408 01 FFFFFFFFF
tape         qk1 0501 01 FFF005FFF
tape1        qk3 0501 01 FFF005FFF
tapepos      qk1 0502 01 FFF005FFF
tapepos1     qk3 0502 01 FFF005FFF
tape         qk2 0511 01 FFFFFF005
tape2        qk3 0511 01 FFFFFF005
tapepos      qk2 0512 01 FFFFFF005
tapepos2     qk3 0512 01 FFFFFF005
st           qk1 0601 01 FFF005FFF
st1          qk3 0601 01 FFF005FFF
et           qk1 0602 01 FFF017FFF
et1          qk3 0602 01 FFF017FFF
rw           qk1 0603 01 FFF017FFF
rw1          qk3 0603 01 FFF017FFF
ff           qk1 0604 01 FFF017FFF
ff1          qk3 0604 01 FFF017FFF
srw          qk1 0605 01 FFF017FFF
srw1         qk3 0605 01 FFF017FFF
sff          qk1 0606 01 FFF017FFF
sff1         qk3 0606 01 FFF017FFF
rec          qk1 0607 01 FFF005FFF
rec1         qk3 0607 01 FFF005FFF
st           qk2 0611 01 FFFFFF005
st2          qk3 0611 01 FFFFFF005
et           qk2 0612 01 FFFFFF017
et2          qk3 0612 01 FFFFFF017
rw           qk2 0613 01 FFFFFF017
rw2          qk3 0613 01 FFFFFF017
ff           qk2 0614 01 FFFFFF017
ff2          qk3 0614 01 FFFFFF017
srw          qk2 0615 01 FFFFFF017
srw2         qk3 0615 01 FFFFFF017
sff          qk2 0616 01 FFFFFF017
sff2         qk3 0616 01 FFFFFF017
rec          qk2 0617 01 FFFFFF005
rec2         qk3 0617 01 FFFFFF005
reset        qkr 0701 01 FFFFFFFFF
newtape      qk1 0702 01 FFF05FFFF
newtape1     qk3 0702 01 FFF05FFFF
label        qk1 0703 01 FFF017FFF
label1       qk3 0703 01 FFF017FFF
matload      qkr 0704 01 FFFFFFFFF
mount1       qk3 0705 01 FFF017FFF
newtape      qk2 0712 01 FFFFFF05F
newtape2     qk3 0712 01 FFFFFF05F
label        qk2 0713 01 FFFFFF017
label2       qk3 0713 01 FFFFFF017
mount2       qk3 0715 01 FFFFFF017
enable       qk1 0801 01 FFF005FFF
enable1      qk3 0801 01 FFF005FFF
enable       qk2 0802 01 FFFFFF005
enable2      qk3 0802 01 FFFFFF005
decode       qkr 0901 01 FFFFFFFFF
perr         qk1 0902 01 FFF001FFF
perr1        qk3 0902 01 FFF001FFF
parity       qk1 0903 01 0D7017FFF
parity1      qk3 0903 01 0D7017FFF
perr         qk2 0912 01 FFFFFF001
perr2        qk3 0912 01 FFFFFF001
parity       qk2 0913 01 0D7FFF017
parity2      qk3 0913 01 0D7FFF017
repro        qk1 1001 01 FFF001FFF
repro1       qk3 1001 01 FFF001FFF
repro        qk1 1002 01 FFF004FFF
repro1       qk3 1002 01 FFF004FFF
repro        qk2 1011 01 FFFFFF001
repro2       qk3 1011 01 FFFFFF001
repro        qk2 1012 01 FFFFFF004
repro2       qk3 1012 01 FFFFFF004
source       qkr 1101 01 FFFFFFFFF
radecoff     qkr 1102 01 FFFFFFFFF
azeloff      qkr 1103 01 FFFFFFFFF
onsource     qkr 1104 01 FFFFFFFFF
xyoff        qkr 1106 01 FFFFFFFFF
track        qkr 1107 01 FFFFFFFFF
tpi          qkr 1203 01 FFFFFFFFF
tpical       qkr 1204 01 FFFFFFFFF
tsys         qkr 1205 01 FFFFFFFFF
tpdiff       qkr 1206 01 FFFFFFFFF
tpzero       qkr 1207 01 FFFFFFFFF
tpgain       qkr 1208 01 012FFFFFF
tpdiffgain   qkr 1209 01 012FFFFFF
caltemp      qkr 1210 01 FFFFFFFFF
cable        qkr 1304 01 FFFFFFFFF
pcal         qkr 1401 01 001001FFF
patch        qkr 1403 01 2E5FFFFFF
*pcals        qkr 1404 01 11
*logout       qkr 1501 01 77
op           qkr 1502 01 FFFFFFFFF
fivept       qkr 1503 01 FFFFFFFFF
*onoff        qkr 1504 01 FFFFFF
*pc           qkr 1505 01 FF
fsversion    qkr 1506 01 FFFFFFFFF
rx           qkr 1601 01 FFFFFFFFF
*head         qkr 1701 01 77
tapeform     qk1 1801 01 FFF017FFF
tapeform1    qk3 1801 01 FFF017FFF
tapeform     qk2 1802 01 FFFFFF017
tapeform2    qk3 1802 01 FFFFFF017
pass         qk1 2101 01 FFF017FFF
pass1        qk3 2101 01 FFF017FFF
stack        qk1 2102 01 FFF017FFF
stack1       qk3 2102 01 FFF017FFF
lvdt         qk1 2103 01 FFF017FFF
lvdt1        qk3 2103 01 FFF017FFF
peak         qk1 2104 01 FFF017FFF
peak1        qk3 2104 01 FFF017FFF
savev        qk1 2105 01 FFF017FFF
savev1       qk3 2105 01 FFF017FFF
hdcalc       qk1 2106 01 FFF017FFF
hdcalc1      qk3 2106 01 FFF017FFF
hecho        qkr 2107 01 FFF017FFF
locate       qk1 2108 01 FFF017FFF
locate1      qk3 2108 01 FFF017FFF
worm         qk1 2109 01 FFF017FFF
worm1        qk3 2109 01 FFF017FFF
hdata        qk1 2110 01 FFF017FFF
hdata1       qk3 2110 01 FFF017FFF
pass         qk2 2111 01 FFFFFF017
pass2        qk3 2111 01 FFFFFF017
stack        qk2 2112 01 FFFFFF017
stack2       qk3 2112 01 FFFFFF017
lvdt         qk2 2113 01 FFFFFF017
lvdt2        qk3 2113 01 FFFFFF017
peak         qk2 2114 01 FFFFFF017
peak2        qk3 2114 01 FFFFFF017
savev        qk2 2115 01 FFFFFF017
savev2       qk3 2115 01 FFFFFF017
hdcalc       qk2 2116 01 FFFFFF017
hdcalc2      qk3 2116 01 FFFFFF017
locate       qk2 2118 01 FFFFFF017
locate2      qk3 2118 01 FFFFFF017
worm         qk2 2119 01 FFFFFF017
worm2        qk3 2119 01 FFFFFF017
hdata        qk2 2120 01 FFFFFF017
hdata2       qk3 2120 01 FFFFFF017
ifdab        qkr 2201 01 012FFFFFF
ifdcd        qkr 2202 01 012FFFFFF
repro        qk1 2301 01 FFF012FFF
repro1       qk3 2301 01 FFF012FFF
repro        qk2 2302 01 FFFFFF012
repro2       qk3 2302 01 FFFFFF012
bbc01        qkr 2401 01 012FFFFFF
bbc02        qkr 2402 01 012FFFFFF
bbc03        qkr 2403 01 012FFFFFF
bbc04        qkr 2404 01 012FFFFFF
bbc05        qkr 2405 01 012FFFFFF
bbc06        qkr 2406 01 012FFFFFF
bbc07        qkr 2407 01 012FFFFFF
bbc08        qkr 2408 01 012FFFFFF
bbc09        qkr 2409 01 012FFFFFF
bbc10        qkr 2410 01 012FFFFFF
bbc11        qkr 2411 01 012FFFFFF
bbc12        qkr 2412 01 012FFFFFF
bbc13        qkr 2413 01 012FFFFFF
bbc14        qkr 2414 01 012FFFFFF
form         qkr 2501 01 002FFFFFF
vform        qkr 2501 01 FFFFFFFFF
enable       qk1 2601 01 FFF012FFF
enable1      qk3 2601 01 FFF012FFF
enable       qk2 2602 01 FFFFFF012
enable2      qk3 2602 01 FFFFFF012
capture      qkr 2701 01 002FFFFFF
dqa          qkr 2801 01 002FFFFFF
vdqa         qkr 2801 01 FFFFFFFFF
tape         qk1 2901 01 FFF012FFF
tape1        qk3 2901 01 FFF012FFF
tape         qk2 2902 01 FFFFFF012
tape2        qk3 2902 01 FFFFFF012
st           qk1 3001 01 FFF012FFF
st1          qk3 3001 01 FFF012FFF
st           qk2 3002 01 FFFFFF012
st2          qk3 3002 01 FFFFFF012
rec          qk1 3101 01 FFF012FFF
rec1         qk3 3101 01 FFF012FFF
rec          qk2 3102 01 FFFFFF012
rec2         qk3 3102 01 FFFFFF012
mcb          qkr 3201 01 FFFFFFFFF
trackform    qkr 3301 01 002FFFFFF
tracks       qkr 3401 01 002FFFFFF
bit_density  qk1 3501 01 FFF012FFF
bit_density1 qk3 3501 01 FFF012FFF
bit_density  qk2 3502 01 FFFFFF012
bit_density2 qk3 3502 01 FFFFFF012
systracks    qk1 3601 01 FFF012FFF
systracks1   qk3 3601 01 FFF012FFF
systracks    qk2 3602 01 FFFFFF012
systracks2   qk3 3602 01 FFFFFF012
rcl          qkr 3701 01 FFFFFFFFF
user_info    qk1 3801 01 FFF008FFF
user_info1   qk3 3801 01 FFF008FFF
st           qk1 3901 01 FFF008FFF
st1          qk3 3901 01 FFF008FFF
et           qk1 4001 01 FFF008FFF
et1          qk3 4001 01 FFF008FFF
rw           qk1 4002 01 FFF008FFF
rw1          qk3 4002 01 FFF008FFF
ff           qk1 4003 01 FFF008FFF
ff1          qk3 4003 01 FFF008FFF
tape         qk1 4101 01 FFF008FFF
tape1        qk3 4101 01 FFF008FFF
rec_mode     qk1 4201 01 FFF008FFF
rec_mode1    qk3 4201 01 FFF008FFF
data_valid   qk1 4301 01 FFFFFFFFF
data_valid1  qk3 4301 01 FFFFFFFFF
data_valid   qk2 4302 01 FFFFFFFFF
data_valid2  qk3 4302 01 FFFFFFFF7
data_valid   qkr 4300 01 FFFFFFFF7
label        qk1 4401 01 FFF008FFF
label1       qk3 4401 01 FFF008FFF
rec          qk1 4501 01 FFF008FFF
rec1         qk3 4501 01 FFF008FFF
form         qkr 4601 01 054FFFFFF
4form        qkr 4601 01 FFFFFFFFF
tracks       qkr 4701 01 054FFFFFF
4tracks      qkr 4701 01 FFFFFFFFF
trackform    qkr 4801 01 054FFFFFF
4trackform   qkr 4801 01 FFFFFFFFF
rvac         qk1 4901 01 FFF012FFF
rvac1        qk3 4901 01 FFF012FFF
rvac         qk2 4902 01 FFFFFF012
rvac2        qk3 4902 01 FFFFFF012
wvolt        qk1 5001 01 FFF012FFF
wvolt1       qk3 5001 01 FFF012FFF
wvolt        qk2 5002 01 FFFFFF012
wvolt2       qk3 5002 01 FFFFFF012
lo           qkr 5101 01 3F7FFFFFF
user_device  qkr 5102 01 FFFFFFFFF
pcalform     qkr 5201 01 FFFFFFFFF
pcald        qkr 5301 01 217FFFFFF
pcalports    qkr 5401 01 254FFFFFF
save_file    qkr 5501 01 FFFFFFFFF
*k4 commands
k4ib         qkr 5601 01 FFFFFFFFF
et           qk1 5701 01 FFF020FFF
et1          qk3 5701 01 FFF020FFF
rw           qk1 5702 01 FFF020FFF
rw1          qk3 5702 01 FFF020FFF
ff           qk1 5703 01 FFF020FFF
ff1          qk3 5703 01 FFF020FFF
st           qk1 5801 01 FFF020FFF
st1          qk3 5801 01 FFF020FFF
tape         qk1 5901 01 FFF020FFF
tape1        qk3 5901 01 FFF020FFF
rec          qk1 6001 01 FFF020FFF
rec1         qk3 6001 01 FFF020FFF
valo         qkr 6101 01 0E0FFFFFF
vblo         qkr 6102 01 0E0FFFFFF
vclo         qkr 6103 01 0E0FFFFFF
va           qkr 6201 01 0E0FFFFFF
vb           qkr 6202 01 0E0FFFFFF
vc           qkr 6203 01 0E0FFFFFF
vcif         qkr 6301 01 0E0FFFFFF
vabw         qkr 6401 01 0E0FFFFFF
vbbw         qkr 6402 01 0E0FFFFFF
vcbw         qkr 6403 01 0E0FFFFFF
form         qkr 6501 01 080FFFFFF
newtape      qk1 6601 01 FFF020FFF
newtape1     qk3 6601 01 FFF020FFF
label        qk1 6701 01 FFF020FFF
label1       qk3 6701 01 FFF020FFF
oldtape      qk1 6801 01 FFF020FFF
oldtape1     qk3 6801 01 FFF020FFF
rec_mode     qk1 6901 01 FFF020FFF
rec_mode1    qk3 6901 01 FFF020FFF
*this recpatch only for non-k4 rec 1
recpatch     qkr 7001 01 FFF0DFFFF
recpatch     qk1 7001 01 FFF020FFF
recpatch1    qk3 7001 01 FFF020FFF
*this k4pcalports only for non-k4 rec 1
k4pcalports  qkr 7101 01 FFF0DFFFF
k4pcalports  qk1 7101 01 FFF020FFF
k4pcalports1 qk3 7101 01 FFF020FFF
*
select       qkr 7201 01 FFFFFFFFF
scan_name    qkr 7301 01 FFFFFFFFF
ifadjust     qkr 7401 01 205FFFFFF
tacd         qkr 7501 01 FFFFFFFFF
cablelong    qkr 7604 01 FFFFFFFFF
cablediff    qkr 7701 01 FFFFFFFFF
mk5          qkr 7800 01 FFFFFFFFF
disk_record  qkr 7801 01 FFFFFFFFF
disk_pos     qkr 7802 01 FFFFFFFFF
disk_serial  qkr 7803 01 FFFFFFFFF
data_check   qkr 7804 01 FFFFFFFFF
mk5relink    qkr 7805 01 FFFFFFFFF
mk5close     qkr 7806 01 FFFFFFFFF
bank_check   qkr 7807 01 FFFFFFFFF
bank_status  qkr 7808 01 FFFFFFFFF
disk2file    qkr 7809 01 FFFFFFFFF
in2net       qkr 7810 01 FFFFFFFFF
scan_check   qkr 7811 01 FFFFFFFFF
rollform     qkr 7901 01 254FFFFFF
tpicd        qkr 8001 01 FFFFFFFFF
onoff        qkr 8101 01 FFFFFFFFF
calrx        qkr 8201 01 317FFFFFF
*lba commands
ds           qkr 8301 01 FFFFFFFFF
ifp01        qkr 8401 01 300FFFFFF
ifp02        qkr 8402 01 300FFFFFF
ifp03        qkr 8403 01 300FFFFFF
ifp04        qkr 8404 01 300FFFFFF
cor01        qkr 8501 01 300FFFFFF
cor02        qkr 8502 01 300FFFFFF
cor03        qkr 8503 01 300FFFFFF
cor04        qkr 8504 01 300FFFFFF
mon01        qkr 8601 01 300FFFFFF
mon02        qkr 8602 01 300FFFFFF
mon03        qkr 8603 01 300FFFFFF
mon04        qkr 8604 01 300FFFFFF
ft01         qkr 8701 01 300FFFFFF
ft02         qkr 8702 01 300FFFFFF
ft03         qkr 8703 01 300FFFFFF
ft04         qkr 8704 01 300FFFFFF
trackform    qkr 8801 01 300FFFFFF
* s2das commands
bbc1         qkr 9001 01 008FFFFFF
bbc2         qkr 9002 01 008FFFFFF
bbc3         qkr 9003 01 008FFFFFF
bbc4         qkr 9004 01 008FFFFFF
agc          qkr 9100 01 008FFFFFF
diag         qkr 9101 01 008FFFFFF
encode       qkr 9102 01 008FFFFFF
fs           qkr 9103 01 008FFFFFF
ifx          qkr 9104 01 008FFFFFF
s2version    qkr 9105 01 FFFFFFFFF
mode         qkr 9106 01 008FFFFFF
s2ping       qkr 9107 01 FFFFFFFFF
pwrmon       qkr 9108 01 008FFFFFF
s2status     qkr 9109 01 008FFFFFF
s2check      qkr 9110 01 008FFFFFF
s2delays     qkr 9111 01 008FFFFFF
errmsg       qkr 9200 01 008FFFFFF
stamsg       qkr 9201 01 008FFFFFF
tonedet      qkr 9300 01 008FFFFFF
tonemeas     qkr 9301 01 008FFFFFF
* boss internal
cont         *xx 0000 02 FFFFFFFFF
halt         *xx 0000 03 FFFFFFFFF
log          xxx 0000 04 FFFFFFFFF
schedule     xxx 0000 05 FFFFFFFFF
xlog         *xx 0000 06 FFFFFFFFF
xdisp        *xx 0000 07 FFFFFFFFF
echo         *xx 0000 08 FFFFFFFFF
*break        *xx 0000 14 77FF
terminate    *xx 0000 10 FFFFFFFFF
flush        *xx 0000 11 FFFFFFFFF
sy           *xx 0000 12 FFFFFFFFF
ti           *xx 0000 13 FFFFFFFFF
proc         xxx 0000 15 FFFFFFFFF
list         *xx 0000 16 FFFFFFFFF
status       *xx 0000 17 FFFFFFFFF
help         *xx 0000 18 FFFFFFFFF
?            *xx 0000 18 FFFFFFFFF
date         *xx 0000 19 FFFFFFFFF
op_stream    *xx 0000 20 FFFFFFFFF
tnx          *xx 0000 21 FFFFFFFFF
