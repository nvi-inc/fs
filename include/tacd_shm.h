/* TAC shared memory (C data structure) layout */

struct tacd_shm {
  float day_frac;          /* The day and fraction of day. */
  float msec_counter;      /* Raw reading on the counter in microsec. */
  float usec_bias;         /* Amount by which the GPS receiver's 1PPS output
                            * has been intentionally biased in usec. */
  float cooked_correction; /* The correct (cooked) counter reading after
                            * applying the usec_correction and usec_bias. */
  float rms;               /* RMS scatter of the sec data points about the 
                            * average in usec. */
  float usec_average;      /* sec point average of the sec cooked counter
                            * readings in usec. */
  float max;               /* The extreme readings of the sec points.*/
  float min;               /* (by definition) max > average > min. */ 
  float day_frac_old;      /* old day and fraction of day value. */
  /* */
  int continuous;          /* 0 = not so often, 1 = continuous */
  int stop_request;        /* -1=file empty,0=ok,1=reopen file,2=fs exit*/
  int usec_correction;     /* On the ONCORE receiver's +/- 52 sec sawtooth 
                            * correction on the GPS 1PPS in nsec. */
  int nsec_accuracy;       /* An estimate of the accuracy of the GPS tick in 
                            * nsec. */
  int sec_average;         /* Number of secs. of data going into the averg. */
  int port;                /* The port number assiged by the Sys. Admin. on
                            * the PC side. */
  int check;               /* read TAC every n secs into SharedMemory */
  int display;             /* what do you want displayed when you do a tacd.
			    * tacd=status(0), tacd=time(1), tacd=average(2)*/
  /* */
  char hostpc[80];         /* The Host name. */
  char oldnew[4];              /* show old or new. -1 is old, 1 is new. */
  char file[40];           /* Log file in the PC doing the work. */
  char status[8];          /* The file status on the PC log file. */
};

