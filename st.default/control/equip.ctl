********* equip.ctl Equipment Control File *********
* Please refer to the Control Files Manual in Volume 1 of the 
* Field System Documentation
* 
*  VLBI equipment
mk3     type of rack (mk3, vlba, vlbag, mk4, vlba4,
*                     k41, k41u, k41/k3, k41u/k3, k41/mk4, k41u/mk4,
*                     k42, k42a, k42b, k42bu, k42c, k42/k3, k42a/k3,
*                     k42bu/k3, k42/mk4, k42a/mk4, k42b/mk4, k42bu/mk4
*                     k42c/mk4, lba, lba4, or none)
mk3     type of recorder 1 (mk3, vlba, vlba2, vlbab, vlba4, vlba42, mk4,
*		            mk4b, s2, k41, k41/dms, k42, k42/dms, mk5a,
*                           mk5a_bs, or none)
mk3     type of recorder 2 (mk3, vlba, vlba2, vlbab, vlba4, vba42, mk4,
*                           mk4b, or none)
mk3     type of decoder (mk3, dqa, mk4, or none)
*
* Mark III/IV rack parameters
 500.10 IF3 LO Frequency
   3    hex mask indicating which IF3 switches are installed, sw N ~ 2^(N-1)
*
* VLBA/4 rack parameters
  a/d   VLBA formatter cross-point switch (a/d or dsm)
101     Hardware ID for VLBA rack (assigned by GSFC)
*
* CDP S/X Receiver Parameters
60      Receiver 70K Stage Check Temperature
20      Receiver 20K Stage Check Temperature
* pcal control
none    type of phase cal control (if3 or none)
*mk iv fm firmware version
40      pre-40 versions have no barrel-rolling or data modulation
*
* LBA/4 rack parameters
   1    No of LBA DAS installed (up to MAX_DAS - see "params.h")
   in   160MHz IF input filters (in or out)
  8bit	Digital input setting (8bit internal sampler or 4bit external at ATCA)
* met sensor type
cdp     cdp or met3, use cdp if you don't have either
