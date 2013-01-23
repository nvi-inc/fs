/* dbbcNN data structures */

struct dbbcnn_cmd {
     unsigned long freq;  /* frequency (Hz) */
     int source;          /* if source, 0=A, 1=B, 2=C, 3=D */
     int bw;              /* bandwidth selection */
     int avper;           /* averaging period for TPI seconds*/
    };

struct dbbcnn_mon {
     int agc;          /* 0=man, 1=agc */
     int gain[2];      /* gain values, index 0=upper, 1=lower */
     unsigned tpon[2]; /* tpi cal on, index 0=upper, 1=lower, 0-65535 counts */
     unsigned tpoff[2];/* tpi cal on, index 0=upper, 1=lower, 0-65535 counts */
    };
