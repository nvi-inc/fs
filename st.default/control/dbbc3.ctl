********* dbbc3.ctl Equipment Control File *********
* Please refer to the Control Files Manual in Volume 1 of the
* Field System Documentation
*
* Two fields: BBCs/IF (8, 12, 16 or nominal (U:16,EV:8)), IFs (1-8)
  nominal 8
*
*   Each firmware version (below) can be followed on the same line with
*     an integer [0,4] that is the second after the 1 PPS to expect the
*     multicast:  0=same second, 1=next second, etc. The value may vary
*     with DBBC3 CPU speed, number of Core3H boards, and firmware version.
*     If not present, the default is 0.
*   The value should typically be the digit before the decimal point in
*     the Arrival field of monit7 (DBBC3 Tsys display), if  the digit
*     is stable. If not stable, use the largest value.
*
* DDC_E firmware version (v121 or later, but DDC_E starts at v126)
  v126 0
* DDC_U firmware version (v121 or later, but DDC_U starts at v125)
  v125 0
* DDC_V firmware version (v121 or later, but DDC_V starts at v124)
  v124 0
* mcast delay 0-499 centiseconds
  57
* setcl board
  1
* DBBC3 clock rate, >= 0, but DDC only supports 128
  128
