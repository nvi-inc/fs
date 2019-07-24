/* header file for vlba dqa data structures */

struct dqa_cmd {         /* command parameters */
     int dur;            /* analysis duration in seconds */
     };

struct dqa_mon {         /* monitor only parameters */
     struct dqa_chan {   /* for each channel */
       int bbc;
       int track;
       float amp;        /* phase-cal amplitude in voltage percent */
       float phase;      /* phase-cal phase in radians */
                             /* error counts: */
       unsigned long parity;     /* parity errors */
       unsigned long crcc_a;     /* crcc-'a' errors */
       unsigned long crcc_b;     /* crcc-'b' errors */
       unsigned long resync;     /* resync errors */
       unsigned long nosync;     /* nosync errors */
       unsigned long num_bits;   /* number of bits actually sampled */
     } a;                /* one struct for channel a */
     struct dqa_chan b;  /* one struct for channel b */
     };
