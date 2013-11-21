/* dbbcifX data structures */

struct dbbcgain_cmd {
     int bbc;          /* bbc, 0=all, or 1-16 */
     int state;        /* 0=man, 1=agc, -1=set gainU, gainL, -2=query */
     int gainU;        /* 1-255 */
     int gainL;        /* 1-255 */
     int target;       /* if state=1, 0-65535 target, -1 == NULL  */
    };
struct dbbcgain_mon {
     int state;        /* 0=man, 1=agc */
     int target;       /* if state=1, 0-65535 target, -1 == NULL  */
    };
