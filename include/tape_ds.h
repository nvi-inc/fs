/* vlba tape data structures */

struct tape_cmd {
     int set;          /* lowset 0=disable or 1=enable */
     int reset;        /* footage counter to 0 or <feet> */
    };

struct tape_mon {
     int foot;         /* tape footage counter */
     int sense;        /* low tape sensor */
     int vacuum;       /* vacuum pressure */
     int chassis;      /* chassis serial number */
     int stat;         /* general status flag */
     int error;        /* error flags */
    };
