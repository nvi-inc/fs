/* header file for vlba rvac data structures */

struct rvac_cmd {        /* command parameters */
     float inches;       /* command vacuum level */
     int set;            /* set flag */
     };

struct rvac_mon {        /* monitor only parameters */
     float volts;       /* actual */
     };
