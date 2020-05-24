""
2A -301
Parameters must since single characters
""
2A -302
Parameters must be 'a', 'b', ...,  'd' (to maximum possible number of RDBEs).
""
2B -201
Error decoding IF value, must be both, 0, or 1.
""
2B -202
Error decoding attenuator value, must be auto, 0, 0.5, 1.0, ..., 31.0,31.5.
""
2B -203
Error decoding target RMS value, must be between 0.0 and 128.0, inclusive.
""
2B -301
No RDBEs active, see active_rdbes command.
""
2B -302
IF 0 RMS too low, rdb?W
""
2B -303
IF 1 RMS too low, rdb?W
""
2B -304
IF 0 RMS too high, rdb?W
""
2B -305
IF 1 RMS too high, rdb?W
""
2B -401
error retrieving class for IF0 query for dbe_atten, rdb?W
""
2B -402
error retrieving class for IF1 query for dbe_atten, rdb?W
""
2B -501
error decording first IF for dbe_atten, rdb?W
""
2B -502
error decording first attenuator for dbe_atten, rdb?W
""
2B -503
error decording first RMS for dbe_atten, rdb?W
""
2B -504
error decording second IF for dbe_atten, rdb?W
""
2B -502
error decording second attenuator for dbe_atten, rdb?W
""
2B -503
error decording second RMS for dbe_atten, rdb?W
""
2B -603
can't specific numberic attenuation and target
""
2B -901
response not received for dbe_atten
""
2B -902
program error: strdup() failed for dbe_atten
""
2M -301
must specify at least 1 argument for rdbe command
""
2M -302
No RDBEs active, see active_rdbes command.
""
2M -401
error retrieving class from ?W
""
2T -501
Error decoding dbe_tsys response from rdb?W.
""
2T -502
Non-zero return code in dbe_tsys response from rdb?W.
""
2T -503
Internal error in decoding dbe_tsys response from rdb?W.
""
2T -504
Wrong number of channels in dbe_tsys response from rdb?W.
""
3A -301
Error decoding argument
""
3A -302
Argument must be 1 ... 4 (maximum possible number of Mark 5Cs).
""
35 -401
error retrieving class for dot query in get_RDBEtime
""
35 -402
error decoding time in get_RDBEtime
""
35 -403
unknown RDBE unit in get_RDBEtime
""
3E -501
error decoding dot? time parameter
""
3E -502
error decoding dot? status parameter
""
3E -503
error decoding dot? OS_time parameter
""
3E -504
error decoding dot? DOT_OS_time_diff parameter
""
3E -505
error decoding dot? vdif_epoch parameter
""
3E -901
query response not received
""
3E -902
program error: strdup() failed
""
3K -301
command does not accept parameters
""
3K -302
No Mark 6s active, see active_mk6s command.
""
3K -401
error retrieving class for scan_check response, ?W
""
3K -501
error decoding scan_check? scan parameter
""
3K -502
error decoding scan_check? label parameter
""
3K -503
error decoding scan_check? data type parameter
""
3K -504
error decoding scan_check? date code parameter
""
3K -505
error decoding scan_check? start parameter
""
3K -506
error decoding scan_check? length parameter
""
3K -507
error decoding scan_check? total rate parameter
""
3K -508
error decoding scan_check? missing parameter
""
3K -509
error decoding scan_check? error parameter
""
3K -601
SCAN_CHECK failed
""
3K -602
SCAN_CHECK missing bytes is not zero.
""
3K -603
SCAN_CHECK (trailing) error field is not empty.
""
3K -901
query response not received
""
3K -902
program error: strdup() failed
""
3M -301
must specify at least 1 argument for mk5c command
""
3M -302
No Mark 6s active, see active_mk6s command.
""
3M -401
error retrieving class from ?W
""
3P -301
command does not accept parameters
""
3P -302
No Mark 6s active, see active_mk6s command.
""
3P -401
error retrieving class, ?W
""
3P -501
error decoding pointers? record position, ?W
""
3P -502
error decoding pointers? scan start position, ?W
""
3P -503
error decoding pointers? scan stop position, ?W
""
3P -901
query response not found, ?W
""
3P -902
program error: strdup() failed, ?W
""
3R -101
no default for record parameter
""
3R -201
record parameter must be 'on' or 'off'.
""
3R -202
scan label parameter too long
""
3R -301
No Mark 6s active, see active_mk6s command.
""
3R -302
scan_name defined scan label too long
""
3R -400
error retrieving acknowledgement of command, ?W
""
3R -401
error retrieving class, ?W
""
3R -501
error decoding record? status parameter, ?W
""
3R -502
error decoding record? scan number parameter, ?W
""
3R -503
error decoding record? scan label parameter, ?W
""
3R -901
query response not found, ?W
""
3R -902
program error: strdup() failed, ?W
""
4F -101
No default for mode.
""
4F -201
Mode must be one of: a, b1, b2, c1, c2, d1, ..., d28, e1, ..., e4.
""
4F -202
Rate must be one of: 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32.
""
4F -203
Fan must be on of 1:1, 1:2, 1:4.
""
4F -204
Barrel-roll must be off, 8, 16, or m.
""
4F -205
Data modulation must be "off" or "on".
""
4F -206
Synch must be off (or -1) or 0, ..., 16.
""
4F -303
Trackform incompatable with VLBA fan-out.
""
4F -500
No corresponding canned mode to prime formatter with.
""
4F -501
Formatter was failing the synch test.
""
4F -503
Rack ID does not have at least two zero bits.
""
4F -504
Formatter and equip.ctl firmware versions disagree, formatter reports ?W
""
4F -505
Can't use 1:4 fan-out with magnitude bits from VCs 9-14.
""
4F -506
Formatter firmware version in equip.ctl doesn't support barrel rolling.
""
4F -507
Formatter firmware version in equip.ctl doesn't support data modulation.
""
4F -508
Rack ID is odd and Mark 5 record is in use, formatter reports rack ID ?W
""
4F -509
Possible bit slip, Altera clock and sync misalign errors.
""
4M -100
no default for trackform track number
""
4M -200
trackform track must be 2-33, 102-133.
""
4M -301
trackform internal error, bsfo2code bs=NULL
""
4M -302
no default for trackform bitstream
""
4M -303
unknown trackform bit-stream 
""
4N -100
no default for tracks track number
""
4N -200
tracks track must be an v(0-7), m(0-7), 2-33, or 102-133. 
""
4R -101
No default for headstack.
""
4R -102
No default for home track.
""
4R -201
Rollform headstack must be 1 or 2.
""
4R -202
Rollform home tracks, must be 2-33.
""
4R -203
Rollform output tracks must be null, -1, or 2-23.
""
4R -301
Rollform can not have more than 16 output tracks.
""
55 -401
error retrieving class for dot query in get_5btime
""
55 -402
error decoding time in get_5btime
""
55 -403
error retrieving class for 1pps_source/clock_set queries in get_5btime
""
5B -301
command does not accept parameters
""
5B -302
VSN does not contain + or - in first seven characters
""
5B -401
error retrieving class
""
5B -402
Use "bank_check" and "bank_status" for Mark 5A, 5B, and 5C recorders only.
""
5B -411
error retrieving class, rtime/bank_set
""
5B -501
error decoding rtime? seconds parameter
""
5B -502
error decoding rtime? gb parameter
""
5B -503
error decoding rtime? percent parameter
""
5B -504
error decoding rtime? mode parameter
""
5B -505
error decoding rtime? sub-mode parameter
""
5B -506
error decoding rtime? track rate parameter
""
5B -507
error decoding rtime? total rate parameter
""
5B -511
error decoding bank_set? active bank parameter
""
5B -512
error decoding bank_set? active vsn parameter
""
5B -513
error decoding bank_set? inactive bank parameter
""
5B -514
error decoding bank_set? inactive vsn parameter
""
5B -521
error decoding vsn? vsn parameter
""
5B -522
error decoding vsn? check parameter
""
5B -523
error decoding vsn? disk parameter
""
5B -524
error decoding vsn? original vsn parameter
""
5B -525
error decoding vsn? new vsn parameter
""
5B -534
error decoding rtime? source parameter
""
5B -535
error decoding rtime? mask parameter
""
5B -534
error decoding rtime? decimate parameter
""
5B -901
query response not received
""
5B -902
program error: strdup() failed
""
5B -911
query response not received
""
5B -912
program error: strdup() failed
""
5B -921
query response not received
""
5B -922
program error: strdup() failed
""
5C -301
command does not accept parameters
""
5D -301
data_check command does not accept parameters
""
5D -403
error retrieving class for data_check response
""
5D -404
Use "data_check" for Mark 5A, 5B, and 5C recorders only.
""
5D -501
error decoding data_check? mode parameter
""
5D -502
error decoding data_check? submode parameter
""
5D -503
error decoding data_check? time parameter
""
5D -504
error decoding data_check? offset parameter
""
5D -505
error decoding data_check? period parameter
""
5D -506
error decoding data_check? bytes parameter
""
5D -507
error decoding data_check? missing parameter
""
5D -511
error decoding data_check? source parameter
""
5D -512
error decoding data_check? start parameter
""
5D -513
error decoding data_check? date code parameter
""
5D -514
error decoding data_check? frames parameter
""
5D -515
error decoding data_check? frame header period parameter
""
5D -516
error decoding data_check? total recording rate parameter
""
5D -517
error decoding data_check? byte offset parameter
""
5D -518
error decoding data_check? total missing bytes parameter
""
5D -522
error decoding data_check? submode parameter
""
5D -523
error decoding data_check? time parameter
""
5D -524
error decoding data_check? offset parameter
""
5D -601
DATA_CHECK failed
""
5D -901
query response not received
""
5D -902
program error: strdup() failed
""
5E -501
error decoding dot? time parameter
""
5E -502
error decoding dot? status parameter
""
5E -503
error decoding dot? FHG_status parameter
""
5E -504
error decoding dot? OS_time parameter
""
5E -505
error decoding dot? DOT_OS_time_diff parameter
""
5E -511
error decoding 1pps_source? source parameter
""
5E -521
error decoding clock_set? freq parameter
""
5E -522
error decoding clock_set? source parameter
""
5E -523
error decoding clock_set? clock_gen parameter
""
5E -901
query response not received
""
5E -902
program error: strdup() failed
""
5E -903
query response not received
""
5E -904
program error: strdup() failed
""
5E -905
query response not received
""
5E -906
program error: strdup() failed
""
5F -201
scan name too long (maximum 32 characters)
""
5F -202
destinaton file name too long (maximum 64 characters)
""
5F -203
start time too long (maximum 32 characters)
""
5F -204
end time too long (maximum 32 characters)
""
5F -205
options too long (maximum 32 characters)
""
5F -301
fork to create child (to run autoftp script) failed, see above error.
""
5F -302
Exec of xterm (to run autoftp script) failed, see above error.
""
5F -303
fork to create grandchild (to run autoftp script) failed, see above error.
""
5F -304
Child did not exit normally when trying to run autoftp script.
""
5F -305
No locally defined file name and Mark5 system did not return file name.
""
5F -306
Non-zero exist status ?WWW.
""
5F -307
Non-zero exist status from child when trying to run autoftp script, see above.
""
5F -308
Parameter after 'abort' must be 'autoftp' or null (empty).
""
5F -400
Error retrieving class for response to commands.
""
5F -401
Error retrieving class for response to query.
""
5F -402
Use "disk2file" for Mark 5 and FlexBuff (including Mark 6) recorders only.
""
5F -501
error decoding disk2file? status parameter
""
5F -502
error decoding disk2file? destination file name parameter
""
5F -503
error decoding disk2file? start byte parameter
""
5F -504
error decoding disk2file? current byte parameter
""
5F -505
error decoding disk2file? end byte parameter
""
5F -506
error decoding disk2file? option parameter
""
5F -511
error decoding scan_set? scan number parameter
""
5F -512
error decoding scan_set? scan label parameter
""
5F -513
error decoding scan_set? start byte parameter
""
5F -514
error decoding scan_set? end byte parameter
""
5F -521
error decoding scan_set? scan label parameter
""
5F -522
error decoding scan_set? start time parameter
""
5F -523
error decoding scan_set? end time parameter
""
5F -901
query response not found for disk2file?
""
5F -902
program error: strdup() failed for diskfile?
""
5F -911
query response not found for scan_set?
""
5F -912
program error: strdup() failed for scan_set?
""
5H -301
command does not accept parameters
""
5H -302
background Mark 5 error(s) detected - see below
""
5H -303
more Mark 5 error messages are pending
""
5H -401
error retrieving class in mk5cn_exec
""
5H -501
unexpected number of replies (expected 1) from mk5cn
""
5H -900
status? query response not received
""
5H -901
error decoding status word: overflow or not hex number or too big
""
5H -910
error? query response not received
""
5H -912
strdup failed initializing get_error
""
5I -101
No default for control parameter
""
5I -102
No default for destination parameter if control is connect.
""
5I -201
Control parameter must be one of: off, on, disconnect, connect
""
5I -202
Destination parameter too long (maximum 64 characters)
""
5I -400
Error retrieving class for response to commands.
""
5I -401
error retrieving class
""
5I -501
error decoding in2net? status parameter
""
5I -502
error decoding in2net? destination parameter
""
5I -503
error decoding in2net? received parameter
""
5I -504
error decoding in2net? buffered parameter
""
5I -901
query response not found
""
5I -902
program error: strdup() failed
""
5K -301
scan_check command does not accept parameters, except 'force'
""
5K  302
There have not been two scan_name=... commands since the schedule started, use scan_check=force to force check
""
5K -401
error retrieving class for scan_check response
""
5K -402
Use "scan_check" for Mark 5 and FlexBuff (including Mark 6) recorders only.
""
5K -501
error decoding scan_check? scan parameter
""
5K -502
error decoding scan_check? label parameter
""
5K -503
error decoding scan_check? mode parameter
""
5K -504
error decoding scan_check? submode parameter
""
5K -505
error decoding scan_check? start parameter
""
5K -506
error decoding scan_check? length parameter
""
5K -507
error decoding scan_check? track rate parameter
""
5K -508
error decoding scan_check? missing parameter
""
5K -513
error decoding scan_check? data type parameter
""
5K -514
error decoding scan_check? data code parameter
""
5K -517
error decoding scan_check? total rate parameter
""
5K -519
error decoding scan_check? error parameter
""
5K -601
SCAN_CHECK failed
""
5K -602
SCAN_CHECK missing bytes is not zero.
""
5K  602
Warning: SCAN_CHECK missing bytes is not zero, but recorder is Mark 5C or FlexBuff.
""
5K -901
query response not received
""
5K -902
program error: strdup() failed
""
5L -301
command does not accept parameters
""
5M -301
must specify at least 1 argument for mk5 command
""
5M -401
error retrieving class
""
5P -301
command does not accept parameters
""
5P -401
error retrieving class
""
5P -402
Use "disk_pos" for Mark 5A, 5B, and 5C recorders only.
""
5P -501
error decoding position? record position
""
5P -502
error decoding position? play position
""
5P -511
error decoding pointers? record position
""
5P -512
error decoding pointers? scan start position
""
5P -513
error decoding pointers? scan stop position
""
5P -901
query response not found
""
5P -902
program error: strdup() failed
""
5R -101
no default for record parameter
""
5R -201
record parameter must be 'on' or 'off'.
""
5R -202
scan label parameter too long
""
5R -302
scan_name defined scan label too long
""
5R -400
error retrieving acknowledgement of command
""
5R -401
error retrieving class
""
5R -501
error decoding record? status parameter
""
5R -502
error decoding record? scan number parameter
""
5R -503
error decoding record? scan label parameter
""
5R -901
query response not found
""
5R -902
program error: strdup() failed
""
5S -301
command does not accept parameters
""
5S -401
error retrieving class
""
5S -501
error decode disk_serial? serial number parameter
""
5S -901
query response not found
""
5S -902
program error: strdup() failed
""
5S -903
program error: too many serial numbers
""
5T -104
No default sample rate if clock rate (from equip.ctl) is "none".
""
5T -114
No default sample rate for Ethernet recorders unless decimate was specified with mark5b.
""
5T -201
source parameter must be 'vdif' or 'mark5b' for Mark 5C/FlexBuff.
""
5T -202
mask parameter must specify a non-zero integer, maximum 64 bits, usually as a hex value, e.g., 0xf
""
5T -203
decimate parameter must be one of 1, 2, 4, 8, or 16
""
5T -204
Mark 5B recorder sample rate must be integer 2, 4, 8, 16, 32, or 64 (MHz).
""
5T -205
fpdp parameter, if specified, must be 1 or 2.
""
5T -206
okay parameter must be 'disk_record_ok' or null.
""
5T -211
Source parameter must be 'ext', 'tvg', or 'ramp' for Mark 5B.
""
5T -212
Upper or lower 32 bits of mask must be zero for Mark 5B.
""
5T -213
For Mark 5B recorder minimum implied sample rate is 2 MHz. Check Mark 5B clock rate in equip.ctl.
""
5T -214
For Mark 5B recorder implied decimation must be integer 1, 2, 4, 8, or 16. Check Mark 5B clock rate in equip.ctl.
""
5T -223
Decimation not supported for VDIF.
""
5T -224
For Ethernet recorders, total date rate must be an integer multiple of 1 Mbps.
""
5T -234
Can't specify sample rate and decimate parameters simultaneously
""
5T -244
Sample rate must be a positive integer Hz.
""
5T -301
Don't change mode while recording, use disk_record=off first or (dangerous) use disk_record_ok as the sixth parameter.
""
5T -400
error retrieving acknowledgement of command
""
5T -401
error retrieving class
""
5T -402
Use "mk5b_mode" for Mark 5B recorders only.
""
5T -403
Use "mk5c_mode" for Mark 5C and Flexbuff recorders only.
""
5T -501
error decoding mode? source/magic  parameter
""
5T -502
error decoding mode? mask or format parameter
""
5T -503
error decoding mode? decimate or tracks parameter
""
5T -504
error decoding mode? fpdp or track bit rate parameter
""
5T -505
error decoding mode? vdif frame size parameter
""
5T -512
error decoding mode? format parameter
""
5T -513
error decoding mode? tracks parameter
""
5T -514
error decoding mode? track bit rate parameter
""
5T -901
query response not found
""
5T -902
program error: strdup() failed
""
10 -401
error retrieving class for time query in get_fila10gtime
""
10 -402
error decoding time in get_fila10gtime
""
AN   -1
Illegal mode
""
AN   -2
Time-out while waiting for a response
""
AN   -3
Antenna response garbled.
""
AN   -4
Interface not set to remote.
""
AN   -5
Error return from antenna.
""
AN   -6
Antenna LU is down, please UP it.
""
AN   -7
Antenna communications restored.
""
AN   -8
Pointing system NOT present.
""
AN   -9
antenna=... command error, see above errors.
""
AN -101
Pointing computer year, day, or time is incorrect.
""
AN -102
Pointing computer command angles are incorrect.
""
AN -103
Pointing computer tracking errors are too large.
""
AQ   -1
Break Detected in AQUIR
""
AQ   -2
AQUIR RN already locked
""
AQ  -10
FIVPT or ONOFF did not finish in the allotted time.
""
AQ  -11
FIVPT or ONOFF is not RP'd
""
AQ  -12
FIVPT or ONOFF is not dormant
""
AQ  -13
FIVPT or ONOFF did not start to execute within 30 seconds.
""
AQ  -20
Source not acquired in alloted time
""
AQ  -30
ANTCN failed too many times
""
AQ  -40
MOON is not available
""
BD -301
must specify at least 1 argument for dbbc command
""
BD -401
error retrieving class
""
BO -101
Error getting next command, UNIX ?FFF
""
BO -102
Not enough room in time-scheduling block.  Max entries ?WWW
""
BO -103
Procedure already in the stack - recursion not allowed.
""
BO -104
Procedure stack is full (5 levels allowed)
""
BO -105
Error opening schedule file, UNIX ?FFF
""
BO -106
Error specifying line number ?WWW
""
BO -107
No parameter was specified for this switch
""
BO -108
Parameter must be ON or OFF
""
BO -109
Common too big
""
BO -110
Error opening FSCMD.CTL or STCMD.CTL, UNIX ?FFF
""
BO -111
Error reading FSCMD.CTL or STCMD.CTL, UNIX ?FFF
""
BO -112
Too many commands in FSCMD.CTL and STCMD.CTL.  Max is ?WWW
""
BO -113
Duplicate hash code, indices are: A*100+B = ?WWW
""
BO -114
Error initializing MATCN ?WWW
""
BO -115
Error initializing IBCON ?WWW
""
BO -116
Error initializing ANTCN ?WWW
""
BO -117
Error opening LOCATION.CTL, UNIX ?FFF
""
BO -118
Error reading LOCATION.CTL, UNIX ?FFF
""
BO -119
Error decoding LOCATION.CTL line ?WWW
""
BO -120
Error opening MUX.CTL, UNIX ?WWW
""
BO -121
Error reading DEV.CTL, UNIX ?WWW
""
BO -122
Error decoding DEV.CTL line ?WWW
""
BO -123
Error positioning in schedule, UNIX ?FFF
""
BO -124
No (scan_name=...) observation starting at a future time found in schedule.
""
BO -125
Reading procedure file, error, UNIX ?FFF
""
BO -126
Too many procedures.  Maximum is ?WWW
""
BO -127
Call to NAMF establishing new procedure library, UNIX ?FFF
""
BO -128
Error in new proc routine, stack is flushed.
""
BO -129
Error in new proc routine, stack is flushed, UNIX ?FFF
""
BO -130
Reading edited proc file, UNIX ?FFF
""
BO -131
Reading new procedure library, UNIX ?FFF
""
BO -132
No SOURCE command found in schedule.
""
BO -133
Error opening procedure library, UNIX ?FFF
""
BO -134
Positioning in schedule file error, UNIX ?FFF
""
BO -135
Maximum number of characters in procedure parameter is ?WWW.
""
BO -136
Can't have schedule and station library the same.
""
BO -137
Schedule year disagrees with current (computer) year.
""
BO -138
Number of lines must be a positive integer.
""
BO -139
Error opening EQUIP.CTL ?FFF
""
BO -140
Error decoding EQUIP.CTL line ?WWW
""
BO -141
Illegal version string in DBBC DDC or PFB version in EQUIP.CTL line ?WWW
""
BO -142
No 'nominal' rate for that DBBC version number, rate in EQUIP.CTL line ?WWW
""
BO -143
Error opening RXDEF.CTL, UNIX ?FFF
""
BO -144
Error trying to read RXDEF.CTL line ?WWW
""
BO -145
Non-numeric conversion factor in RXDEF.CTL line ?WWW
""
BO -146
Error opening TEDEF.CTL, UNIX ?FFF
""
BO -147
Error trying to read first line of TEDEF.CTL
""
BO -148
Error parsing first line of TEDEF.CTL
""
BO -149
Illegal integer in first line of TEDEF.CTL
""
BO -150
Illegal floating point number in first line of TEDEF.CTL
""
BO -151
Error opening HEAD.CTL, UNIX ?FFF
""
BO -152
Error reading HEAD.CTL, UNIX ?FFF
""
BO -153
Error decoding line # ?WWW in HEAD.CTL
""
BO -154
Error opening ANTENNA.CTL, UNIX ?FFF
""
BO -155
Error reading ANTENNA.CTL, UNIX ?FFF
""
BO -156
Error decoding line # ?WWW in ANTENNA.CTL
""
BO -157
Can't change procedure library while PFMED is running.
""
BO -158
Can't open STATION as procedure library.
""
BO -159
Can't change schedule library because resource is locked.
""
BO -160
Error opening RXDIODE.CTL, UNIX ?FFF
""
BO -161
Error trying to read RXDIODE.CTL line ?WWW
""
BO -162
Non-numeric conversion factor in RXDIODE.CTL line ?WWW
""
BO -163
Temperatures from RXDIODE.CTL are out of order.
""
BO -164
Voltages from RXDIODE.CTL are out of order.
""
BO -165
Too many values in RXDIODE.CTL, only ?WWW permitted.
""
BO -166
Temperatures from RXDIODE.CTL are equal.
""
BO -167
Voltages from RXDIODE.CTL are equal.
""
BO -169
Too many entries in MATAD.CTL file only ?WWW permitted.
""
BO -170
Too many entries in IBAD.CTL file only ?WWW permitted.
""
BO -171
Resource locked. Cannot terminate. Is PFMED running?
""
BO -172
Parameter for terminate must be disk_record_ok.
""
BO -173
Don't terminate while recording, either use disk_record=off first or (dangerous) terminate=disk_record_ok.
""
BO -180
Error opening TIME.CTL, UNIX ?FFF
""
BO -181
Error decoding rate field in TIME.CTL
""
BO -182
Error decoding span field in TIME.CTL
""
BO -183
Error decoding model field in TIME.CTL
""
BO -189
Error reading TIME.CTL, UNIX ?FFF
""
BO -190
Error initiliazing mcbcn, internal error ?WWW
""
BO -191
Error initiliazing rclcn, internal error ?WWW
""
BO -192
Error initiliazing mk5cn, internal error ?WWW
""
BO -193
Error initiliazing dscon, internal error ?WWW
""
BO -194
Error initiliazing dbbcn, internal error ?WWW
""
BO -195
Error initiliazing dbbc2, internal error ?WWW
""
BO -196
Error initiliazing mk6ca, internal error ?WWW
""
BO -197
Error initiliazing mk6cb, internal error ?WWW
""
BO -198
More than ?WWW Mark6s requires mods to binit.f (plus fspgm.ctl, fserr.ctl, and mk6cn.c).
""
BO -200
File name too long in caccess(), while checking .prc permissions/existence
""
BO -201
Mode length must be greater than zero in caccess(), while checking .prc permissions/existence
""
BO -202
Unrecognized mode caccess(), while .prc checking permissions/existence
""
BO -203
Can't access new procedure library, UNIX ?FFF
""
BO -204
Unrecognized error from caccess(), while checking .snp permissions/existence
""
BO -205
File name too long in caccess(), while checking .snp permissions/existence
""
BO -206
Mode length must be greater than zero in caccess(), while checking .snp permissions/existence
""
BO -207
Unrecognized mode caccess(), while checking .snp permissions/existence
""
BO -208
Can't access new schedule file, UNIX ?FFF
""
BO -209
Unrecognized error from caccess(), while checking .snp permissions/existence
""
BO -210
Procedure library is too big, trailing procedures ignored.
""
BO -211
Can't open a new schedule when a procedure from the schedule library is executing
""
BO -212
Can't change schedule procedure library when a procedure from the schedule procedure library is executing
""
BO -219
Error opening drivev1.ctl ?FFF
""
BO -220
Error decoding drivev1.ctl line ?WWW
""
BO -221
Error opening drivem1.ctl ?FFF
""
BO -222
Error decoding drivem1.ctl line ?WWW
""
BO -223
Error opening drivev2.ctl ?FFF
""
BO -224
Error decoding drivev2.ctl line ?WWW
""
BO -225
Error opening drivem2.ctl ?FFF
""
BO -226
Error decoding drivem2.ctl line ?WWW
""
BO -227
Error opening head1.ctl ?FFF
""
BO -228
Error decoding head1.ctl line ?WWW
""
BO -229
Error opening head2.ctl ?FFF
""
BO -230
Error decoding head2.ctl line ?WWW
""
BO -231
Error opening rdbe.ctl ?FFF 
""
BO -232
Error decoding rdbe.ctl line ?WWW
""
BO -251
Internal error: time for secsnow invalid
""
BO -252
Internal error: time for secswait invalid
""
BO -253
Internal error: time for secsnow invalid
""
BO -254
Internal error: time for secsmin invalid
""
BO -255
Internal error: time for seconds invalid
""
BO -256
Internal error: time for logsecs invalid
""
BO -257
Internal error: time for prsecs invalid
""
BO -258
Internal error: time for secsnow invalid
""
BO -259
Internal error: time for secst invalid
""
BO -260
Procedure file name too long, 8 characters maximum.
""
BO -261
Schedule file name too long, 8 characters maximum.
""
BO -262
Cannot change schedules while recording, use disk_record=off to stop.
""
BO -295
Error initiliazing rdbca, internal error ?WWW
""
BO -296
Error initiliazing rdbcb, internal error ?WWW
""
BO -297
Error initiliazing rdbcc, internal error ?WWW
""
BO -298
Error initiliazing rdbcd, internal error ?WWW
""
BO -299
More than ?WWW RDBEs requires mods to binit.f (plus fspgm.ctl, fserr.ctl, fmset.c, and rdbcn.c).
""
BO -300
There must be two character error mnemonic for TNX.
""
BO -301
Error decoding error number in TNX.
""
BO -302
TNX action parameter must be 'on' or 'off'.
""
BO -303
This error has not occurred yet, so its state can't be changed (trying to turn 'off').
""
BO -304
This error has not occurred yet, so its state can't be changed (trying to turn 'on').
""
BO -305
TNX=... command cannot be executed from a procedure.
""
BO -306
TNX=... command cannot be executed from time-list.
""
BO -307
TNX=... command cannot be executed from the schedule.
""
BO -308
Internal error in help command.
""
BO -309
Help not available for that command, maybe your equipment type is wrong.
""
BO -310
Error decoding error string '#num' for TNX.
""
BO -311
Error already "on", for TNX.
""
BO -312
Error already "off", for TNX.
""
BO -313
IF command must have an equals.
""
BO -314
No default for IF command condition.
""
BO -315
Unknown condition in IF command.
""
BO -400
Error opening flagr.ctl, UNIX ?FFF
""
BO -401
Error reading flagr.ctl, UNIX ?FFF
""
BO -402
Error antenna check period in TIME.CTL
""
BO -403
Error ?FFF reading antenna gain file, see preceeding message for file name.
""
BO -404
Error ?FFF reading flux.ctl file.
""
BO -405
Error opening TACD.CTL ?FFF
""
BO -406
Error reading TACD.CTL, UNIX ?FFF
""
BO -407
Error decoding TACD.CTL line ?WWW
""
BO -501
Error following schedule procedure library file name link.
""
BO -502
Schedule procedure library link was empty.
""
BO -503
Final schedule procedure library link does contain '.prc'.
""
BO -506
Error following station procedure library file name link.
""
BO -507
Station procedure library link was empty.
""
BO -508
Final station procedure library link does contain '.prc'.
""
BO -998
ANTCN termination mode failed, see above error.
""
BO -999
WARNING: Log file just opened is already larger than 100 MB.
""
CD  -1
Error from DBBCN in TPICD, see above for error.
""
CD  -2
Error retrieving processing buffers from DBBCN in TPICD, see above for error.
""
CH   -1
Trouble with class buffer in CHEKR
""
CH   -2
Illegal mode in MATCN
""
CH   -3
Unrecognized device in MATCN
""
CH   -4
Device ?W timed-out on response from MATCN
""
CH   -5
Improper response (wrong number of chars) from MATCN
""
CH   -6
Verify error from MATCN
""
CH   -7
MATCN reports MAT device is /dev/null, MAT devices inaccessible.
""
CH -196
?W communication trouble, turning off lvdt
""
CH -197
?W communication trouble, convertig voltage to microns
""
CH -198
?W communication trouble, reading head voltage
""
CH -199
?W communication trouble, turning on lvdt
""
CH -200
?W wrong number of buffers in respone
""
CH -201
?W communication trouble
""
CH -202
?W frequency does not check with requested value
""
CH -203
?W if input source does not check with requested setting
""
CH -204
?W USB bandwidth does not check with requested value
""
CH -205
?W LSB bandwidth does not check with requested value
""
CH -206
?W USB bandwidth compensation does not check with requested value
""
CH -207
?W LSB bandwidth compensation does not check with requested value
""
CH -208
?W gain mode does not check with requested setting
""
CH -209
?W USB gain value does not check with requested value
""
CH -210
?W LSB gain value does not check with requested value
""
CH -211
?W averaging period does not check with requested setting
""
CH -212
?W LO unlocked.
""
CH -222
?W attenuator for IF channel A does not check with requested setting
""
CH -223
?W attenuator for IF channel B does not check with requested setting 
""
CH -224
?W input source for IF channel A does not check with requested setting
""
CH -225
?W input source for IF channel B does not check with requested setting 
""
CH -226
?W averaging period does not check with requested setting
""
CH -227
?W mode does not check with requested setting
""
CH -228
?W sample rate does not check with requested setting
""
CH -229
?W format does not check with requested setting
""
CH -230
?W enable tracks do not check with requested setting
""
CH -231
?W DQA channels do not check with requested setting
""
CH -232
?W group enables do not match commanded enable
""
CH -233
?W tape drive should be moving and it isn't
""
CH -234
?W commanded speed and actual speed differ
""
CH -235
?W direction of tape travel is different than commanded
""
CH -236
?W tape drive shouldn't be moving and it is
""
CH -237
?W tape drive is not ready and a schedule is active and not halted.
""
CH -238
?W low tape sensor doesn't match commanded
""
CH -239
?W tape drive should be recording but no groups are enabled.
""
CH -240
?W attenuator for IF channel C does not check with requested setting
""
CH -241
?W attenuator for IF channel D does not check with requested setting 
""
CH -242
?W input source for IF channel C does not check with requested setting
""
CH -243
?W input source for IF channel D does not check with requested setting 
""
CH -244
?W averaging period does not check with requested setting
""
CH -288
Head is moving.
""
CH -289
Command head position out-of-range (VLBA2/VLBA42 drive).
""
CH -290
Head motion timed-out.
""
CH -301
?W module is not in remote
""
CH -302
?W frequency does not check with requested value
""
CH -303
?W bandwidth does not check with requested value
""
CH -304
?W TPI selection does not check with requested setting
""
CH -305
?W USB attenuator does not check with requested setting
""
CH -306
?W LSB attenuator does not check with requested setting
""
CH -307
?W unlock indicator is on
""
CH -308
?W total power integrator overflow
""
CH -309
?W alarm is on
""
CH -310
?W shows the majority of possible error conditions
""
CH -311
IF distributor is not in remote
""
CH -312
IF1 attenuator does not check with requested value
""
CH -313
IF2 attenuator does not check with requested value
""
CH -314
IF1 input does not check with requested setting
""
CH -315
IF2 input does not check with requested setting
""
CH -316
Total power integrator overflow on IF1
""
CH -317
Total power integrator overflow on IF2
""
CH -318
IF distributor alarm is on
""
CH -319
IF distributor shows the majority of possible error conditions
""
CH -320
Formatter is not in remote
""
CH -321
Formatter input does not check with requested setting
""
CH -322
Formatter mode does not check with requested setting
""
CH -323
Formatter sample rate does not check with requested setting
""
CH -324
Formatter synch test on/off does not check with requested setting
""
CH -325
Formatter synch test fail
""
CH -326
Formatter detected power fail
""
CH -327
Formatter's run/set switch is in SET position
""
CH -328
System too busy to compare Formatter/computer clock
""
CH -329
Formatter time does not agree with Field System time.
""
CH -330
Formatter alarm is on
""
CH -331
Formatter shows the majority of possible error conditions
""
CH -332
Tape drive is not in remote
""
CH -333
Tape should be stopped and it's moving
""
CH -334
Tape should be moving and it's stopped
""
CH -335
Tape direction does not check with request
""
CH -336
Enabled tracks do not check with requested tracks
""
CH -337
Reproduce bandwidth does not check with request
""
CH -338
Reproduce equalizer does not check with request
""
CH -339
Bypass mode does not check with requested setting
""
CH -340
Reproduce track A does not check with request
""
CH -341
Reproduce track B does not check with request
""
CH -342
Tape is not in ready state (vacuum not ready)
""
CH -343
Tape rate generator does not agree with request.
""
CH -344
Tape should be recording, but no tracks are enabled.
""
CH -345
Tape drive alarm is on
""
CH -346
Record enable is in the wrong state.
""
CH -347
Tape drive shows the majority of possible error conditions
""
CH -348
Receiver LO is unlocked.
""
CH -349
The Receiver 70K stage is hotter than?WWWK.
""
CH -350
The Receiver 20K stage is hotter than?WWWK.
""
CH -351
Tape head 1 is not in requested position.
""
CH -352
Tape head 2 is not in requested position.
""
CH -360
IF3 module shows the majority of possible error conditions
""
CH -361
IF3 module is not in remote
""
CH -362
IF3 attenuator does not check with requested value.
""
CH -363
IF3 mixer state does not check with request.
""
CH -364
IF3 switch 1 setting does not check with request.
""
CH -365
IF3 switch 2 setting does not check with request.
""
CH -366
IF3 switch 3 setting does not check with request.
""
CH -367
IF3 switch 4 setting does not check with request.
""
CH -368
IF3 frequency does not check with equip.ctl value.
""
CH -369
IF3 lo is unlocked.
""
CH -370
Total power integrator overflow on IF3
""
CH -371
IF3 alarm is on
""
CH -372
IF3 pcal control not present, equip.ctl says it is.
""
CH -373
IF3 pcal control state doesn't check with request.
""
CH -401
Head is still moving.
""
CH -402
Class error in get_class.
""
CH -408
Error locking LVDT Resource Number.
""
CH -409
Error unlocking LVDT Resource Number.
""
CH -421
Program error: prematurely out of rclcn response_buffer for device ?W
""
CH -422
Program error: less than zero length data object request for device ?W
""
CH -423
Program error: impossible type code for rclcn_res_position_read for device ?W
""
CH -500
Previous error prevented checking S2 recorder measured delay.
""
CH -501
User Info Field 1 Label does not agree with request.
""
CH -502
User Info Field 2 Label does not agree with request.
""
CH -503
User Info Field 3 Label does not agree with request.
""
CH -504
User Info Field 4 Label does not agree with request.
""
CH -505
User Info Field 1 Field does not agree with request.
""
CH -506
User Info Field 2 Field does not agree with request.
""
CH -507
User Info Field 3 Field does not agree with request.
""
CH -508
User Info Field 4 Field does not agree with request.
""
CH -509
Record speed does not agree with request.
""
CH -510
Recorder state does not agree with request.
""
CH -511
Record mode does not agree with request.
""
CH -512
Record group does not agree with request.
""
CH -513
Record data valid flag does not agree with request.
""
CH -514
Record data valid playback enable flag does not agree with request.
""
CH -515
Tapeid (label) does not agree with request.
""
CH -516
Tapetype does not agree with request.
""
CH -517
program error: Recorder returned individual positions, overall was expected.
""
CH -518
Barrelroll mode does not agree with request.
""
CH -601
Internal error: time for secs_fm invalid
""
CH -700
if?W: communication trouble.
""
CH -701
if?W: High Res Sampler Module N2 missing.
""
CH -702
if?W: Digital Filter Module N3 missing.
""
CH -703
if?W: Digital Filter Module is not processing.
""
CH -704
if?W: Band Splitter input level is too high for servo loop.
""
CH -705
if?W: Band Splitter input level is too low for servo loop.
""
CH -706
if?W: Band Splitter input offset is out of servo range.
""
CH -707
if?W: Band Splitter USB level is out of servo range.
""
CH -708
if?W: Band Splitter LSB level is out of servo range.
""
CH -709
if?W: Fine Tuner USB level is out of servo range.
""
CH -710
if?W: Fine Tuner LSB level is out of servo range.
""
CH -711
if?W: Digital Filter clock error detected.
""
CH -712
if?W: High Res Sampler 5 MHz reference signal has failed.
""
CH -713
if?W: High Res Sampler 1 PPS synchronisation signal has failed.
""
CH -714
if?W: High Res Sampler Module N2 is overheating - please check cooling fan.
""
CH -715
if?W: Digital Filter Module N3 is overheating - please check cooling fan.
""
CH -720
da?W: communication trouble.
""
CH -721
da?W: +5 Volt supply for first IFP is out of tolerance.
""
CH -722
da?W: +5 Volt supply for second IFP is out of tolerance.
""
CH -723
da?W: -5.2 Volt supply for both IFPs is out of tolerance.
""
CH -724
da?W: +9 Volt supply for both IFPs is out of tolerance.
""
CH -725
da?W: -9 Volt supply for both IFPs is out of tolerance.
""
CH -726
da?W: +15 Volt supply for both IFPs is out of tolerance.
""
CH -727
da?W: -15 Volt supply for both IFPs is out of tolerance.
""
CH -801
AGC mode is not as selected.
""
CH -802
Mode is not as selected.
""
CH -803
encode scheme is not as selected.
""
CH -804
Frequency Switching is not as expected.
""
CH -805
Frequency Switching sequence has been changed.
""
CH -810
Communication error for DBBC.
""
CH -811
Error retrieving communication buffer for DBBC.
""
CH -812
Incorrect response from DBBC.
""
CH -813
DBBC firmware version/personality does not match equip.ctl, compare to dbbc=version.
""
CH -814
Incorrect response while checking version, unable to verify DBBC firmware version/personality, please check.
""
CH -815
Failed to deconde DBBC vsi_clk response, can't check value.
""
CH -816
DBBC vsi_clk setting is incorrect, please use fmset 's' command to correct.
""
DB   -1
dbbc.: error opening dbb?W.ctl
""
DB   -2
dbbc.: error pushing back on dbb?W.ctl
""
DB   -3
dbbc.: first non-comment line in dbb?W.ctl did not contain three tokens
""
DB  -11
dbb?W: error opening socket
""
DB  -13
dbb?W: error from gethostbyname()
""
DB  -14
dbb?W: host had NULL IP address
""
DB  -15
dbb?W: error connecting to host
""
DB  -16
dbb?W: error opening stream
""
DB  -17
dbb?W: error gethostbyname(): HOST_NOT_FOUND
""
DB  -18
dbb?W: error gethostbyname(): TRY_AGAIN
""
DB  -19
dbb?W: error gethostbyname(): NO_RECOVERY
""
DB  -20
dbb?W: error gethostbyname(): NO_ADDRESS
""
DB  -21
dbb?W: error connect(): dbbc device connection open timed-out
""
DB  -22
dbb?W: error from getsockopt(), see above for error
""
DB  -23
dbb?W: error opening, dbbc probably not running, see above for error
""
DB  -24
dbb?W: select for connect() error, see above for error
""
DB  -25
dbb?W: error gethostbyname(): DNS timed-out
""
DB  -98
dbb?W: no dbbc device defined
""
DB  -99
dbb?W: illegal mode
""
DB -101
dbb?W: error getting class buffer
""
DB -102
dbb?W: error sending data, connection closed
""
DB -103
dbb?W: error on select reading data, see above for error, connection closed
""
DB -104
dbb?W: time-out, connection closed
""
DB -105
dbb?W: error on read, see above for error, connection closed
""
DB -106
dbb?W: error and EOF on read, see above for error, connection closed
""
DB -107
dbb?W: EOF on read, dbbc may have crashed, connection closed
""
DB -108
dbb?W: no data on read, but no EOF or error, connection closed
""
DB -109
dbb?W: read too long for input buffer, only returning partial response
""
DB -110
dbb?W: error pre-draining input, see above for error, connection closed
""
DB -111
dbb?W: error and EOF pre-draining input, see above for error, connection closed
""
DB -112
dbb?W: EOF pre-draining input, dbbc may have crashed, connection closed
""
DB -113
dbb?W: no data pre-draining input, but no EOF or error, connection closed
""
DB -114
dbb?W: re-open after pre-drain error was okay, proceeding to transaction.
""
DB -201
dbb?W: ERROR response from DBBC, see db -200 error for text.
""
DC -101
No default for frequency
""
DC -201
Error decoding frequency, must be 10.000000 to 2200.000000.
""
DC -202
Error decoding IF source, must be A, B, C, or D.
""
DC -203
Error decoding bandwidth, must be one of: 1, 2, 4, 8, 16, 32, or 64.
""
DC -204
Averaging period must be a positive integer 60 or less.
""
DC -213
BW 1 can only be used with non-lettered (NOT e/f) DDC versions.
""
DC -223
BW 32 can only be used with lettered (e/f) DDC versions or v107 or later.
""
DC -233
BW 64 can only be used with v107 or later.
""
DC -301
Even BBCs not supported for DDC firmware E/F.
""
DC -302
IF source position exceeds number of conditioning modules
""
DC -401
Class buffer error from monitor response.
""
DC -403
Error decoding dbbcNN/ response, could be a DBBC version mis-match, see error DC -402 for text.
""
DC -451
Class buffer error from command response.
""
DC -501
Only DBBC DDC rack types supported in bbcNN commands.
""
DD -201
Mode must be one of: off, on.
""
DD -202
Polarity control must one of: 0, 1, 2, or 3  (or -1 to not command).
""
DD -212
Continuous cal polarity control not supported for firmware versions < 105x_1.
""
DD -203
Samples must be a positive integer.
""
DD -204
Frequency must one in range [8,300000] (or -1 to not command).
""
DD -214
Frequency not supported for firmware versions < 106.
""
DD -205
Option must be 0 or 1 (or -1 to not command).
""
DD -215
Option not supported for firmware versions < 106.
""
DD -401
Class buffer error from monitor response.
""
DD -402 Place holder

""
DD -403
Error decoding cont_cal/ response, could be a DBBC version mis-match, see error DD -402 for text.
""
DD -451
Class buffer error from command response.
""
DD -501
Only DBBC DDC rack types supported in cont_cal command.
""
DE -201
Mode must be one of: off, on.
""
DE -202
Polarity must be one of 0, 1, 2, or 3.
""
DE -203
Frequency must be 8-300000.
""
DE -204
Option must be 0 or 1.
""
DE -205
Samples must be a positive integer.
""
DE -401
Class buffer error from monitor response.
""
DE -403
Error decoding cont_cal/ response, could be a DBBC version mis-match, see error DF -402 for text.
""
DE -451
Class buffer error from command response.
""
DF -101
No default for mode.
""
DF -102
No default for test parameter if mode=test.
""
DF -201
Mode must be one of (DDC): astro, geo, wastro, test, lba, astro2, astro3, geo2, (PFB): flex, full, full_auto, spol.
""
DF -202
Test must be one of:  0, 1, bin, tvg.
""
DF -211
Mode astro2 not supported before DBBC version 104.
""
DF -221
Mode astro3 cannot be used with non-lettered (NOT e/f) DDC versions.
""
DF -231
Lettered DDC versions (e/f) only support modes astro3 and test modes.
""
DF -241
Mode geo2 not supported before DBBC version 106.
""
DF -301
astro2 mode not supppored for DBBC DDC version less than 104
""
DF -302
Above error probably caused by a DBBC version mismatch, check equip.ctl and a dbbc=version response.
""
DF -401
Class buffer error from monitor response.
""
DF -402 Place Holder

""
DF -403
Error decoding dbbcform/ response, could be a DBBC version mis-match, see error DF -402 for text.
""
DF -451
Class buffer error from command response.
""
DF -453
DBBC version does not agree with equip.ctl; dbbc has v100: July 14 2011 or Feb 21 2011
""
DF -454
DBBC version does not agree with equip.ctl; dbbc has v101: March 08 2012
""
DF -455
DBBC version does not agree with equip.ctl; dbbc has v102: September 07 2012
""
DF -456
DBBC version does not agree with equip.ctl; see message above for DBBC's version.
""
DF -457
DBBC version does not agree with equip.ctl; dbbc has (unsupported) v103: DDC,103,October 04 2012
""
DF -458
DBBC version does not agree with equip.ctl; dbbc has v104: DDC,104,June 20 2013
""
DF -459
DBBC has unsupported date code for version 102, ddbc has: July 04 2012
""
DF -460
DBBC has unsupported date code for version 104, ddbc has: DDC,104,March 19 2013
""
DF -461
DBBC version should be DDC, but is PFB; see message above for DBBC's version.
""
DF -462
DBBC version should be PFB, but is DDC; see message above for DBBC's version.
""
DF -463
Unknown rack type in logmsg_dbbc().
""
DF -501
Only DDC and PFB types suppoterd in DBBC form command.
""
DG -101
No default for bbc, should be "all" or 1,2,...16.
""
DG -102
No default for 2nd parameter, if first parameter is "all".
""
DG -103
No default for 3rd parameter, if second parameter is gain for upper channel.
""
DG -201
Error decoding bbc, should be "all" or 1,2,..,16.
""
DG -202
Error decoding state/gainU, should be null or state: "man", "agc", or gainU: 1-255.
""
DG -203
Error decoding target/gainL, should be null or target: 0-65525, or gainL: 1-255.
""
DG -211
Error decoding bbc, should be "all" or 1,2,..,128.
""
DG -300
Monitor form requires bbc to read as a parameter, e.g., bbc_gain=1
""
DG -401
Class buffer error from monitor response.
""
DG -403
Error decoding dbbcgain/ response, could be a DBBC version mis-match, see error DG -402 for text.
""
DG -451
Class buffer error from command response.
""
DG -501
Only DBBC DDC rack types supported in bbc_gain command.
""
DH -104
No default sample rate if clock rate (from equip.ctl) is "none".
""
DH -201
mask2 parameter, must specify an integer, usually as a hex value, e.g., 0xf
""
DH -202
mask1 parameter, must specify a non-zero integer, usually as a hex value, e.g., 0xf
""
DH -203
decimate parameter, must be 1-255
""
DH -204
Sample rate must be a number greater than 0.124
""
DH -205
okay parameter must be disk_record_ok or null
""
DH -211
mask2 parameter cannot be non-zero unless FiLa10G input select in 'equip.ctl' is 'vsi1-2'.
""
DH -214
Clock rate (from equip.ctl) divided by sample rate must be an integer 1-255.
""
DH -301
Don't change mode while recording, use disk_record=off first or (dangerous) use disk_record_ok as the fifth parameter.
""
DH -302
mask2 cannot be used unless VSI1-2 input is selected in equip.ctl.
""
DH -304
Can't specify sample rate and decimate parameters simultaneously
""
DH -400
error retrieving acknowledgement of command
""
DH -401
error retrieving class
""
DH -501
error decoding vsi_bitmask response
""
DH -502
error decoding vsi_samplerate response
""
DI -101
No default for IF input.
""
DI -102
No default for gain.
""
DI -103
No default for IF filter.
""
DI -104
No default for AGC target.
""
DI -201
IF input must be 1-4.
""
DI -202
Attenuation must be "man", "agc", or 0 to 63.
""
DI -203
IF filter must be 1 (512-1024), 2 (10-512), 3 (1536-2048), or 4 (1024-1536), 5 (0-1024), 6 (1200-1800), 7&8 (spares).
""
DI -204
AGC target must 0-65535.
""
DI -304
AGC target not available for DBBC versions < v101.
""
DI -400
IF module position exceeds number of conditioning modules
""
DI -401
Class buffer error from monitor response.
""
DI -403
Error decoding dbbcifX/ response, could be a DBBC version mis-match, see error DI -402 for text.
""
DI -451
Class buffer error from command response.
""
DJ -101
No default for IF input.
""
DJ -102
No default for gain.
""
DJ -103
No default for AGC target.
""
DJ -201
IF input must be 1-2.
""
DJ -202
Attenuation must be "man", "agc", or 0 to 63.
""
DJ -203
AGC target must 0-65535.
""
DJ -300
IF module position exceeds number of conditioning modules
""
DJ -401
Class buffer error from monitor response.
""
DJ -403
Error decoding dbbcifX/ response, could be a DBBC3 version mis-match, see error DJ -402 for text.
""
DJ -451
Class buffer error from command response.
""
DK -101
No default for frequency
""
DK -201
Error decoding frequency, must be less than or equal to 4096
""
DK -202
Error decoding IF source, must be A, B, C, D, E, F, G, or H.
""
DK -203
Error decoding bandwidth, must be one of: 2, 4, 8, 16, or 32.
""
DK -204
Averaging period must be a positive integer 60 or less.
""
DK -302
IF source exceeds number of conditioning modules
""
DK -401
Class buffer error from monitor response.
""
DK -403
Error decoding dbbcNN/ response, could be a DBBC version mis-match, see error DC -402 for text.
""
DK -451
Class buffer error from command response.
""
DP -301
No command form of pfbX command.
""
DP -302
Error response from DBBC in pfbX command.
""
DP -401
Class buffer error from monitor response.
""
DP -402 Place Holder

""
DP -403
Error decoding power/ response, could be a DBBC version mis-match, see error DP -402 for text.
""
DP -501
Only DBBC PFB rack types supported in pfbX commands.
""
DQ -1
Invalid state number for bbc (0 to 64).
""
DQ -2
Invalid LO frequency for bbc (100.0 to 1000.0Mhz). 
""
DQ -3
Invalid IF source for bbc command (i1, i2, i3, i4, none).
""
DQ -4
Invalid bandwith for bbc (16,8,4,2,1,0,5,0,25,0.125,0.0625 in Mhz).
""
DQ -5
Invalid TPI averaging period for bbc (0.01 to 10 seconds).
""
DQ -6
Invalid AGC mode for bbc (on, off).
""
DQ -10
Invalid state number for ifx (0 to 64).
""
DQ -11
Invalid attenuator value (0 to 30, step of 2 or auto).
""
DQ -12
Invalid source (alt, dir or none).
""
DQ -13
Invalid TPI averaging period for ifx (0.01 to 10 seconds).
""
DQ -20
Invalid encode scheme (vlba or sbin).
""
DQ -21
Invalid agc mode (on or off).
""
DQ -22
Invalid module name for powermon (clk, ifx, bbcx). Blank for all.
""
DQ -23
Invalid mode value.
""
DQ -24
Invalid parameter for status request (long, short, brief).
""
DQ -25
Message (>0) or error (<0) code required.
""
DQ -30
Invalid option for frequency switching.
""
DQ -31
Invalid number of state for frequency switching (1 to 64).
""
DQ -32
Invalid period for frequency switching (> 0.02seconds).
""
DQ -33
Invalid state number (1 to 64).
""
DQ -34
Invalid bbc number (1 to 4).
""
DQ -35
Invalid LO frequency (100.0 to 1000.0Mhz).
""
DQ -36
Invalid If source (i1, i2, i3, i4, i?d, i?a)
""
DQ -40
Device not specified (da or r1).
""
DQ -41
Invalid parameter for diag (self1).
""
DQ -45
No parameters. Monitor only.
""
DQ -50
Must specify a bbc number (1 to 4).
""
DQ -51
Invalid bbc number (1 to 4).
""
DQ -52
Invalid state number (0 to 64).
""
DQ -70
Invalid device for ping (da ro r1).
""
DS   -1
Unable to open dsad.ctl file.
""
DS   -2
Too many devices in dsad.ctl file.
""
DS   -3
Trouble with class buffers in DSCON.
""
DS   -4
Dataset interface not initialised.
""
DS   -5
Unrecognised Dataset mnemonic ?W.
""
DS   -6
Error in Dataset ?W request buffer format.
""
DS   -7
Unable to open Dataset device.
""
DS  -11
Time-out or error on reading from Dataset ?W.
""
DS  -12
Dataset ?W response was corrupted.
""
DS  -21
Dataset ?W request write failed.
""
DS  -22
Dataset device name is /dev/null, All datasets inaccessible.
""
DS -101
No default for Dataset mnemonic.
""
DS -102
No default for Dataset function.
""
DS -201
Dataset mnemonic must be 2 characters.
""
DS -202
Dataset function must be between 0 and 511.
""
DS -203
Dataset function data must be a hexadecimal value.
""
DS -301
Must have 2 or 3 parameters, see help file.
""
DS -401
Trouble with class buffer from DSCON.
""
DS -801
Dataset ?W WARNING: a non-terminating subtask loop has been detected.
""
DS -802
Dataset ?W WARNING: an abnormal condition occured during initialisation.
""
DS -803
Dataset ?W WARNING: a subroutine has returned an unknown error flag.
""
DS -804
Dataset ?W WARNING: the internal NVRAM battery is getting low.
""
DS -805
Dataset ?W WARNING: the previous request packet contained too few frames.
""
DS -806
Dataset ?W WARNING: the serial port output buffer has overflowed.
""
DS -807
Dataset ?W WARNING: the previous response packet contained too few frames.
""
DS -808
Dataset ?W WARNING: the dataset program has been restarted by power on or reset.
""
DS -901
Dataset ?W ERROR: the serial port input buffer has overflowed.
""
DS -902
Dataset ?W ERROR: a request frame has been found with a parity error.
""
DS -903
Dataset ?W ERROR: the previous request frame was truncated.
""
DS -904
Dataset ?W ERROR: a packet syntax error (unknow escape sequence) was seen.
""
DS -905
Dataset ?W ERROR: the requested function is not implemented in this dataset.
""
DS -906
Dataset ?W ERROR: an internal program error has been detected (xprogerr).
""
DS -907
Dataset ?W ERROR: the previous function is still executing, request ignored.
""
DS -908
Dataset ?W ERROR: an internal program error has been detected (xpaderr).
""
DT -300
IF module position exceeds number of conditioning modules
""
DT -301
Command does accept parameters,
""
DT -401
Class buffer error from monitor response.
""
DT -403
Error decoding dbbctpifX/ response, could be a DBBC3 version mis-match, see error DT -402 for text.
""
DT -451
Class buffer error from command response.
""
DV -201
Error decoding channel number of parameter 1
""
DV -202
Error decoding channel number of parameter 2
""
DV -203
Error decoding channel number of parameter 3
""
DV -204
Error decoding channel number of parameter 4
""
DV -205
Error decoding channel number of parameter 5
""
DV -206
Error decoding channel number of parameter 6
""
DV -207
Error decoding channel number of parameter 7
""
DV -208
Error decoding channel number of parameter 8
""
DV -209
Error decoding channel number of parameter 9
""
DV -210
Error decoding channel number of parameter 10
""
DV -211
Error decoding channel number of parameter 11
""
DV -212
Error decoding channel number of parameter 12
""
DV -213
Error decoding channel number of parameter 13
""
DV -214
Error decoding channel number of parameter 14
""
DV -215
Error decoding channel number of parameter 15
""
DV -216
Error decoding channel number of parameter 16
""
DV -221
No such channel for parameter 1
""
DV -222
No such channel for parameter 2
""
DV -223
No such channel for parameter 3
""
DV -224
No such channel for parameter 4
""
DV -225
No such channel for parameter 5
""
DV -226
No such channel for parameter 6
""
DV -227
No such channel for parameter 7
""
DV -228
No such channel for parameter 8
""
DV -229
No such channel for parameter 9
""
DV -230
No such channel for parameter 10
""
DV -231
No such channel for parameter 11
""
DV -232
No such channel for parameter 12
""
DV -233
No such channel for parameter 13
""
DV -234
No such channel for parameter 14
""
DV -235
No such channel for parameter 15
""
DV -236
No such channel for parameter 16
""
DV -300
Maximum 16 parameters for vsiX command.
""
DV -301
No monitor form of vsiX command.
""
DV -302
Error response from DBBC in vsiX command.
""
DV -451
Class buffer error from command response.
""
DV -501
Only DBBC PFB rack types supported in vsiX commands.
""
ER -902
Unable to find ":" in S2 error decode response.
""
FL   -1
Previous source in this schedule not reached before new source was commanded
""
FL   -2
FLAGR detected error in ANTCN, see above for error.
""
FM   -1 FMPSEE Place Holder

""
FP   -1
Break Detected in FIVPT
""
FP   -2
FIVPT RN already locked
""
FP  -10
Diagnostic: Unknown axis system found in REOFF
""
FP  -20
Did not reach source in allotted time
""
FP  -30
ANTCN failed too many times
""
FP  -40
Diagnostic: Unknown axis system found in LOCAL
""
FP  -60
Diagnostic: Unknown axis system found in GOOFF
""
FP  -70
Device Timed Out
""
FP  -71
Device returned wrong number of characters
""
FP  -72
Device communication failed too many times
""
FP  -80
TPI Overflowed
""
FP  -81
Diagnostic: Unknown device
""
FP  -82
TPI overflowed too many times
""
FP  -83
Error reading user device.
""
FP  -90
program error: incorrect response count from mcbcn_v.
""
FP  -91
program error: incorrect response count from vget_att.
""
FP  -92
program error: incorrect response count from vset_zero.
""
FP  -93
program error: incorrect response count from vrst_att.
""
FP  -94
program error: incorrect response count from mcbcn_d #1
""
FP  -95
program error: incorrect response count from mcbcn_d #2
""
FP  -96
program error: incorrect response count from mcbcn_r
""
FP -100
Couldn't get back to source after an error
""
FP -110
Couldn't reset attenuators after an error
""
FP -111
Couldn't set manual gain control
""
FP -112
Couldn't restore automatic gain control (AGC), or for VLBA to previous value.
""
FP -401
Class buffer error, from monitor response for DBBC IF gain control.
""
FP -402
Error decoding IFx response for DBBC IF gain control.
""
FP -403
Class buffer error, from DBBC voltage read response.
""
FP -404
Error decoding BBCnn response for voltage from DBBC.
""
FP -405
Error decoding IFx response for voltage from DBBC.
""
FP -406
Error decoding power=n response for voltage.
""
FP -410
Class buffer error, for monitor response from RBDE.
""
FV   -1
fmset: Error receiving message from matcn
""
FV   -2
fmset: Error receiving time from matcn
""
FV   -3
fmset: Mark IV Formatter date less than 1970 or greater than Jan 2038.
""
FV   -4
fmset: Error receiving message from mcbcn
""
FV   -5
fmset: Bad completion code from mcbcn
""
FV   -6
fmset: Error receiving message from matcn
""
FV   -7
fmset: Error resetting FS time, please see messages above.
""
FV   -8
fmset: Error from MK5CN, please see messages above.
""
FV   -9
fmset: Error from DBBCN, please see messages above.
""
FV  -10
fmset: Error from MATCN, please see messages above.
""
FV  -11 FMSET place holder

""
FV -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
FV -402
Program error: less than zero length data object request for device ?W
""
FV -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
HL   -1
Break Detected in HOLOG
""
HL   -3
HOLOG already running
""
HL   -4
Error occurred while trying to return to source at end. Check offsets.
""
HL   -5
Error occurred forming the command to send.
""
HL   -6
Command formed is too big.
""
HL  -20
Did not reach source in allotted time
""
HL  -30
ANTCN failed too many times
""
HL  -40
Diagnostic: Unknown axis system found in LOCAL
""
HL  -60
HOLOG Diagnostic: Unknown axis system found in GOOFF
""
IB   -1
Trouble with GPIB class buffer
""
IB   -2
Illegal GPIB mode
""
IB   -3
Unrecognized GPIB device
""
IB   -4
GPIB Device time-out on response ?W
""
IB   -5
Improper GPIB response (wrong number of chars)
""
IB   -6
Attempt to read from a listen-only GPIB device
""
IB   -7
Attempt to write to a talk-only GPIB device
""
IB   -8
GPIB error condition, check driver manual UGPIB section for explanation
""
IB   -9
GPIB UNIX error code ?WWW
""
IB  -10
ibcon initialization failed, gpib devices inaccessible.
""
IB  -11
gpib driver not installed, gpib devices inaccessible.
""
IB  -12
gpib device is /dev/null, gpib devices inaccessible.
""
IB -101
Number of entries from IBAD control file exceed table limit of ?WWW
""
IB -201
GPIB error condition ?WWW
""
IB -202
Internal error, board name length invalid in opbrd, ?W
""
IB -203
Internal error, device name length invalid in opdev, ?W
""
IB -300
GPIB(edvr) unix error, see message above, ?W
""
IB -301
GPIB(ecic) function requires GPIB board to be CIC, ?W
""
IB -302
GPIB(enol) write handshake error, CHECK instrument and cable, ?W
""
IB -303
GPIB(eadr) GPIB board not addressed correctly, ?W
""
IB -304
GPIB(earg) invalid argument to function call, ?W
""
IB -305
GPIB(esac) GPIB board not system controller as required, ?W
""
IB -306
GPIB(eabo) I/O operation aborted, ?W
""
IB -307
GPIB(eneb) not-existent GPIB board, ?W
""
IB -308 
GPIB(edma) DMA hardware error, ?W
""
IB -309
GPIB(ebto) DMA hardware bus timeout, ?W
""
IB -311
GPIB(ecap) no capability for type of operation, ?W
""
IB -312
GPIB(efso) file system error, ?W
""
IB -314
GPIB(ebus) GPIB bus error, ?W
""
IB -315
GPIB(estb) serial poll queue overflow, ?W
""
IB -316
GPIB(esrq) SRQ line asserted by unknown device, ?W
""
IB -320
GPIB(ibfind) failed to open GPIB special file, no file descriptor returned, ?W
""
IB -321
GPIB(ibufln) the returned data string is longer then expected.
""
IB -322
GPIB driver not installed
""
IB -400
GPIB/232 converter serial error, see message above, ?W
""
IB -401
GPIB(ecic) function requires GPIB board to be CIC, ?W
""
IB -402
GPIB(enol) write handshake error, CHECK instrument and cable, ?W
""
IB -403
GPIB(eadr) GPIB board not addressed correctly, ?W
""
IB -404
GPIB(earg) invalid argument to function call, ?W
""
IB -405
GPIB(esac) GPIB board not system controller as required, ?W
""
IB -406
GPIB(eabo) I/O operation aborted, ?W
""
IB -411
GPIB(ecap) no capability for type of operation, ?W
""
IB -414
GPIB(ebus) GPIB bus error, ?W
""
IB -415
GPIB(ecmd) unrecognized command, ?W
""
IB -420
Error decoding device ID in opdev. Check ibad.ctl.
""
IB -501
Error in portopen, device name length illegal, ?W
""
IB -502
Error in portopen, open failed, see message above, ?W
""
IB -503
Error in portopen, TCGETA failed, see message above, ?W
""
IB -504
Error in portopen, invalid stop bits, ?W
""
IB -505
Error in portopen, invalid data bits, ?W
""
IB -506
Error in portopen, invalid parity, ?W
""
IB -507
Error in portopen, invalid BAUD, ?W
""
IB -508
Error in portopen, TCSETA failed, see message above,?W
""
IB -509
Error in portopen, TIOCGSERIAL failed EINVAL not DIGI , see message above, ?W
""
IB -510
Error in portopen, TIOCSSERIAL failed, see message above, ?W
""
IB -511
Error in portopen, DIGI TCGETA failed, see message above, ?W
""
IB -512
Error in portopen, DIGI_GETA failed, see message above, ?W
""
IB -513
Error in portopen, DIGI_SETAW failed, see message above, ?W
""
IB -514
Error in portopen, DIGI TCSETA failed, see message above, ?W
""
IB -515
Error in portopen, TIOCGSERIAL failed not EINVAL, see message above, ?W
""
IB -516
Error in portopen, non-blocking open failed, see message above, ?W
""
IB -517
Error in portopen, non-blocking TCGETA failed, see message above, ?W
""
IB -518
Error in portopen, non-blocking TCSETA failed, see message above, ?W
""
IB -519
Error in portopen, non-blocking close failed, see message above, ?W
""
IB -521
Error in sib, portflush failed, see message above, ?W
""
IB -522
Error in sib, portwrite failed, see message above, ?W
""
IB -523
Error in sib, portread buffer had no extent, ?W
""
IB -524
GPIB/232 converter timed out, ?W
""
IB -525
Error reading GPIB/232 converter, see message above ?W
""
IB -526
Error decoding GPIB/232 ibsta, ?W
""
IB -527
Error decoding GPIB/232 iberr, ?W
""
IB -528
Error decoding GPIB/232 ibser, ?W
""
IB -529
Error decoding GPIB/232 ibcnt, ?W
""
IB -541
GPIB/232 (EPAR) serial parity error detected by converter, ?W
""
IB -542
GPIB/232 (EORN) serial over-run error detected by converter, ?W
""
IB -543
GPIB/232 (EOFL) serial buffer overflow detected by converter, ?W
""
IB -544
GPIB/232 (EFRM) serial data framing error detected by converter, ?W
""
IF -301
Error can't open ifatt.ctl.
""
IF -302
>=100 entries. Only 100 entries in SHM, cleanup 'ifatt.ctl'.
""
IF -303
>=50 entries. Only 100 entries allowed, start cleanup of 'ifatt.ctl'.
""
IF -304
mode_name not found - misspelled,or not in SHM.
""
IF -501
No VC's patched
""
IF -502
Unable to decode IF 1 or 2 attenuator setting
""
IF -503
Wrong number of TPI records returned
""
IF -504
Unable to decode VC ?W power level
""
IF -505
The attenuators for one or more IF channels failed to converge.
""
IF -506
The attenuators for IF channel 1 failed to converge.
""
IF -507
The attenuators for IF channel 2 failed to converge.
""
IF -508
The attenuators for IF channel 3 failed to converge.
""
IF -509
Unable to decode IF 3 attenuator setting
""
IF -510
Break detected in IFADJUST.
""
IF -511
VC(s) in trackform not patched.
""
IF -512
Mark 5B bit mask not set.
""
IF -513
vsi4 must be configured.
""
IF -514
VC(s) in vsi4 configuration not patched.
""
IF -515
NO VCs selecte when vsi4 configuration is TVG.
""
IF -516
vsi4 has impossible configuration.
""
KA -201
K4 tape label must have 8 characters or be a "#".
""
KB -201
Bandwith must be one of 2, 4, 8, 16, 32 depending on VC type.
""
KC -101
No default port A.
""
KC -201
Port A must be 1-16. 
""
KC -102
No default port B.
""
KC -202
Port B must be 1-16. 
""
KE -301
No equals for ET command.
""
KF -101
No default for the mode.
""
KF -201
Mode must be one of a, b, c, d.
""
KF -202
Rate must be one of 0.25, 0.5, 1, 2, 4, 8.
""
KF -203
Input must be one of nor, ext, crc, low, high.
""
KF -204
Aux data must be up to 12 hex digits.
""
KF -205
Sync must be on or off.
""
KF -206
Aux start must be frm or 1pps.
""
KF -207
Output  must be nor, high, or low.
""
KF -301
Formatter is not in remote.
""
KI -201
IF attenuator 1 must be 0-15.
""
KI -202
IF attenuator 2 must be 0-15.
""
KI -203
IF attenuator 3 must be 0-15.
""
KI -204
IF attenuator 4 must be 0-15.
""
KI -301
VCIF only supported for K-4 type 1 VCs.
""
KL -101
No default for channel number.
""
KL -102
No default for frequency.
""
KL -201
Channel must be 1-16 for K-4 type 1 VCs and 1-8 for type 2 VCs.
""
KL -202
Frequency must be 99.99-511.99 for K-4 type 1 VCs and 499.99-999.99 for type 2.
""
KM -201
Record mode bandwidth must be one of 16, 32, 64, 128, or 256.
""
KM -202
Number of sample bits must be one of 1, 2, 4, or 8.
""
KM -203
Number of channels must be one of 1, 2, 4, 8, or 16.
""
KM -204
Time stamp mode is either FB or FT.
""
KM -205
Time stamp insertion time must be 0 to 30 or 99.
""
KM -301
Record mode bandwidth can only be set for K4 type 2 recorder (DFC2100).
""
KO -301
oldtape command requires a non-NULL parameter
""
KP -201
Recorder port number must be 1-16
""
KP -202
Channel input must be one of 1...16u/l for K4 type 1 rack.
""
KP -203
Channel input must be one of a1...a8u/l for K4 type 2 rack.
""
KP -204
Channel input must be one of 1...14u/l for Mark III/IV or none rack.
""
KP -300
There mus be pairs of ports, channels.
""
KR -101
No default for action.
""
KR -201
Action must be one of: eject, init, synch, drum_on drum_off, synch_on, synch_off, or 7 digit position to move to.
""
KR -202
Aux data must be 16 hex digits.
""
KS -201
ST parameter must be one of play or record.
""
KS -301
rec_mode must be set-up first
""
KT -101
No default for tape parameter.
""
KT -201
Parameter must be reset.
""
KV -101
No default for channel number.
""
KV -201
Channel must be 1-16 for type 1 VC and 1-8 for type 2 VC.
""
KV -202
Attenuator must 0-15 (type 1 VC) or range must be low or high (type 2 VC).
""
KV -203
Sideband musb usb or lsb.
""
K4 -201
Device mnemonic must have 2 characters.
""
K4 -203
Mode must be one of read, read/write, poll, status, and clear.
""
K4 -204
Format must be normal, binary, or ascii.
""
K4 -205
Length must be normal or a positive integer.
""
K4 -301
k4ib must have equals.
""
LC -201
Correlator type must be AT (4 level) or MB (3 level).
""
LC -202
Primary source must be one of USB, LSB, BSU, BSL, FTU, FTL, 32 or 64.
""
LC -203
Secondary source must be one of USB, LSB, BSU, BSL, FTU, FTL, 32 or 64.
""
LC -204
AT correlator output clock delay must be between 0 and 3.
""
LC -301
Command only takes 4 parameters.
""
LC -901
Error detected while writing to DAS through AT Dataset driver DSCON.
""
LC -902
Error detected while reading from DAS through AT Dataset driver DSCON.
""
LC -903
Required DAS hardware not available, check equip.ctl.
""
LF -201
Band Splitter digital output (Fine Tuner input) setting must be LSB or USB.
""
LF -202
Frequency specified lies outside range of current Band Splitter bandwidth.
""
LF -203
Filter bandwidth must be between 1 and 1/16th of current Band Splitter bandwidth.
""
LF -204
Filter mode must be NONE, DSB, SCB or ACB (first two only at specific bandwidths).
""
LF -205
Frequency offset specified lies outside range of current Band Splitter bandwidth.
""
LF -206
Phase offset must be between 0 and 360 degrees.
""
LF -207
Fine Tuner NCO test mode must be OFF or ON.
""
LF -301
Command only takes 7 parameters.
""
LF -901
Error detected while writing to DAS through AT Dataset driver DSCON.
""
LF -902
Error detected while reading from DAS through AT Dataset driver DSCON.
""
LF -903
Required DAS hardware not available, check equip.ctl.
""
LF -904
Fine Tuner is currently not available - see IFPnn settings.
""
LG   -1 Place Holder for lgerr Error

""
LG    1 Place Holder for lgerr Warning

""
LI -101
No default for frequency.
""
LI -201
Frequency specified lies outside tuning range for given filter settings.
""
LI -202
Bandwidth must be one of 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32 or 64 MHz.
""
LI -203
Filter mode must be one of SCB, ACB, DSB, SC1, AC1, DS2 (and DS4, DS6 at 8MHz).
""
LI -204
Upper sideband/Centre band spectrum inverter must be NAT or FLIP.
""
LI -205
Lower sideband spectrum inverter must be NAT or FLIP.
""
LI -206
Recorder 2-bit output format must be AT (true sign & magnitude) or VLBA.
""
LI -207
Internal 2-bit sampler statistics must be either 4LVL or 3LVL.
""
LI -301
Command only takes 7 parameters.
""
LI -901
Error detected while writing to DAS through AT Dataset driver DSCON.
""
LI -902
Error detected while reading from DAS through AT Dataset driver DSCON.
""
LI -903
Required DAS hardware not available, check equip.ctl.
""
LM -201
Band Splitter analog monitor setting must be LSB or USB.
""
LM -202
Fine Tuner analog monitor setting must be USB or LSB.
""
LM -203
Fine Tuner digital output setting must be USB or LSB.
""
LM -301
Command only takes 3 parameters.
""
LM -901
Error detected while writing to DAS through AT Dataset driver DSCON.
""
LM -902
Error detected while reading from DAS through AT Dataset driver DSCON.
""
LM -903
Required DAS hardware not available, check equip.ctl.
""
LT -100
No default for trackform track number.
""
LT -200
Trackform track number must be in the range 0-15.
""
LT -201
Trackform track already in use.
""
LT -301
Trackform internal error, bsfo2vars bs=NULL.
""
LT -302
No default for trackform bit-stream.
""
LT -303
Unknown trackform bit-stream.
""
LT -304
Trackform bit-stream comes from uninitialized IFP.
""
LT -305
No LSB bit-stream available at 32 or 64 MHz bandwidth.
""
LT -306
No magnitude bit-stream available at 64 MHz bandwidth.
""
LT -307
Requested fan-out does not exist at this bandwidth.
""
LT -308
Sign bit-streams must go to even tracks, magnitude to odd.
""
LT -309
Sign & magnitude bit-streams must be assigned in pairs.
""
LT -901
Error detected while writing to DAS through AT Dataset driver DSCON.
""
LT -902
Error detected while reading from DAS through AT Dataset driver DSCON.
""
LT -903
Required DAS hardware not available, check equip.ctl.
""
MA   -1
Trouble with class buffer
""
MA   -2
Illegal mode
""
MA   -3
Unrecognized device
""
MA   -4
Device ?W timed-out on response.
""
MA   -5
Improper response (wrong number of chars)
""
MA   -6
Verify error
""
MA   -7
MAT device is /dev/null, MAT devices inaccessible.
""
MA   -8
Did not get Mark IV formatter prompt.
""
MA   -9
MAT not open.
""
MA  -10
MAT had bad buffer length for read (programming error).
""
MA  -11
MAT read error from UNIX, see error message above.
""
MA  -12
MAT error setting BAUD.
""
MA -100
Unable to open MAT device, ?WWW
""
MA -101
Number of entries from MATAD control file exceed table limit of ?WWW
""
MA -102
Unsupported BAUD rate, use one of 110, 300, 600, 1200, 2400, 4800, or 9600.
""
MA -103
Error closing MAT port ?WWW.
""
MA -104
Working around possible serial line problem, there may be a 30 second pause.
""
MA -105
Recovery seemed to succeed.
""
MA -106
Recovery seemed to fail. You'll have to restart the FS to use MAT bus.
""
MA -701
MK4 DE unknown command 
""
MA -702
MK4 DE wrong number of arguments
""
MA -703
MK4 DE illegal argument type
""
MA -704
MK4 DE argument out of range
""
MA -801
MK4 FM auxdata loading conflict 
""
MA -802
MK4 FM auxdata not in idle state 
""
MA -803
MK4 FM system not in STOP state 
""
MA -804
MK4 FM board number out of range 
""
MA -805
MK4 FM illegal a/d converter bit 
""
MA -806
MK4 FM no tokens found 
""
MA -807
MK4 FM don't recognize command 
""
MA -808
MK4 FM parameter out of range 
""
MA -809
MK4 FM MUX - SAMPLE RATE conflict 
""
MA -810
MK4 FM phasecal select conflict 
""
MA -811
MK4 FM A/D converter vs. mode conflict 
""
MA -812
MK4 FM unknown configuration mode  
""
MA -813
MK4 FM map parameter out of range 
""
MA -814
MK4 FM track parameter out of range 
""
MA -815
MK4 FM a/d parameter out of range 
""
MA -816
MK4 FM bad a/d selection 
""
MA -817
MK4 FM bcd out of range 
""
MA -818
MK4 FM bad parameter count 
""
MA -819
MK4 FM parameter out of range 
""
MA -820
MK4 FM parameter conflict  
""
MA -821
MK4 FM no site 1 pps signal    
""
MA -822
MK4 FM no 2 msec warning from internal clock 
""
MA -823
MK4 FM clock out of sync 
""
MA -824
MK4 FM format is not synced to internal 1pps 
""
MA -825
MK4 FM no mk4 frame detected 
""
MA -826
MK4 FM display controller stays busy  
""
MA -827
MK4 FM illegal bits/sample 
""
MA -828
MK4 FM illegal multiplex mode 
""
MA -829
MK4 FM illegal sample rate  
""
MA -830
MK4 FM xilinx reprogram error  
""
MA -831
MK4 FM front panel display hung busy 
""
MA -851
MK4 FM C_FIRMWARE_ERROR -1
""
MA -852
MK4 FM T_LATCH_ERROR -2
""
MA -853
MK4 FM X_FIRMWARE_ERROR -3
""
MA -854
MK4 FM V_FIRMWARE_ERROR -4    
""
MA -998
MK4 DE error exceeds FS reportable range
""
MA -999
MK4 FM error exceeds FS reportable range
""
MC   -1
Interface ?W timed-out.
""
MC   -2
Interface ?W responded, but did not ACKnowledge.
""
MC   -3
Interface ?W detected parity error.
""
MC   -4
Interface ?W failed to handshake on command.
""
MC   -5
Interface ?W failed to handshake on monitor.
""
MC   -6
Interface ?W timed-out on last monitor byte.
""
MC  -18
Interface ?W has the wrong address.
""
MC  -19
Interface ?W has the wrong block length.
""
MC  -20
Formatter MM:SS stuck.
""
MC  -21
Write request to mcb device failed.
""
MC  -22
MCB device is /dev/null, MCB devices inaccessible.
""
MC -101
Unable to open mcbcn.ctl file.
""
MC -102
Too many devices in mcbcn.ctl file.
""
MC -103
Class buffer problems in mcbcn.
""
MC -104
MCBCN not initiliazed.
""
MC -105
Unknown interface mnemonic ?W.
""
MC -106
Illegal mode.
""
MC -107
Unable to open mcb device.
""
MC -108
Error in request buffer format.
""
M5   -1
mk5cn: error opening mk5ad.ctl
""
M5   -2
mk5cn: error pushing back on mk5ad.ctl
""
M5   -3
mk5cn: first non-comment line in mk5ad.ctl did not contain three tokens
""
M5  -11
mk5cn: error opening socket
""
M5  -13
mk5cn: error from gethostbyname()
""
M5  -14
mk5cn: host had NULL IP address
""
M5  -15
mk5cn: error connecting to host
""
M5  -16
mk5cn: error opening stream
""
M5  -17
mk5cn: error gethostbyname(): HOST_NOT_FOUND
""
M5  -18
mk5cn: error gethostbyname(): TRY_AGAIN
""
M5  -19
mk5cn: error gethostbyname(): NO_RECOVERY
""
M5  -20
mk5cn: error gethostbyname(): NO_ADDRESS
""
M5  -21
mk5cn: error connect(): mk5 device connection open timed-out
""
M5  -22
mk5cn: error from getsockopt(), see above for error
""
M5  -23
mk5cn: error opening, mark 5 probably not running, see above for error
""
M5  -24
mk5cn: select for connect() error, see above for error
""
M5  -25
mk5cn: error gethostbyname(): DNS timed-out
""
M5  -98
mk5cn: no mk5 device defined
""
M5  -99
mk5cn: illegal mode
""
M5 -101
mk5cn: error getting class buffer
""
M5 -102
mk5cn: error sending data, connection closed
""
M5 -103
mk5cn: error on select reading data, see above for error, connection closed
""
M5 -104
mk5cn: time-out, connection closed, will reopen on next attempt
""
M5 -105
mk5cn: error on read, see above for error, connection closed
""
M5 -106
mk5cn: error and EOF on read, see above for error, connection closed
""
M5 -107
mk5cn: EOF on read, mark 5 may have crashed, connection closed
""
M5 -108
mk5cn: no data on read, but no EOF or error, connection closed
""
M5 -109
mk5cn: read too long for input buffer, connection closed
""
M5 -110
mk5cn: error pre-draining input, see above for error, connection closed
""
M5 -111
mk5cn: error and EOF pre-draining input, see above for error, connection closed
""
M5 -112
mk5cn: EOF pre-draining input, mark 5 may have crashed, connection closed
""
M5 -113
mk5cn: no data pre-draining input, but no EOF or error, connection closed
""
M5 -114
mk5cn: re-open after pre-drain error was okay, proceeding to transaction.
""
M5 -898
Mark 5B sync required, use FMSET 's'.
""
M5 -899
unable to find or decode return code
""
M5 -900 place holder for Mark 5 error string

""
M5 -901
Mark5 return code 1: action initiated or enabled, but not completed
""
M5 -902
Mark5 return code 2: command not implemented or not relevant to this DTS
""
M5 -903
Mark5 return code 3: syntax (or parameter error)
""
M5 -904
Mark5 return code 4: error encountered (during attempt to execute)
""
M5 -905
Mark5 return code 5: currently too busy to service request; try again later
""
M5 -906
Mark5 return code 6: inconsistent or conflicting request
""
M5 -907
Mark5 return code 7: no such keyword
""
M5 -908
Mark5 return code 8: parameter error
""
M5 -909
Mark5 return code 9: indeterminate state
""
M6   -1
mk6c.: error opening mk6?W.ctl
""
M6   -2
mk6c.: error pushing back on mk6?W.ctl
""
M6   -3
mk6c.: first non-comment line in mk6?W.ctl did not contain three tokens
""
M6  -11
mk6?W: error opening socket
""
M6  -13
mk6?W: error from gethostbyname()
""
M6  -14
mk6?W: host had NULL IP address
""
M6  -15
mk6?W: error connecting to host
""
M6  -16
mk6?W: error opening stream
""
M6  -17
mk6?W: error gethostbyname(): HOST_NOT_FOUND
""
M6  -18
mk6?W: error gethostbyname(): TRY_AGAIN
""
M6  -19
mk6?W: error gethostbyname(): NO_RECOVERY
""
M6  -20
mk6?W: error gethostbyname(): NO_ADDRESS
""
M6  -21
mk6?W: error connect(): mk6 device connection open timed-out
""
M6  -22
mk6?W: error from getsockopt(), see above for error
""
M6  -23
mk6?W: error opening, mark 5 probably not running, see above for error
""
M6  -24
mk6?W: select for connect() error, see above for error
""
M6  -25
mk6?W: error gethostbyname(): DNS timed-out
""
M6  -98
mk6?W: no mk6 device defined
""
M6  -99
mk6?W: illegal mode
""
M6 -101
mk6?W: error getting class buffer
""
M6 -102
mk6?W: error sending data, connection closed
""
M6 -103
mk6?W: error on select reading data, see above for error, connection closed
""
M6 -104
mk6?W: time-out, connection closed, will reopen on next attempt
""
M6 -105
mk6?W: error on read, see above for error, connection closed
""
M6 -106
mk6?W: error and EOF on read, see above for error, connection closed
""
M6 -107
mk6?W: EOF on read, mark 5 may have crashed, connection closed
""
M6 -108
mk6?W: no data on read, but no EOF or error, connection closed
""
M6 -109
mk6?W: read too long for input buffer, connection closed
""
M6 -110
mk6?W: error pre-draining input, see above for error, connection closed
""
M6 -111
mk6?W: error and EOF pre-draining input, see above for error, connection closed
""
M6 -112
mk6?W: EOF pre-draining input, mark 5 may have crashed, connection closed
""
M6 -113
mk6?W: no data pre-draining input, but no EOF or error, connection closed
""
M6 -114
mk6?W: re-open after pre-drain error was okay, proceeding to transaction.
""
M6 -899
mk6?W: unable to find or decode return code
""
M6 -901
mk6?W: Mark6 return code 1: action initiated or enabled, but not completed
""
M6 -902
mk6?W: Mark6 return code 2: command not implemented or not relevant to this DTS
""
M6 -903
mk6?W: Mark6 return code 3: syntax (or parameter error)
""
M6 -904
mk6?W: Mark6 return code 4: error encountered (during attempt to execute)
""
M6 -905
mk6?W: Mark6 return code 5: currently too busy to service request; try again later
""
M6 -906
mk6?W: Mark6 return code 6: inconsistent or conflicting request
""
M6 -907
mk6?W: Mark6 return code 7: no such keyword
""
M6 -908
mk6?W: Mark6 return code 8: parameter error
""
M6 -909
mk6?W: Mark6 return code 9: indeterminate state
""
MN   -1 Place Holder

""
NF   -1
Break Detected in ONOFF
""
NF   -3
ONOFF already running
""
NF   -4
Error occurred while trying to return to source at end. Check offsets.
""
NF   -5
Error occurred while trying to return to AGC. Check BBC gain settings.
""
NF   -6
Error occurred while trying to restore IF att. Check IF att settings.
""
NF   -7
WARNING: Source structure correction greater than 20% for detector ?W.
""
NF  -10
MCBCN failed setting AGC
""
NF  -11
internal program error, not enough MCBCN response records getting tpi
""
NF  -12
MCBCN failed setting IF attenuators
""
NF  -13
internal program error, not enough MCBCN response records setting IF att
""
NF  -14
internal program error, not enough MCBCN response records resetting IF att
""
NF  -15
MCBCN failed resetting IF attenuators
""
NF  -16
Device communication failed getting TPI
""
NF  -17
Error retrieving DBBC BBC responses.
""
NF  -18
Error decoding DBBC BBC response.
""
NF  -19
Error retrieving DBBC IF responses.
""
NF  -20
Did not reach source in allotted time
""
NF  -21
Error decoding DBBC IF response.
""
NF  -30
ANTCN failed too many times
""
NF  -40
Diagnostic: Unknown axis system found in LOCAL
""
NF  -60
Diagnostic: Unknown axis system found in GOOFF
""
NF  -70
Device Timed Out
""
NF  -71
Device returned wrong number of characters
""
NF  -72
Device communication failed too many times
""
NF  -80
TPI Overflowed
""
NF  -81
Diagnostic: Unknown device
""
NF  -82
TPI overflowed too many times
""
NF  -83
Error reading user device.
""
NF  -90
program error: incorrect response count from mcbcn_v2.
""
NF  -91
program error: incorrect response count from vget_att.
""
NF  -92
program error: incorrect response count from vset_zero.
""
NF  -93
program error: incorrect response count from vrst_att.
""
NF  -94
program error: incorrect response count from mcbcn_d2, #1.
""
NF  -95
program error: incorrect response count from mcbcn_d2, #2.
""
NF  -96
program error: incorrect response count from mcbcn_r2, #2.
""
NF -100
Couldn't get back to source after an error
""
NF -110
Couldn't reset attenuators after an error
""
NF -111
Couldn't set manual gain control
""
NF -112
Couldn't reset gain to original value
""
NF -113
Error retrieving BBCnn response from dbbcn
""
NF -114
Error retrieving IFx response from dbbcn
""
NF -115
Error retrieving dbe_tsys response from rdb?W
""
NF -116
Error decoding dbe_tsys response from rdb?W
""
NF -117
Incorrect IF channel in dbe_tsys response from rdb?W
""
PC   -1
program error: portopen8: devdb incorrect size.
""
PC   -2
PCALR could not open data buffer.
""
PC   -3
PCALR could not get data buffer device set-up.
""
PC   -4
Data buffer BAUD rate not supported.
""
PC   -5
PCALR could not change data buffer device set-up.
""
PC   -6
PCALR RN already locked.
""
PC -101
Skipping track ?WWW, incorrect record length from data buffer.
""
PC -102
Skipping track ?WWW, incorrect checksum from data buffer.
""
PC -103
No response from data buffer, skipping track ?WWW.
""
PD  -92
IF3 mixer must be selected in or out.
""
PD  -93
VC external filter bandwidth not specified.
""
PD  -94
VC not set-up.
""
PD  -95
VC patching not specified.
""
PD  -96
selected tone must be between 0 and VC (bandwidth plus pcal spacing).
""
PD  -97
pcal spacing must be known to determine frequency of tone.
""
PD  -98
LO must be set-up to determine pcal spacing.
""
PD  -99
BBC must be set-up to determine frequency of tone.
""
PD -201
Continuous parameter must be yes or no.
""
PD -202
Bits parameter must be auto, 0, or 1.
""
PD -203
Integration time must be a positive integer.
""
PF -102
No default value for 2nd argument.
""
PF -103
No default value for 3rd argument.
""
PF -104
No default value for 4th argument.
""
PF -105
No default value for 5th argument.
""
PF -106
No default value for 6th argument.
""
PF -107
No default value for 7th argument.
""
PF -108
No default value for 8th argument.
""
PF -109
No default value for 9th argument.
""
PF -110
No default value for 10th argument.
""
PF -111
No default value for 11th argument.
""
PF -112
No default value for 12th argument.
""
PF -113
No default value for 13th argument.
""
PF -114
No default value for 14th argument.
""
PF -115
No default value for 15th argument.
""
PF -116
No default value for 16th argument.
""
PF -201
First argument must a channel specifier.
""
PF -202
2nd argument must specify tone number, #n, or frequency in MHz
""
PF -203
3rd argument must specify tone number, #n, or frequency in MHz
""
PF -204
4th argument must specify tone number, #n, or frequency in MHz
""
PF -205
5th argument must specify tone number, #n, or frequency in MHz
""
PF -206
6th argument must specify tone number, #n, or frequency in MHz
""
PF -207
7th argument must specify tone number, #n, or frequency in MHz
""
PF -208
8th argument must specify tone number, #n, or frequency in MHz
""
PF -209
9th argument must specify tone number, #n, or frequency in MHz
""
PF -210
10th argument must specify tone number, #n, or frequency in MHz
""
PF -211
11th argument must specify tone number, #n, or frequency in MHz
""
PF -212
12th argument must specify tone number, #n, or frequency in MHz
""
PF -213
13th argument must specify tone number, #n, or frequency in MHz
""
PF -214
14th argument must specify tone number, #n, or frequency in MHz
""
PF -215
15th argument must specify tone number, #n, or frequency in MHz
""
PF -216
16th argument must specify tone number, #n, or frequency in MHz
""
PF -217
17th argument must specify tone number, #n, or frequency in MHz
""
PF -301
No saved value for 1st argument.
""
PF -302
No saved value for 2nd argument.
""
PF -303
No saved value for 3rd argument.
""
PF -304
No saved value for 4th argument.
""
PF -305
No saved value for 5th argument.
""
PF -306
No saved value for 6th argument.
""
PF -307
No saved value for 7th argument.
""
PF -308
No saved value for 8th argument.
""
PF -309
No saved value for 9th argument.
""
PF -310
No saved value for 10th argument.
""
PF -311
No saved value for 11th argument.
""
PF -312
No saved value for 12th argument.
""
PF -313
No saved value for 13th argument.
""
PF -314
No saved value for 14th argument.
""
PF -315
No saved value for 15th argument.
""
PF -316
No saved value for 16th argument.
""
PP -101
No default for first pcalport VC.
""
PP -102
No default for second pcalport VC.
""
PP -201
First pcalport VC must be one of 1,2,3,4,9,10,11, or 12.
""
PP -202
Second pcalport VC must be one of 5,6,7,8,13,14,15, or 16.
""
PP -401
Can't read which ports are in use.
""
PP -402
Porgram error: Impossible situation in pcalports_dis.
""
Q1 -107
No default for detectors.
""
Q1 -201
Repititions must be 1-100.
""
Q1 -202
Integration period must be 1-100.
""
Q1 -203
Cut-off must be between 0.0 and 90.0.
""
Q1 -204
Step must be between 0.0 and 90.0.
""
Q1 -205
Procedure base name must be 31 or fewers characters long.
""
Q1 -206
Wait must be 1-1200.
""
Q1 -207
Unknown detector.
""
Q1 -301
Un-supported VC detector.
""
Q1 -302
Unknown LO sideband.
""
Q1 -303
VC patching not defined.
""
Q1 -304
No detectors selected.
""
Q1 -305
ONOFF, FIVPT, or HOLOG already running.
""
Q1 -306
BBC patching not defined.
""
Q1 -307
WARNING: Source structure correction greater than 20% for detector ?W.
""
Q1 -308
Unknown IF filter.
""
Q1 -309
Unknown IF filter or unsupported IF filter for PFB BBC.
""
Q1 -310
formbbc and formif not currently supported for DBBC3.
""
Q2 -201
Satellite name longer than 24 characters.
""
Q2 -102
If satellite name or TLE file name is null, the other one must be also.
""
Q2 -103
No default for satellite tracking mode.
""
Q2 -202
TLE file name too long, probably longer than 64 characters.
""
Q2 -203
Satellite tracking mode must be one of: track, radc, azel.
""
Q2 -204
Wrap must be one of: CCW, CW, or NEUTRAL.
""
Q2 -301
No ephmeris found, satellite probably not correct in temporary TLE file.
""
Q2 -302
Premature end to ephmeris file in line ?WWWW.
""
Q2 -303
Wrong number of data entries on line ?WWWW in data file.
""
Q2 -304
Unknown tracking mode, internal program error.
""
Q2 -305
Error from system() trying to run "predict", see above UNIX error.
""
Q2 -306
The "predict" program exited with unexpected status -1.
""
Q2 -307
Time has not reached satellite ephemeris, probably due to satoff=...
""
Q2 -308
Time is beyond ephermis, probably due to satoff=...
""
Q2 -309
Opening ephemris file failed, some one must have deleted it.
""
Q2 -310
The "predict" program did not find the TLE file.
""
Q2 -311
The "predict" program did not find the QTH file.
""
Q2 -312
The "predict" program did not find the TLE or the QTH file.
""
Q2 -313
Error trying to run "predict", is "predict" installed?
""
Q2 -314
The "predict" program exited with an unkown status of ?WWW.
""
Q2 -315
Error creating temporary ephemeris file.
""
Q2 -316
Error creating temporary QTH file.
""
Q2 -317
Error opening temporary QTH file for writing.
""
Q2 -318
The "predict" program could not read the QTH file.
""
Q2 -319
TLE data not have consist catalog number in each line.
""
Q2 -320
TLE data not defined.
""
Q2 -321
Error creating temporary TLE file.
""
Q2 -322
Error opening temporary TLE file for writing.
""
Q2 -323
Can't open TLE file, check UNIX error code above.
""
Q2 -324
Can't decode some line in TLE file.
""
Q2 -325
Some TLE line 1 and/or line 2 don't have correct format in TLE file.
""
Q2 -326
Error reading TLE file, see UNIX error code above.
""
Q2 -327
Did not find satellite in TLE file.
""
Q2 -328
There is a too long line in the TLE file, maybe extra trailing space.
""
Q2 -400
WARNING: ANTCN not being run, antenna device is /dev/null.
""
Q3 -101
No default for seconds.
""
Q3 -201
Seconds did not decode.
""
Q3 -102
No default for cross.
""
Q3 -202
Cross did not decode.
""
Q3 -203
Hold parameter must be "hold" or "track".
""
Q3 -301
Time has not reached satellite ephemeris, probably due to seconds being too negative.
""
Q3 -302
Time is beyond ephermis, probably due to seconds being too positive.
""
Q3 -303
Unknown tracking mode, internal program error.
""
Q3 -304
No Satellite commanded, can't use satellite offsets.
""
Q4 -101
No default for TLE line number
""
Q4 -201
TLE Line number must be 0, 1, or 2.
""
Q4 -102
No default for TLE catalog number
""
Q4 -202
TLE catalog number must be positive.
""
Q4 -103
No default for TLE string.
""
Q4 -203
TLE line 0 too long, maximum 24 characters.
""
Q4 -213
TLE line 1 too long, maximum 69 characters.
""
Q4 -223
TLE line 2 too long, maximum 69 characters.
""
Q4 -301
TLE command program error, impossible line case.
""
Q4 -313
TLE first character in line 1 is not 1.
""
Q4 -323
TLE first character in line 2 is not 2.
""
Q4 -413
TLE can't decode catalog number in line 1.
""
Q4 -423
TLE can't decode catalog number in line 2.
""
Q4 -513
TLE line 1 catalog number does not agree with specified catalog number.
""
Q4 -523
TLE line 2 catalog number does not agree with specified catalog number.
""
Q4 -613
TLE can't decode check sum in line 1.
""
Q4 -623
TLE can't decode check sum in line 2.
""
Q4 -713
TLE line 1 check-sum doesn't match.
""
Q4 -723
TLE line 2 check-sum doesn't match.
""
QA -101
No default for tape number.
""
QA -102
No default allowed for the check label.
""
QA -201
Tape number must be 8 charaters.
""
QA -202
Check label doesn't match.  Check it and try again.
""
QA -203
Thin/thick override must be "thin" or "thick".
""
QA -301
Error RP'ing program PRLAB
""
QA -302
Cannot use mount1 (or 2)  when drive 1 (or 2) is selected.
""
QA -303
Thin/thick override not allowed unless vaccum switching is enabled.
""
QB -1
Must have parameters, see help file
""
QB -2
No default for mnemonic
""
QB -101
No default for the A/D channel.
""
QB -201
Error specifying A/D channel.  Can be 0 to 1F, or code word.
""
QB -202
Delay cal heat is ON or OFF.
""
QB -203
Box heat is OFF, A, or B controllers.
""
QB -204
S-band amplifier can be turned ON or OFF.
""
QB -205
X-band amplifier can be turned ON or OFF.
""
QB -206
K-band amplifier can be turned ON or OFF.
""
QB -207
Noise cal can be ON, OFF, EXT, OON, or OOFF.
""
QB -301
WARNING: ANTCN not being run, antenna device is /dev/null.
""
QC -101
No default for CAL switch.
""
QC -201
Cal must be ON or OFF.
""
QD -201
Only channel A or B can be decoded.
""
QD -202
Data type must be AUX, SYN, TIME, ERR, or DATA.
""
QD -301
Synch block CRC checksum test FAILED.
""
QD -302
Decode command only supports Mark III decoder.
""
QE -102
Asterisk (*) notation not supported by ENABLE command.
""
QE -103
Not a valid enable command for Mark IV.
""
QE -201
Error in 1st track specified.  Must be G1,G2,G3,G4,1,...28.
""
QE -202
Error in 2nd track specified.  Must be G1,G2,G3,G4,1,...28.
""
QE -203
Error in 3rd track specified.  Must be G1,G2,G3,G4,1,...28.
""
QE -204
Error in 4th track specified.  Must be G1,G2,G3,G4,1,...28.
""
QE -205
Error in 5th track specified.  Must be G1,G2,G3,G4,1,...28.
""
QE -207
Write electronics variable from HEAD.CTL incorrectly set.
""
QF -101
No default for mode.
""
QF -201
Formatter mode must be A, B, C, D.
""
QF -202
Formatter sample rate must be 8, 4, 2, 1, 0.5, 0.25.
""
QF -203
Source of data must be NOR, EXT, or CRC.
""
QF -204
Synch test is either ON or OFF.
""
QF -205
Maximum 12 hex characters in auxilliary data.
""
QG -201
Parity error threshold must be an integer.
""
QG -202
Sync error threshold must be an integer.
""
QG -203
Channel decoder parameter must be A, B, or AB with PARITY command.
""
QG -204
AUX check must be ON or OFF.
""
QG -205
Track assignment must be G1, G2, G3, G4, 1, ..., 28.
""
QG -206
Number with G for track assignment must be between 1 and 4.
""
QG -207
Track must be between 1 and 28.
""
QG -208
Track assignment must be between 0 and 35 and/or ALL.
""
QG -215
Track assignment must be gX, mX, vX (x=0,...3) or 0, ..., 35.
""
QG -216
Number with G, M, or V for track assignment must be between 0 and 3.
""
QG -217
Track must be between 0 and 35.
""
QG -218
Parity command only accepts one or two digit track numbers.
""
QG -302
No class number available.
""
QG -303
Track ?W parity errors exceed threshold.
""
QG -304
Track ?W sync errors exceed threshold.
""
QG -305
AUX data differs from expected value on track ?W.
""
QG -306
No tracks selected, was command set-up?
""
QG -307
Parity command doesn't support your combination of rack and recorder.
""
QG -308
Reproduce electronics from HEAD.CTL not set correctly.
""
QG -309
Odd and Even tracks requested with Odd or Even electronics.
""
QG -310
Asterisk (*) notation only supported for first track in list.
""
QG -311
Equalizer must be set with repro command first.
""
QG -312
Too few frames detected in track ?W.
""
QG -313
Error decoding Mark IV decoder dqa response.
""
QG -314
Bit rate must be set with repro command first.
""
QG -315
Bandwidth must be set with repro command first.
""
QH -101
No default for azimuth span.
""
QH -102
No default for elevation span.
""
QH -103
No default for azimuth points.
""
QH -104
No default for elevation points.
""
QH -105
No default for re-calibration period (seconds).
""
QH -106
No default for procedure base name.
""
QH -201
Azimuth span must have an absolute value less than 360.
""
QH -202
Elevation span must have an absolute value less than 90.
""
QH -203
Azimuth points must have an odd absolute value less than 100.
""
QH -204
Elevation points must have odd absolute value less than 100.
""
QH -205
Re-calibration period (seconds) must be "off" (0, default) or positive number less than 10001.
""
QH -206
Procedure base name must be 31 or fewers characters long.
""
QH -207
Onsource wait times (seconds) must be a positive number less than 1001.
""
QH -301
ONOFF, FIVPT, or HOLOG already running.
""
QH -302
HOLOG can't be run until it is set-up, HOLOG=...
""
QI -101
No default for IF1 attenuator
""
QI -102
No default for IF2 attenuator
""
QI -201
IF1 attenuator must be MAX, OLD, or between 0 and 63
""
QI -202
IF2 attenuator must be MAX, OLD, or between 0 and 63
""
QI -203
IF1 input must be NOR or ALT
""
QI -204
IF2 input must be NOR or ALT
""
QI -300
Unable to read IFD attenuator setting, default setting failed.
""
QI -301
Rack read to determine default IFD attenuators, please modify command.
""
QI -302
Last commanded IFD attenuations used as default, please modify command.
""
QJ -101
No default for track to be decoded.
""
QJ -201
Track must be between 1 and 28.
""
QJ -202
Only decoder channel A or B can be used.
""
QJ -203
Maximum 10 samples can be averaged.
""
QJ -204
Sample time must be 0 to 2 seconds.
""
QJ -205
Mode must be REC or PLAY.
""
QK   -1
Class buffer trouble.
""
QK -101
No default for the list of TPIs to be read.
""
QK -102
Previous detectors not remembered between uses.
""
QK -201
TPIs must be one of ALL,EVEN,ODD,IF1,IF2,IF3,V1,...V14,FORMVC,FORMIF.
""
QK -202
TPIs are ALL,EVENU,ODDU,EVENL,ODDL,IFA-D,1u,1l,...14u,14l,FORMBBC,FORMIF.
""
QK -203
TPIs must be one of ALL,EVEN,ODD,P1,...Pn,FORMIFP.
""
QK -204
No detectors selected
""
QK -205
TPIs are ALL,EVENU,ODDU,EVENL,ODDL,IFA-D,1u,1l,...16u,16l,FORMBBC,FORMIF.
""
QK -206
TPIs are ALL, FORMBBC, FORMIF, IFX (IX), X01-Xnn, X=available CoMos A-D, nn=16*Cores available on CoMo X
""
QK -207
FORMBBC and FORMIF are not implemented for DBBC3.
""
QK -208
TPIs are ALL,EVENU,ODDU,EVENL,ODDL,IA-IH(IFA-IFH),1u,1l,...128u,128l,FORMBBC,FORMIF.
""
QK -211
Tsys value for device ?W overflowed or was less than zero.
""
QK -212
No default for detector devices
""
QK -213
Previous detectors not remembered between uses.
""
QK -214
No rack detectors must be one of u5 or u6
""
QK -215
Tsys value for device a?W overflowed or was less than zero.
""
QK -216
Tsys value for device b?W overflowed or was less than zero.
""
QK -217
Tsys value for device c?W overflowed or was less than zero.
""
QK -218
Tsys value for device d?W overflowed or was less than zero.
""
QK -219
Tsys value for device i?W overflowed or was less than zero.
""
QK -301
VC detectors other than must be upper, lower, and dual not supported.
""
QK -302
LO sideband is unknown for detector device.
""
QK -303
Patching not defined for detector device.
""
QK -304
LBA filter mode not defined for detector device.
""
QK -306
IF source not defined for detector device.
""
QK -307
Filter not defined for detector device IF source.
""
QK -308
Detector not found.
""
QK -309
IF not defined for station device.
""
QK -401
Error retrieving device response buffers.
""
QK -402
Error decoding device response buffers.
""
QL -101
No default for the MAT address.
""
QL -201
MAT address must be 00 to FF.
""
QL -102
No default for the download location.
""
QL -202
Download location must be 0000 to FFFF.
""
QL -103
No default for the data to be downloaded.
""
QL -203
Data bytes must all be 00 to FF.
""
QM -201
Baud rate must be one of 9600,4800,2400,1200,600,300,110
""
QN -201
Error in request. Unknown module or does not match your equipment.
""
QO   -1
Class error in command processing: onsource, offset command, or track.
""
QO  -11
Error specifying onsource time-out. must be >0 and <=84600 seconds.
""
QO  -12
Error specifying onsource Tracking command to execute, must be 12 characters or less
""
QO  -13
Error specifying onsource slewing command to execute, must be 12 characters or less
""
QO  -20
Break detected in onsource check while waiting for time-out.
""
QO  -99
No parameters permitted for track command.
""
QO -101
No default for first offset.
""
QO -102
No default for second offset.
""
QO -201
Error specifying first offset.
""
QO -202
Error specifying second offset.
""
QO -301
WARNING: ONSOURCE status is SLEWING!
""
QO -302
WARNING: ANTCN not being run, antenna device is /dev/null.
""
QO -401
No default for BEAMx= until LO has  been setup.
""
QO -400
Midband freq and antenna diameter must both be non-zero for default BEAMx=.
""
QO -402
Error specifying beamsize.
""
QO -403
Model name must be: GAUSSIAN, DISK, or TWOPOINTS.
""
QO -404
No default for first flux value.
""
QO -405
No default for first angular value.
""
QO -406
Error in specifying first angular value.
""
QO -407
Error in specifying second angular value.
""
QO -408
Error in specifying third angular value.
""
QO -409
Error specifying fourth angular value.
""
QO -410
BEAM size must already be defined.
""
QO -411
First flux value must be a number.
""
QO -412
Second flux value must be a number.
""
QO -413
No default for beam5 or beam6.
""
QO -502
IF3 must be set-up first.
""
QP -201
Number of cycles must be greater than or equal to 0.
""
QP -202
Pause between cycles must be between 0 and 1800 seconds inclusive.
""
QP -203
Reproduce mode must be one of FS, BY, RW or AB.
""
QP -204
Number of blocks must be between 1 and 256 inclusive.
""
QP -205
Debug parameter must be between -2 and +2 inclusive.
""
QP -206
Exactly 2 tracks required for split mode (AB).
""
QP -207
VC must be 1 to 14, tracks 1 to 28.
""
QP -208
No phase cal.
""
QP -209
None of specified tracks have phase cal.
""
QP -301
PCALR not dormant
""
QP -302
PCALR not present
""
QQ -102
No default for patching, you must give at least one
""
QQ -201
LO parameter must be LO1, LO2, or LO3.
""
QQ -202
VC number must be from 1 to 14
""
QQ -203
Patching must be L(ow) or H(igh)
""
QQ -204
Patching must be 1-4, 5-8, 9-12, or 13-16 for K4 type 1 VC.
""
QQ -205
Patching must be a1-a8, b1-b8 for K4 type 2 VC.
""
QR -1
No class number available.
""
QR -201
Only BYP (BYPass) or RAW/READ (Read After Write) permitted.
""
QR -202
Track for decoder channel A must be 0 to 28, or 0 to 35 for Mark IV.
""
QR -203
Track for decoder channel B must be 0 to 28, or 0 to 35 for Mark IV.
""
QR -204
Bandwidth must be 4, 2, 0.5, 0.25, 0.125.
""
QR -205
Bandwidth for the equalizer must be 4, 2, 0.5, 0.25, 0.125.
""
QR -206
Tracks can't be even and odd when electronics is even or odd.
""
QR -207
Reproduce electronics variable incorrectly set.
""
QR -208
Track must be from stack 0 if read mode.
""
QR -209
Equalizer must be 0, 1, 2, 3 (DIS) or 80, 135, 160, 270.
""
QR -210
Bitrate must be 16, 8, 4, 2, or 1.
""
QR -301
Bypass in disagreement with common.
""
QR -302
Encode A track in disagreement with common.
""
QR -303
Encode B track in disagreement with common.
""
QR -304
Bandwidth for reproduce in disagreement with common.
""
QR -305
Equalizer in disagreement with common.
""
QR -306
Bitrate in disagreement with common.
""
QR -307
Vacuum level must be set with rec=load or rec=novac first.
""
QS -101
No default for source name.
""
QS -102
No default for right ascension.
""
QS -103
No default for declination.
""
QS -202
Error specifying right ascension.
""
QS -203
Error specifying declination.
""
QS -204
Error specifying epoch.
""
QS -301
Sun is not currently visible.
""
QS -302
Moon is not currently visible.
""
QS -303
No parameters are allowed after SUN.
""
QS -304
No parameters are allowed after MOON.
""
QS -305
No parameters are allowed after: stow, idle, disable, or service.
""
QS -306
WARNING: ANTCN not being run, antenna device is /dev/null.
""
QT -201
Lowtape sensor must be OFF or LOW.
""
QT -202
Reset option must be RESET or blank.
""
QU -101
No default for the tape position
""
QU -201
Tape position must be 0 to 19500.
""
QU -301
Can't position the tape while it's moving.
""
QU -302
Tape is within 100 feet of requested position.
""
QV -101
No default for video converter frequency.
""
QV -201
Video converter frequency must be between 100 and 500 MHz.
""
QV -202
VC BW must be 4, 2, (8, 16 for MK4), 0.5, 0.125 (1, 0.250 for MK3).
""
QV -203
TPI must be U, L, UL, IF, LO, or GR.
""
QV -204
USB attenuator 0 or 10 db only.
""
QV -205
LSB attenuator 0 or 10 db only.
""
QV -301
Frequency in disagreement with common.
""
QV -302
Bandwidth in disagreement with common.
""
QV -303
Total Power selection in disagreement with common.
""
QV -304
Attenuator upper in disagreement with common.
""
QV -305
Attenuator lower in disagreement with common.
""
QX -301
Error in temperature response from met sensor.
""
QX -302
Error in humidity response from met sensor.
""
QX -303
Error in pressure response from met sensor.
""
QX -304
VHF switch positions must be: A, B, C, or D.
""
QX -305
Relay switch positions must be: A or B.
""
QY   -1
Error in response from counter.
""
QZ   -1
Class error.
""
QZ -106
No default for detector.
""
QZ -201
Axis must be HADC, AZEL, XYEW, or XYSN.
""
QZ -202
Number (absolute value) of repetitions must be between 1 and 10.
""
QZ -203
Number (absolute value) of points must be between 3 and 31.
""
QZ -204
Step size must be a real number.
""
QZ -205
Integration period must be between 1 and 32.
""
QZ -206
Detector device must be one of the allowed detectors for your equipment or u5 or u6.
""
QZ -207
Wait time must be 1-1200
""
QZ -213
Detector device not one of ia/b/c/d, or bbc1 ... bbc14.
""
QZ -214
Cal noise source temp not retrievable from COMMON.
""
QZ -215
Beam size was not retrievable from COMMON.
""
QZ -216
PATCH has not setup the specified VC for FIVPT.
""
QZ -217
bbc not set-up.
""
QZ -218
Detector must be one of IFX (IX), X01-Xnn, X=available CoMos A-D, nn=16*Cores available on CoMo X
""
QZ -219
Unrecognized DBBC3 detector.
""
QZ -220
Unrecognized RDBE detector.
""
QZ -301
FIVPT is not dormant.
""
QZ -303
The VC specified for FIVPT was not setup.
""
QZ -304
Parameters were not successfully set up for FIVPT.
""
Q* -101
No default for LO channel
""
Q* -102
No default for LO frequency
""
Q* -105
No default for LO pcal spacing
""
Q* -201
Chan is lo1-3:MK3/4/5+K4, loa-d:VLBA/4/5, lo1-4:LBA/4, loa-d,2a-2d:DBBC, loa0-d0,a1-d1:RDBE, loa-h:DBBC3, lo1-8:others
""
Q* -202
LO frequency must be a positive real number
""
Q* -203
LO sideband must be one of unknown, usb, or lsb.
""
Q* -204
LO polarization must be one of unknown, rcp, or lcp.
""
Q* -205
LO pcal spacing must be a positive real number or one of unknown or off.
""
Q* -205
LO pcal offset must be a positive real number.
""
Q* -301
Previous value not permitted for LO channel.
""
Q* -302
Previous value not permitted for LO frequency.
""
Q* -303
Previous value not permitted for LO sideband.
""
Q* -304
Previous value not permitted for LO polarization.
""
Q* -305
Previous value not permitted for LO pcal spacing.
""
Q* -306
Previous value not permitted for LO pcal offset.
""
Q* -401
LO channel position exceeds number of conditioning modules
""
Q- -101
No default for User Device channel
""
Q- -102
No default for User Device LO frequency
""
Q- -103
No default for User Device sideband
""
Q- -104
No default for User Device polarization
""
Q- -105
No default for User Device center frequency
""
Q- -201
User Device must be one of u1, u2, ..., u6
""
Q- -202
User Device LO frequency must be a positive real number
""
Q- -203
User Device sideband must be one of unknown, usb, or lsb.
""
Q- -204
User Device polarization must be one of unknown, rcp, or lcp.
""
Q- -205
User Device center frequency must be a positive real number
""
Q- -206
User Device zero must be yes or no.
""
Q- -301
Previous value not permitted for User Device channel.
""
Q- -302
Previous value not permitted for User Device LO frequency.
""
Q- -303
Previous value not permitted for User Device sideband.
""
Q- -304
Previous value not permitted for User Device polarization.
""
Q- -305
Previous value not permitted for User Device center frequency.
""
Q- -306
Previous value not permitted for User Device zero
""
Q# -201
An invalid number was specified for an LU
""
Q# -202
LU must not be negative.
""
Q# -203
Maximum of 5 LUs may be specified.
""
Q& -101
No default for operator ID.
""
Q& -201
Maximum of 12 characters in operator ID.
""
Q:   -1
Trouble with class buffer
""
Q:   -2
Mode and message must be specified
""
Q:   -3
Mode 3 and 4 for MET and LOS commands only
""
Q:   -4
Message must follow comma
""
Q:   -5
Mode must be between 0 and 4
""
Q:   -6
Program PCCOM is not present
""
Q:   -7
Azimuth out of range for LOS command
""
Q:   -8
Elevation out of range for LOS command
""
Q> -4
Head positioner timed out.
""
Q> -201
Head identifier must start with R, W, or B.
""
Q> -202
Head pass number must be between 1 and 100 inclusive.
""
Q> -204
TAPEFORM has not assigned an offset for this pass number.
""
Q> -301
Unable to position head 1 within 20 tries.
""
Q> -302
Unable to position head 2 within 20 tries.
""
Q> -303
Error reading tape head position.
""
Q> -403
Wrong number of records returned from MATCN.
""
Q< -101
No default for tape direction.
""
Q< -201
Tape direction must be FOR or REV.
""
Q< -202
Tape speed must be one of the values listed in manual.
""
Q< -203
Record enable must be ON or OFF.
""
Q< -301
Vacuum is not ready.
""
Q< -302
Tape drive has an error condition, not ready.
""
Q< -303
program error: incorrect number of responses from recorder.
""
Q< -401
no default for or old value for parameter
""
Q< -501
parameter must be load or novac
""
Q< -502
Tape thickness must be set with LABEL=... before loading
""
Q< -503
novac can only be used for MK4 drives with vacuum switching
""
Q< -504
rec must set at least one parameter
""
Q< -505
Internal error, wrong sub-recorder index number.
""
Q?   -2
Tape position must be greater than or equal to 0
""
Q?   -3
Tape drive reported current position as negative
""
Q?   -4
Tape drive isn't moving
""
Q? -301
Tape drive must be stopped
""
Q^   -3
Number of parameters must be even
""
Q^  -42
Too many parameters for one line
""
Q^ -201
Pass number or offset out of range
""
Q^ -301
Missing equal sign
""
Q@   -1
Class error.
""
Q@ -201
Write head pass number out of range.
""
Q@ -202
Read head pass number out of range.
""
Q@ -203
Offset parameter must be auto or none.
""
Q@ -211
Error decoding write stack position parameter.
""
Q@ -212
Error decoding read stack position parameter.
""
Q@ -213
Write head calibration parameter must start with F,R, or U.
""
Q@ -214
Read head calibration parameter must start with F,R, or U.
""
Q@ -221
Error decoding write head position pamameter.
""
Q@ -222
Error decoding read head position parameter.
""
Q@ -231
Error decoding range parameter.
""
Q@ -232
Error decoding the number of samples.
""
Q@ -233
Error decoding step size.
""
Q@ -234
Head must be R or W.
""
Q@ -241
Error decoding number of samples.
""
Q@ -242
Error decoding number of iterations.
""
Q@ -243
Head must be R or W.
""
Q@ -251
Unknown voltage name.
""
Q@ -252
Error decoding voltage value.
""
Q@ -261
No parameters for this command.
""
Q@ -271
Head must be R or W.
""
Q@ -272
Scale calibration must be O(ld) or N(ew).
""
Q@ -273
Not supported for VLBA2/VLBA42 tape drives.
""
Q@ -281
No parameters allowed except MAT functions.
""
Q@ -282
No parameters allowed for VLBA rec.
""
Q@ -283
program error: in get_vatod.
""
Q@ -284
program error: incorrect response count in get_vatod.
""
Q@ -285
program error: incorrect response count in lvdonn_v.
""
Q@ -286
program error: incorrect response count in lvdofn_v.
""
Q@ -287
program error: incorrect response count in head_vmov.
""
Q@ -288
VLBA recorder head stack still moving.
""
Q@ -289
VLBA2/VLBA42 recorder head positioning timed-out.
""
Q@ -291
Echo control must be ON or OFF.
""
Q@ -292
program error: incorrect response count in v2_motion_done.
""
Q@ -293
program error: incorrect response count in v2_vlt_head.
""
Q@ -294
program error: incorrect response count in v2_head_vmov.
""
Q@ -301
Write pass number not defined.
""
Q@ -302
Read pass number not defined.
""
Q@ -303
No pass specified for either head.
""
Q@ -311
No position specified for either head.
""
Q@ -321
No parameters allowed.
""
Q@ -322
No position specified for either head.
""
Q@ -331
Tape must be moving.
""
Q@ -332
Cannot read tape while recording in reverse.
""
Q@ -333
LOCATE must be set-up before using.
""
Q@ -341
Tape must be moving.
""
Q@ -342
Cannot read tape while recording in reverse.
""
Q@ -343
PEAK must be set-up before using.
""
Q@ -351
The last peak failed, nothing saved.
""
Q@ -352
Write head has not been positioned, nothing saved.
""
Q@ -371
WORM command must be set-up.
""
Q@ -372
Specified head has no new calibration.
""
Q@ -401
Head did not stop moving soon enough.
""
Q@ -402
Class error in get_class.
""
Q@ -403
Undefined pass referenced.
""
Q@ -404
Head positioning failed to converge.
""
Q@ -405
Break detected, positioning aborted.
""
Q@ -406
Formatter must be set-up before calibrated positioning.
""
Q@ -407
Head ?W reached limit or is stuck.
""
Q@ -408
Error locking LVDT Resource Number.
""
Q@ -409
Error unlocking LVDT Resource Number.
""
Q@ -410
Commanded position out of range
""
Q@ -501
No default for VLBA
""
Q@ -502
No second head for VLBA
""
Q@ -506
No second head for VLBA so calibration not valid. 
""
Q+ -201
if3 attenuation must be one of 0, ..., 63, max, or old.
""
Q+ -202
if3 mixer state must be in or out.
""
Q+ -203
if3 switch 1 state must be 1 or 2.
""
Q+ -204
if3 switch 2 state must be 1 or 2.
""
Q+ -205
if3 switch 3 state must be 1 or 2.
""
Q+ -206
if3 switch 4 state must be 1 or 2.
""
Q+ -207
if3 pcal control must be on or off.
""
Q+ -300
Unable to read IF3 attenuator setting, default setting failed.
""
Q+ -301
Rack read to determine default IF3 attenuator, please modify command.
""
Q+ -302
Last commanded IF3 attenuation used as default, please modify command.
""
Q+ -303
if3 switch 1 not available, check equip.ctl.
""
Q+ -304
if3 switch 2 not available, check equip.ctl.
""
Q+ -305
if3 switch 3 not available, check equip.ctl.
""
Q+ -306
if3 switch 4 not available, check equip.ctl.
""
RA   -1
rdbc.: error opening rdb?W.ctl
""
RA   -2
rdbc.: error pushing back on rdb?W.ctl
""
RA   -3
rdbc.: first non-comment line in rdb?W.ctl did not contain three tokens
""
RA  -11
rdb?W: error opening socket
""
RA  -13
rdb?W: error from gethostbyname()
""
RA  -14
rdb?W: host had NULL IP address
""
RA  -15
rdb?W: error connecting to host
""
RA  -16
rdb?W: error opening stream
""
RA  -17
rdb?W: error gethostbyname(): HOST_NOT_FOUND
""
RA  -18
rdb?W: error gethostbyname(): TRY_AGAIN
""
RA  -19
rdb?W: error gethostbyname(): NO_RECOVERY
""
RA  -20
rdb?W: error gethostbyname(): NO_ADDRESS
""
RA  -21
rdb?W: error connect(): rdbe device connection open timed-out
""
RA  -22
rdb?W: error from getsockopt(), see above for error
""
RA  -23
rdb?W: error opening, RDBE probably not running, see above for error
""
RA  -24
rdb?W: select for connect() error, see above for error
""
RA  -25
rdb?W: error gethostbyname(): DNS timed-out
""
RA  -98
rdb?W: device not defined
""
RA  -99
rdb?W: illegal mode
""
RA -101
rdb?W: error getting class buffer
""
RA -102
rdb?W: error sending data, connection closed
""
RA -103
rdb?W: error on select reading data, see above for error, connection closed
""
RA -104
rdb?W: time-out, connection closed, will reopen on next attempt
""
RA -105
rdb?W: error on read, see above for error, connection closed
""
RA -106
rdb?W: error and EOF on read, see above for error, connection closed
""
RA -107
rdb?W: EOF on read, RDBE may have crashed, connection closed
""
RA -108
rdb?W: no data on read, but no EOF or error, connection closed
""
RA -109
rdb?W: read too long for input buffer, connection closed
""
RA -110
rdb?W: error pre-draining input, see above for error, connection closed
""
RA -111
rdb?W: error and EOF pre-draining input, see above for error, connection closed
""
RA -112
rdb?W: EOF pre-draining input, RDBE may have crashed, connection closed
""
RA -113
rdb?W: no data pre-draining input, but no EOF or error, connection closed
""
RA -114
rdb?W: re-open after pre-drain error was okay, proceeding to transaction.
""
RA -120
rdb?W: format error in dbe_dot? response for mode 4
""
RA -121
rdb?W: time field too long for dbe_dot? response for mode 4
""
RA -122
rdb?W: did not find change of second in alloted time
""
RA -899
rdb?W: unable to find or decode return code
""
RA -901
rdb?W: RDBE return code 1: action initiated or enabled, but not completed
""
RA -902
rdb?W: RDBE return code 2: command not implemented or not relevant to this DTS
""
RA -903
rdb?W: RDBE return code 3: syntax (or parameter error)
""
RA -904
rdb?W: RDBE return code 4: error encountered (during attempt to execute)
""
RA -905
rdb?W: RDBE return code 5: currently too busy to service request; try again later
""
RA -906
rdb?W: RDBE return code 6: inconsistent or conflicting request
""
RA -907
rdb?W: RDBE return code 7: no such keyword
""
RA -908
rdb?W: RDBE return code 8: parameter error
""
RA -909
rdb?W: RDBE return code 9: indeterminate state
""
RB -101
No default for label.
""
RB -201
Label too long.
""
RB -202
Type must be one or six charaters.
""
RB -203
Format can be at most 32 characters long.
""
RB -301
Label is not in CSA format as specifed.
""
RB -302
Non-CSA tape type must be 1 or 6 characters.
""
RB -303
Check-sum incorrect.
""
RB -305
Tape type must agree with label for CSA format
""
RB -306
Can't change tape type while recording
""
RB -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RB -402
Program error: less than zero length data object request for device ?W
""
RB -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RC -1
Tape drive has no vacuum.
""
RC -2
Tape drive has an error condition, not ready.
""
RC -201
Parameter must be reboot,load,unload,bot,eot,release,<feet>,feet,or zero.
""
RC -202
No vacuum on recorder or problem reading recorder.
""
RC -203
Can't zero footage of a VLBA2/VLBA42 drive.
""
RC -204
Can't set footage of a VLBA2/VLBA42 drive.
""
RC -205
Can't reboot a VLBA2/VLBA42 drive.
""
RC -206
Tape thickness must be set with LABEL=... before loading
""
RC -401
program error: incorrect number of responses in rec.
""
RD -101
No default for data valid flag.
""
RD -102
No default for playback enable flag.
""
RD -201
Data valid flag must be "on" or "off".
""
RD -202
Playback enable flag must be "use" or "ignore".
""
RD -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RD -402
Program error: less than zero length data object request for device ?W
""
RD -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RE -301
No parameters allowed for ET, RW, and FF.
""
RE -302
Internal error in s2et.c
""
RE -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RE -402
Program error: less than zero length data object request for device ?W
""
RE -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RL -131
Operation failed (non-specific error) on device ?W
""
RL -132
I/O error on device ?W.
""
RL -133
Communications timeout, RCL device probably dead on device ?W
""
RL -134
Parameter value is illegal or out of range on device ?W
""
RL -135
String parameter is too long/short on device ?W
""
RL -136
Network I/O error on device ?W
""
RL -137
Unknown host name on device ?W
""
RL -138
No connection open for that reference address on device ?W
""
RL -139
No more network connections can be opened on device ?W
""
RL -140
Network connection closed by remote host on device ?W
""
RL -141
Unexpected response packet from RCL device on device ?W
""
RL -142
Wrong packet length returned by RCL device on device ?W
""
RL -143
Bad format in packet returned by RCL device on device ?W
""
RL -300
Unknown mode request in rclcn.
""
RL -301
There must two fields on each non-comment line rclcn.ctl.
""
RL -302
The device field on a rclcn.ctl did not have two characters.
""
RL -303
An address field in rclcn.ctl was longer than 64 characters.
""
RL -304
Ran out of memory initializing rclcn.
""
RL -305
Error reading file, see previous error message.
""
RL -306
Line in rclcn.ctl greater than 131 characters or last line without new-line.
""
RL -319
Error opening rclad.ctl, see previous error message.
""
RL -320
Received a buffer with no data in rclcn.
""
RL -321
Unknown rcl device ?W
""
RL -322
Program error: impossible code for RCL_CMD_ALIGN in rclcn for ?W
""
RL -323
Program error: impossible num for RCL_CMD_POSITION_SET in rclcn for ?W
""
RL -324
Program error: impossible code for RCL_CMD_POSITION_SET in rclcn for ?W
""
RL -325
Program error: impossible num for RCL_CMD_POSITION_READ in rclcn for ?W
""
RL -326
Unimplemented RCL command function for ?W
""
RL -327
Unknown RCL command function for ?W
""
RL -328
Ping failed (unable to open device) on device ?W
""
RL -329
Device unreachable (initial ping failed) on device ?W
""
RM -201
Device parameter in RCL= command must contain two characters exactly.
""
RM -202
Error in rcl command parameter in RCL= command.
""
RM -203
Error in rcl command specific parameter in RCL= command.
""
RM -204
Error in rcl command specific parameter in RCL= command.
""
RM -205
Error in rcl command specific parameter in RCL= command.
""
RM -206
Error in rcl command specific parameter in RCL= command.
""
RM -207
Error in rcl command specific parameter in RCL= command.
""
RM -208
Error in rcl command specific parameter in RCL= command.
""
RM -209
Error in rcl command specific parameter in RCL= command.
""
RM -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RM -402
Program error: less than zero length data object request for device ?W
""
RM -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RM -501
Program error: impossible command type in rcl_dis for device ?W
""
RM -502
Program error: impossible type code in rcl_dis for device ?W
""
RN -101
No default for vacuum command.
""
RN -201
Error in vacuum level commanded.
""
RN -301
No previous "*" value available until a succesful command.
""
RN -401
Command not supported for VLBA2/VLBA42.
""
RO -101
No default for write voltage for head 1.
""
RO -102
No default for write voltage for head 2.
""
RO -201
Error in write voltage commanded for head 1.
""
RO -202
Error in write voltage commanded for head 2.
""
RO -301
No previous "*" value for head 1 available until a succesful command.
""
RO -302
No previous "*" value for head 2 available until a succesful command.
""
RO -401
Command not supported for VLBA2/VLBA42.
""
RR -101
No default for mode.
""
RR -102
No default for group.
""
RR -201
Mode string too long.
""
RR -202
Group must be an integer.
""
RR -203
Roll must be "on" or "off".
""
RR -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RR -402
Program error: less than zero length data object request for device ?W
""
RR -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RS -103
No default for speed if record state is on.
""
RS -201
Direction must be "for".
""
RS -202
Speed must be "lp" or "slp".
""
RS -203
State must be "on" ("record") or "off" ("play").
""
RS -301
Can't change speeds while recording
""
RS -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RS -402
Program error: less than zero length data object request for device ?W
""
RS -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RT -101
First parameter must be "reset", a position, "unk", or "uns".
""
RT -102
No default for second parameter.
""
RT -103
No default for third parameter.
""
RT -104
No default for fourth parameter.
""
RT -105
No default for fifth parameter.
""
RT -106
No default for sixth parameter.
""
RT -107
No default for seventh parameter.
""
RT -108
No default for eighth parameter.
""
RT -201
Position must be a number, "reset", "unk" or "uns".
""
RT -202
Position must be a number, "unk" or "uns".
""
RT -203
Position must be a number, "unk" or "uns".
""
RT -204
Position must be a number, "unk" or "uns".
""
RT -205
Position must be a number, "unk" or "uns".
""
RT -206
Position must be a number, "unk" or "uns".
""
RT -207
Position must be a number, "unk" or "uns".
""
RT -208
Position must be a number, "unk" or "uns".
""
RT -301
One or eight positions must be specified.
""
RT -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RT -402
Program error: less than zero length data object request for device ?W
""
RT -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RU -101
No default for field number.
""
RU -201
Field number must be 1-4.
""
RU -202
Label or field entry must label or field.
""
RU -204
Auto must be auto and field={1,2}, label=field, and string empty.
""
RU -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RU -402
Program error: less than zero length data object request for device ?W
""
RU -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RV -101
First parameter must be "eject" ("unload"), "re-establish", "uns", or a position.
""
RV -102
No default for second parameter.
""
RV -103
No default for third parameter.
""
RV -104
No default for fourth parameter.
""
RV -105
No default for fifth parameter.
""
RV -106
No default for sixth parameter.
""
RV -107
No default for seventh parameter.
""
RV -108
No default for eighth parameter.
""
RV -201
First parameter must be "eject" ("unload"), "re-establish" or a position.
""
RV -202
Second parameter must be a position or "uns".
""
RV -203
Third parameter must be a position or "uns".
""
RV -204
Fourth parameter must be a position or "uns".
""
RV -205
Fifth parameter must be a position or "uns".
""
RV -206
Sixth parameter must be a position or "uns".
""
RV -207
Seventh parameter must be a position or "uns".
""
RV -208
Eight parameter must be a position or "uns".
""
RV -301
One or eight positions must be specified.
""
RV -302
Incorrect number of positions returned (internal error).
""
RV -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
RV -402
Program error: less than zero length data object request for device ?W
""
RV -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
RW   -1
No signal from bar code reader.
""
RW   -2
Successive readings from bar code reader differ.
""
RZ    2
rdt?W: receiving multicast messages again
""
RZ   -1
rdt?W: Error from select(), see above message for details.
""
RZ   -2
rdt?W: multicast may not be running, no message received
""
SC   -1
setcl: incorrect number of class buffers.
""
SC   -2
setcl: formatter time out-of-range
""
SC   -3
setcl: setting system time not supported
""
SC   -4
setcl: formatter to cpu boot time difference greater than 248 days
""
SC   -5
setcl: formatter time garbled
""
SC   -6
setcl: more than 248 days since last boot, reboot required
""
SC   -7
setcl: times() has passed -1, reboot required
""
SC   -8
setcl: less than 30 days until time error, reboot as soon as possible
""
SC   -9
setcl: less than 30 days until times() returns -1, reboot as soon as possible
""
SC  -10
setcl: failed too many times, couldn't check formatter time
""
SC  -11
setcl: cannot set fs time without Mk3/4 VLBA/4, S2, K4*/MK4, DBBC/FiLa10G rack or S2, K4, M5B recorder
""
SC  -12
setcl: FS to computer time difference 0.5 seconds or greater
""
SC  -13
setcl: formatter to FS time difference 0.5 seconds or greater
""
SC  -14
setcl: Computer time not synced to NTP
""
SC  -15
setcl: Cannot determine NTP sync state
""
SC  -16
setcl: leading digits not allowed in formatter jump value
""
SC  -17
setcl: bad argument
""
SC  -18
setcl: program is already running, try "run setcl" instead.
""
SC  -19
setcl: Mark 5B 1PPS source is wrong, CONSIDER using fmset 's' option to fix.
""
SC  -20
setcl: Mark 5B clock frequency is wrong, CONSIDER using fmset 's' option to fix.
""
SC  -21
setcl: Mark 5B clock source is wrong, CONSIDER using fmset 's' option to fix.
""
SC  -22
setcl: Mark 5B clock source is wrong, CONSIDER correcting manually.
""
SC  -23
setcl: Mark 5B not sync'd, CONSIDER using fmset 's' option to fix.
""
SC  -24
setcl: Mark 5B syncerr_gt_3, CONSIDER using fmset 's' option to fix.
""
SC  -25
setcl: rte_check got error from times(), see above for error
""
SC -401
Program error: prematurely out of rclcn response_buffer for device ?W
""
SC -402
Program error: less than zero length data object request for device ?W
""
SC -403
Program error: impossible type code for rclcn_res_position_read for device ?W
""
SE -101
No default for recorder selection.
""
SE -201
Recorder selected must be 1 or 2.
""
SE -301
Recorder selection can be set/changed unless two recorders are in use.
""
SF -301
Error opening save file for reading.
""
SF -302
Error reading save file.
""
SF -303
Error closing save file after reading.
""
SF -305
Error opening save file for writing.
""
SF -306
Error setting permissions of save file.
""
SF -307
Error writing save file.
""
SF -308
Error closing save file after writing.
""
SF -309
save file was empty
""
SP   -1
Error in characters following a !
""
SP   -2
More than 512 characters in command including parameters.
""
SP   -3
More than 12 characters in function or procedure name.
""
SP   -4
Unrecognized name (not a function or procedure).
""
SP   -5
Standard format time field error.
""
SP   -6
Illegal character in date or time field.
""
SP   -7
Date or time out or range.
""
SP   -8
Alternate format time field error.
""
SP   -9
No date allowed in time field.
""
SP  -10
Attempt to schedule over New Year's eve.
""
SP  -11
Stop time occurs before start time.
""
SP  -12
More than 512 characters in expanded command.
""
SP  -13
This command not supported for your equipment, check equip.ctl.
""
SP  -14
Date more than one day in past, please give year explicitly.
""
TA   -1
tacd.ctl control file not present.
""
TA   -2
tacd.ctl control file is empty or just has comments.
""
TA   -3
TACD: Socket can not be created or someone else is using it.
""
TA   -4
TACD: Can't connect to socket.
""
TA   -5
TACD: Can't read from socket.
""
TA   -6
TACD: Can't write to socket.
""
TA   -7
,,
""
TA   -8
Syntax error in tacd.ctl - only spaces and . are allowed as delimeters.
""
TA   -9
TACD: "Wrong IP address, or TAC32 PC not setup properly.
""
TA   -10
TACD: Setting non-blocking mode failed. Can not continue.
""
TA   -11
TACD: Unknown host, bad file discriptor, or invalid IP.
""
TA -201
commands are tacd={version,status,time,average} only.
""
TC -102
cycle period has no default.
""
TC -201
Continuous parameter must be "no" or "yes" (or "stop" or "tsys").
""
TC -202
Cycle period must be a non-negative integer.
""
TC -301
Continuous cal not enabled for DBBC or DBBC3.
""
TC -302
TPICD not set-up: no detectors selected.
""
TC -303
Continuous cal Tsys only available for DBBC DDC.
""
TE   -9
Video converter frequency has not been set
""
TE  -21
Phase cal amplitude too high in VC?WWW
""
TE  -22
Phase cal amplitude too low in VC?WWW
""
TE  -23
Phase cal insufficently suppressed when off in VC?WWW
""
TE  -24
Spectrum analyzer input from VC?WWW is out of range
""
TE  -25
Low coherence amplitude between VCs ?W
""
TE  -26
Inconstant relative phase between VCs ?W
""
TE  -31
Can't separate S and X band; patching probably wrong
""
TE  -32
Extreme channels in band have the same frequency
""
V4 -201
VSI4 configuration must be vlba, geo, or tvg.
""
V4 -202
VSI4 pcalx must be 1-16.
""
V4 -203
VSI4 pcaly must be 1-16.
""
V4 -301
VSI4: nothing commanded.
""
VB -101
No default for L.O. frequency.
""
VB -102
No default for IF source.
""
VB -103
No default for USB bandwidth.
""
VB -104
No default for LSB bandwidth.
""
VB -201
L.O. frequency must be between 500.00 MHz and 999.99 MHz (0.01 MHz steps).
""
VB -202
I.F. input should be one of: a, b, c, or d.
""
VB -203
USB bandwidth should be one of: 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32.
""
VB -204
LSB bandwidth should be one of: 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32.
""
VB -205
TPI averaging period must be one of: 0, 1, 2, 4, 10, 20, 40, or 60.
""
VB -206
Gain mode must be agc or man.
""
VB -207
USB gain value must be between -18.0 and 12.0.
""
VB -208
LSB gain value must be between -18.0 and 12.0.
""
VB -401
program error: incorrect number of responses in bbc_dis.
""
VD -101
No default for bit density.
""
VD -201
Bit density must be a positive value.
""
VE -100
No default for the tracks/groups to be enabled.
""
VE -200
List elements must be one of: g0, g1, g2, g3, d1, ..., d28.
""
VE -300
Redundant list entries.
""
VE -301
mcb functions addr and test not supported for this command.
""
VE -401
program error: incorrect number of responses in venable_dis.
""
VF -101
No default for mode.
""
VF -201
Mode must be one of: prn, a, b, c, d1, ..., d28.
""
VF -202
Rate must be one of: 0.25, 0.5, 1, 2, 4, 8, 16, 32.
""
VF -203
Fan must be on of 1:1, 1:2, 1:4, 4:1, 2:1, X0, X1, or X7.
""
VF -204
Barrel-roll must be one of: off, 8:1, 8:2, 8:4, 16:1, 16:2, 16:4, off4.
""
VF -301
Modes a, b, and c are not supported for vlba rack type.
""
VF -303
Rate and fan ratio combination is not supported
""
VF -401
program error: incorrect number of responses in vform_dis.
""
VF -402
program error: incorrect number of responses in need_config.
""
VF -403
program error: incorrect number of responses in aux_active.
""
VF -990
program error: incorrect number of responses in get_vtime.
""
VI -201
IF attenuator setting must be 0 or 20.
""
VI -202
IF attenuator setting must be 0 or 20.
""
VI -203
IF input selection must be nor or ext.
""
VI -204
IF input selection must be nor or ext.
""
VI -205
IF averaging period must be one of: 0, 1, 2, 4, 10, 20, 40, or 60.
""
VI -401
program error: incorrect number of responses in dist_dec.
""
VM -100
no default for trackform track number
""
VM -200
trackform track must be 2-33.
""
VM -300
trackform internal error, unknown rack_type
""
VM -301
trackform internal error, bs2code type=NULL
""
VM -302
trackform internal error, bs2code bs=NULL
""
VM -303
trackform internal error, bs2code unknown rack_type
""
VM -304
no default for trackform bitstream
""
VM -305
unknown trackform bit-stream or not available for this rack
""
VN -100
no default for tracks track number
""
VN -200
tracks track must be v(0-3), m(0-3), or 2-33.
""
VQ -101
No default for duration.
""
VQ -201
Duration must be in the range 1-5 inclusive.
""
VQ -501
Duration must be set first.
""
VQ -502
QA recoder must be selected with form command first.
""
VR -201
modeA must be read (raw), or byp.
""
VR -202
trackA must 0-35 or 100-135 depending on recorder.
""
VR -203
trackB must 0-35 or 100-135 depending on recorder.
""
VR -204
modeB must be read (raw), or byp.
""
VR -205
equA must be std, alt1, or alt2.
""
VR -206
equB must be std, alt1, or alt2.
""
VR -301
mcb functions addr and test not supported for this command.
""
VR -401
program error: incorrect number of responses in vrepro_dis.
""
VS -1
Tape drive has no vacuum.
""
VS -2
Tape drive has an error condition, not ready.
""
VS -101
No default for tape direction.
""
VS -102
No default for tape speed.
""
VS -201
Tape direction must be for or rev.
""
VS -102
No default for tape speed unless bit density and format are defined.
""
VS -202
Tape speed must be one of the values listed in manual.
""
VS -203
Record parameter must be on or off.
""
VS -401
program error: incorrect number of responses in vst_dis.
""
VT -201
Tape parameter must be low, or off.
""
VT -202
footage parameter must be either reset or >0 and <65536
""
VT -302
Can't set footage for a VLBA2/VLBA42 drive.
""
VT -201
system tracks must be in the range 0-35
""
VT -202
system tracks must be in the range 0-35
""
VT -203
system tracks must be in the range 0-35
""
VT -204
system tracks must be in the range 0-35
""
VV -102
address argument must not be empty
""
VV -202
trouble decoding address
""
VV -203
trouble decoding data
""
VV -301
must specify at least 2 arguments for mcb command and not more than 3
""
VX -401
program error: incorrect number of responses in systracks_dis.
""
V@   -1
program error: missing class number in quikv.
""
V@   -2
Command too long for quikv to handle.
""
V@   -3
Too many parameters in command for quikv to parse.
""
V@   -4
program error: unknown command in quikv.
""
WC -100
Cablediff has no parameters.
""
WS -101
No default for scan name.
""
WS -201
Scan name must be less than 17 characters. 
""
WS -202
Session name must be less than 17 characters. 
""
WS -203
Station code must be less than 17 characters. 
""
WS -204
Error decoding scan length or value was less than zero.
""
WS -205
Error decoding continuous recording length or value was less than zero.
""
WS -301
No previous value allowed for scan name
""
WS -302
No previous value allowed for session name
""
WS -303
No previous value allowed for station code.
""
WS -304
No previous value allowed for scan length.
""
WS -305
No previous value allowed for continuous recording length.
""
WX   -1
Could not look-up server by name, see above for error.
""
WX   -2
Unable to create socket, see above for error.
""
WX   -3
Unable to set socket non-blocking, see above for error.
""
WX   -4
Unable to connect to server, see above for error.
""
WX   -5
Unable to get host address info, see above for error.
""
WX   -6
Unable to create socket on last GETADDRINFO, see above for error.
""
WX   -7
Unable to set socket non-blocking on last GETADDRINFO, see above for error.
""
WX   -8
Unable to connect to server on last GETADDRINFO, see above for error.
""
WX   -9
No useful host address info returned.
""
WX   -10
Select call failed, server timed-out, see above for error.
""
WX   -11
Met server timed-out.
""
WX   -12
Error connecting to server/retrieving met. data, see above for error.   
""
WX   -13
Error closing socket after GETADDRINFO fcntl, see above for error.
""
WX   -14
Error closing socket after GETADDRINFO connect, see above for error.
""
WX   -15
Error closing socket at end, see above for error.
