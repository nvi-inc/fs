********* dbbc3.ctl Equipment Control File *********
* Please refer to the Control Files Manual in Volume 1 of the
* Field System Documentation
*
* Two fields: BBCs/IF (8, 12, 16 or nominal (U:16,EV:8)), IFs (1-8)
  nominal 8
*
*   Each firmware version (below) can be followed on the same line with an
*     integer [0,499] that is the centisecond after the 1 PPS to expect the
*     multicast: [0,99]=same second, [100,199]=next second, etc. The value
*     depends on the DBBC3 CPU speed, number of Core3H boards, and firmware
*     version. If not present, the default is '0', i.e., same second.
*   The value should typically be the Arrival field of the DBBC3 Tsys
*     display (monit7), or the 'hsecs' field of 'mcast_time', when the
*     system is using, and synced, to NTP or is using a good 'setcl'
*     calibration. If you are using a 'computer' model in 'time.ctl', then
*     Using '0' initially is acceptable. If the Arrival time varies a
*     a little between one second and the next, use the larger value.
*
* DDC_E firmware version (v121 or later, but DDC_E starts at v126)
  v126 0
* DDC_U firmware version (v121 or later, but DDC_U starts at v125)
  v125 0
* DDC_V firmware version (v121 or later, but DDC_V starts at v124)
  v124 0
* placeholder, 0-499, not used
  0
* setcl board
  1
* DBBC3 clock rate, >= 0, but DDC only supports 128
  128
