*rdbcc.ctl example file - RDBE-C communication settings
* 
* line 1: address port time-out multicast_address multicast_port
*
* using an IP address for host avoids name server problems
* using dash (-) for an address disables that function
*
* multicast_address and multicast_address can be omitted, but if 
*  omitted, both values must be omitted, in that case they default to:
*       239.0.2.30   20023
*
* time-out is in centiseconds, values below 200 are converted to 200
*
* no non-comment line means this rdbe is not used
*
* example: remote host uses a long time-out
*   192.52.61.56 5000  500
* example: local host uses a short time-out
*   128.183.107.27 5000 200
* example: with explicit multicast
*  192.168.1.124 5000 200 239.0.2.30 20023
