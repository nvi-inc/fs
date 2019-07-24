/* vlba bbc data structures */

struct bbc_cmd {
     long freq;        /* bits sent to bbc to command frequency */
     int source;       /* if source, 0=A, 1=B, 2=C, 3=D */
     int bw[2];        /* bandwidth selection */
     int bwcomp[2];    /* bandwidth gain compensation USB & LSB */
     struct {
       int mode;       /* 0=fixed, 1=AGC */
       int value[2];   /* */
       int old;        /* old setting */
     } gain;
     int avper;   /* averaging period for TPI, 0,1,2,4,10,20,40,60 secs*/
    };

struct bbc_mon {
     int lock;         /* 0=un-locked, 1=locked */
     unsigned pwr[2];  /* 0-65535 counts */
     int serno;        /* 12 bit serial number */
     int timing;       /* 0=error, 1=okay */
    };
