*monit6 control file
* only read at start-up of any instance of monit6, affects all instances
* one non-comment line per RDBE supported to control display
*   four fields: Tsys0 channel, Tsys1 channel, IF0 pcal tone, IF1 pcal tone
*     Tsys channels: 0-15, avg, sum
*                    0     is the "split" channel
*                    avg   1/average(1/Tsys_per_chan)
*                    sum   sums  counts (and Tcal) from all channels
*     pcal tones: 0-1023
*                 number is tone in MHz relative to fundamental in the band
*                        currently only multiples of 5 are calculated       
*
*RDBE-A:    
 avg avg 30 30
*RDBE-B:
 avg avg 30 30
*RDBE-C:
 avg avg 30 30
*RDBE-D:
 avg avg 30 30
