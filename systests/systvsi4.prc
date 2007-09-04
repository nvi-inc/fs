define  tpisamp       00000000000
"tpisamp
!+2s
"these two lines for mark III/IV racks
tpi=formvc,formif
tsys=formvc,formif
"these two lines for vlba/4 racks
"tpi=formbbc,formif
"tsys=formbbc,formif
"these two lines for station specific detectors
"tpi=u5,u6
"tsys=u5,u6
enddef
define  bbcmanx       00000000000
"bbcmanx
"for VLBA/4 racks, bbcmanz is required
"for other racks, comment it out
"bbcmanz
enddef
define  bbcagcx       00000000000
"bbcagcx
"for VLBA/4 racks, bbcagcz is required
"for other racks, comment it out
"bbcagcz
enddef
define  pcalonsys     00000000000
"pcalonsys
xdisp=on
"turn pcal on
"pick one of fs.prompt or local computer control
"fs.prompt
sy=fs.prompt 'please turn pcal on'
"local computer control
"for kokee
"phon
xdisp=off
enddef
define  pcaloffsys    00000000000x
"pcaloffsys
xdisp=on
"turn pcal off
"pick one of fs.prompt or local computer control
"fs.prompt
sy=fs.prompt 'please turn pcal off'
"local computer control
"for kokee
"phoff
xdisp=off
enddef
define  lounlocksys   00000000000x
"lounlocksys
xdisp=on
"turn pcal on and unlock lo
"pick one of fs.prompt or local computer control
"fs.prompt
sy=fs.prompt 'please turn pcal on and unlock lo'
"local computer control
"something here
xdisp=off
enddef
define  pcal5moffsys  00000000000x
"pcal5moffsys
xdisp=on
"relock lo and turn pcal 5Mhz off
"pick one of fs.prompt or local computer control
"fs.prompt
sy=fs.prompt 'please relock lo and turn pcal 5mhz off'
"local computer control
"something here
xdisp=off
enddef
define  pcal5monsys   00000000000x
"pcal5monsys
xdisp=on
"turn pcal 5mhz on
"pick one of fs.prompt or local computer control
"fs.prompt
sy=fs.prompt 'please turn pcal 5mhz on'
"local computer control
"something here
xdisp=off
enddef
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
define  bbcagcz       00000000000
"bbcagcz
bbc01=*,*,*,*,*,agc
bbc02=*,*,*,*,*,agc
bbc03=*,*,*,*,*,agc
bbc04=*,*,*,*,*,agc
bbc05=*,*,*,*,*,agc
bbc06=*,*,*,*,*,agc
bbc07=*,*,*,*,*,agc
bbc08=*,*,*,*,*,agc
bbc09=*,*,*,*,*,agc
bbc10=*,*,*,*,*,agc
bbc11=*,*,*,*,*,agc
bbc12=*,*,*,*,*,agc
bbc13=*,*,*,*,*,agc
bbc14=*,*,*,*,*,agc
enddef
define  bbcmanz       00000000000
"bbcmanz
bbc01=*,*,*,*,*,man
bbc02=*,*,*,*,*,man
bbc03=*,*,*,*,*,man
bbc04=*,*,*,*,*,man
bbc05=*,*,*,*,*,man
bbc06=*,*,*,*,*,man
bbc07=*,*,*,*,*,man
bbc08=*,*,*,*,*,man
bbc09=*,*,*,*,*,man
bbc10=*,*,*,*,*,man
bbc11=*,*,*,*,*,man
bbc12=*,*,*,*,*,man
bbc13=*,*,*,*,*,man
bbc14=*,*,*,*,*,man
enddef
define  bbcman        00000000000
"bbcman
"empty on purpose
enddef
define  bbcagc        00000000000
"bbcagc
"empty on purpose
enddef
define  pcalofftpi    00000000000
"pcalofftpi
pcaloffsys
tpisamp
enddef
define  pcalontpi     00000000000
"pcalontpi
pcalonsys
tpisamp
enddef
define  pcalall       00000000000x
"pcalall
pcalsamp=1,5
pcalsamp=2,6
pcalsamp=3,7
pcalsamp=4,8
pcalsamp=9,13
pcalsamp=10,14
pcalsamp=11,15
pcalsamp=12,16
enddef
define  pcalimagel    00000000000x
"pcalimagel
pcalsampil=1,5
pcalsampil=2,6
pcalsampil=3,7
pcalsampil=4,8
pcalsampil=9,13
pcalsampil=10,14
pcalsampil=11,15
pcalsampil=12,16
enddef
define  pcalimageu    00000000000x
"pcalimageu
pcalsampiu=1,5
pcalsampiu=2,6
pcalsampiu=3,7
pcalsampiu=4,8
pcalsampiu=9,13
pcalsampiu=10,14
pcalsampiu=11,15
pcalsampiu=12,16
enddef
define  statsamp      05183161424x
"statsamp
xdisp=on
vsi4=,$
xdisp=off
statx
staty
enddef
define  pcalsamp      00000000000x
"pcalsamp
xdisp=on
vsi4=,$
xdisp=off
pcalx
pcaly
enddef
define  pcalsampil    00000000000x
"pcalsampil
xdisp=on
vsi4=,$
xdisp=off
pcalxil
pcalyil
enddef
define  pcalsampiu    00000000000x
"pcalsampiu
xdisp=on
vsi4=,$
xdisp=off
pcalxiu
pcalyiu
enddef
define  pcalx         05184234333x
"pcalx
decode4=pcal usbx   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal usbx 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
decode4=pcal lsbx  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal lsbx 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
enddef
define  pcaly         00000000000x
"pcaly
decode4=pcal usby   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal usby 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
decode4=pcal lsby  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal lsby 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
enddef
define  pcalxil       00000000000x
"pcalxil
decode4=pcal usbx   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal usbx 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
decode4=pcal lsbx   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal lsbx 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
enddef
define  pcalyil       00000000000x
"pcalyil
decode4=pcal usby   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal usby 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
decode4=pcal lsby   10000 1010000  2010000  3010000  4010000  5010000  6010000  7010000
!+1.5s
decode4=pcal
decode4=pcal lsby 8010000 9010000 10010000 11010000 12010000 13010000 14010000 15010000
!+1.5s
decode4=pcal
enddef
define  pcalxiu       00000000000x
"pcalxiu
decode4=pcal usbx  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal usbx 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
decode4=pcal lsbx  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal lsbx 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
enddef
define  pcalyiu       00000000000x
"pcalyiu
decode4=pcal usby  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal usby 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
decode4=pcal lsby  990000 1990000  2990000  3990000  4990000  5990000  6990000  7990000
!+1.5s
decode4=pcal
decode4=pcal lsby 8990000 9990000 10990000 11990000 12990000 13990000 14990000 15990000
!+1.5s
decode4=pcal
enddef
define  statx         05183161424x
"statx
decode4=samples usbx
!+1.5s
decode4=samples
decode4=samples lsbx
!+1.5s
decode4=samples
enddef
define  staty         05183161427x
"statx
decode4=samples usby
!+1.5s
decode4=samples
decode4=samples lsby
!+1.5s
decode4=samples
enddef
define  samplestat    05183161424x
xlog=on
"samplestat
decode4=bocf 128
statsamp=1,5
statsamp=2,6
statsamp=3,7
statsamp=4,8
statsamp=9,13
statsamp=10,14
statsamp=11,15
statsamp=12,16
xdisp=on
"samplestat done
xdisp=off
xlog=off
enddef
define  pcalspur      00000000000x
xlog=on
"pcalspur
decode4=bocf 128
pcalonsys
pcalall
pcaloffsys
pcalall
lounlocksys
pcalall
pcal5moffsys
pcalall
pcal5monsys
xdisp=on
"pcalspur done
xdisp=off
xlog=off
enddef
define  pcalamp       00000000000x
xlog=on
"pcalamp
decode4=bocf 128
pcalall
xdisp=on
"pcalamp done
xdisp=off
xlog=off
enddef
define  pcalimage     00000000000x
xlog=on
"pcalimage
decode4=bocf 128
pcalimagel
pcalimageu
xdisp=on
"pcalimage done
xdisp=off
xlog=off
enddef
define  pcalpowera    00000000000x
xlog=on
"pcalpowera
"alternates measurements
decode4=bocf 128
pcalonsys
bbcmanx
"first measurement set-up
caltsys
"now flip back and forth
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
pcalofftpi
pcalontpi
bbcagcx
xdisp=on
"done with pcalpowera
xdisp=off
xlog=off
enddef
define  pcalpowerb    00000000000
xlog=on
"pcalpowerb
"several in each state at a time
decode4=bocf 128
"pcal on"
pcalonsys
bbcmanx
caltsys
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
"pcal off
pcaloffsys
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
"pcal on
pcalonsys
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
"pcal off
pcaloffsys
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
"pcal on
pcalonsys
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
tpisamp
bbcagcx
xdisp=on
"done with pcalpowerb
xdisp=off
xlog=off
enddef
define  pcsample      00000000000x
xlog=on
vsi4=,1,5
xlog=off
decode4=pcal usbx 10000 32
!+1.5s
decode4=pcal
decode4=pcal usby 10000 32
!+1.5s
decode4=pcal
xlog=on
vsi4=,4,8
xlog=off
decode4=pcal usbx 10000 32
!+1.5s
decode4=pcal
decode4=pcal usby 10000 32
!+1.5s
decode4=pcal
xlog=on
vsi4=,9,14
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
