* Contents of first uncommented line of TEDEF.CTL
* 1. MODSA    model number of spectrum analyzer (3582 or 35660) 
* 2. AMPTOL   tolerance, in dB, for variation in phase cal amplitude
* 3. GDYTOL   tolerance, in ns, for variation in group delay at X-band
* 4. DIFTOL   tolerance, in nanoseconds, for difference between change in 
*             cable length and change in X-band group delay 
* 5. PHATOL   tolerance, in nanoseconds, for variation in phase delay 
* 
* (1)  (2)   (3)     (4)    (5) 
 3582  0.5   1.0     0.3    1.0 
* 
* Contents of second uncommented line of (TEDEF:
* 1. NPRSET   number of groups of four measurements to do in cable test 
* 2. INTPHA   spectrum analyzer integration time (s) for phase measurements 
* 3. INTAMP   same, but for amplitude measurements
* 4. LVSENS   spectrum analyzer sensitivity (2 for 30V full scale,
*             decreasing by 10 dBV per level to 10 for 3 mV full scale) 
* 5. SON2HI   threshold, in %, for phase cal SNR being considered too high
* 6. SON2LO   threshold, in %, for phase cal SNR being considered too low 
* 7. SOF2HI   same as 5, but with phase cal off 
* 8. CPKMIN   min acceptable peak coherence between VCs at same frequency 
* 9. PHJMAX   max acceptable phase jitter between VCs at same frequency 
* 
* (1) (2) (3) (4)  (5)  (6)  (7)  (8) (9) 
   1   30  3   4   15.   1.  0.1  .9  40. 
