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
mk3     type of rack (mk3, vlba, vlbag, mk4, vlba4, or none)
mk3     type of recorder (mk3, mk3b, vlba, vlba2, mk4, s2, vlba4, or none)
101     Hardware ID for VLBA rack (assigned by GSFC)
*
10.0    vacuum level (inches) (if vacuum switching this is for thin tape ~5.0) 
2860    vacuum current offset (counts)
290     vacuum current scale  (counts/in)
-5.0    vacuum sensor offset  (in)
.014    vacuum sensor scale   (in/count)
268     tape thickness (kA)   (if vacuum switching this is for thin tape ~152) 
14.0    write voltage (V) (stack 1 for vlba4)
54625   capstan size constant
*
 500.10 IF3 LO Frequency
   3    hex mask indicating which IF3 switches are installed, sw N ~ 2^(N-1)
*
  a/d   VLBA formatter cross-point switch (a/d or dsm)
* additional values for vacuum switching only
15.0    thick tape vacuum level (inches)
268     thick tape thickness (kA)
14.0    thick tape write voltage (V)
* VLBA4 parameters
14.0    VLBA4 stack 2 write voltage (V) (thin tape if switching)
14.0    VLBA4 stack 2 write voltage (V) (only if switching then thick)

