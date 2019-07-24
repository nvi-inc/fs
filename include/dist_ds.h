/* header file for vlba ifd (dist) data structures */

/* each instance of a structure refers to one distributor */
/* arrays index over the channels in a distributor */

struct dist_cmd {        /* command parameters */
     int atten[2];       /* attenutor settings, 0 or 20 */
     int input[2];       /* input selction, 0 or 1 */
     int avper;          /* averaging period */
     int old[2];         /* `old' attenuator settings (atten[]) */
     };

struct dist_mon {        /* monitor only parameters */
     int serial;         /* 12 bits of serial number */
     int timing;         /* timing status, 0 or 1 */
     unsigned totpwr[2]; /* total power counts */
     };
