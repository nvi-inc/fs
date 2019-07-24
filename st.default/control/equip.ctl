********* Equipment Control File *********
* Please refer to the Control Files Manual in Volume 1 of the 
* Field System Documentation
* 
100     Tape Startup Parameter (TACC)
330     Max tape speed, ips
270     Schedule tape speed, ips
8450.   RF Frequency
60      Receiver 70K Stage Check Temperature
20      Receiver 20K Stage Check Temperature
*  VLBI equipment
MK3     type of rack (MK3, VLBA, or MK4) 
MK3     type of recorder (MK3, VLBA, or MK4)
101     Hardware ID for VLBA rack (assigned by GSFC)
*
10.0    vacuum level (inches)
0       vacuum current offset (counts)
0       vacuum current scale  (counts/in)
0       vacuum sensor offset  (in)
0       vacuum sensor scale   (in/count)
268     tape thickness (kA)
14.0    head write voltage (V)
54625   capstan size constant
*
 500.10 IF3 LO Frequency
   3    hex mask indicating which IF3 switches are installed, sw N ~ 2^(N-1)
