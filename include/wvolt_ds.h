/* header file for vlba wvolt data structures */

struct wvolt_cmd {        /* command parameters */
     float volts[2];      /* command write volts level, two heads */
     int set[2];          /* set flag */
     }; 

