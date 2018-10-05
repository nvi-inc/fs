/* dbbc3 ifX data structures */

struct dbbc3_ifx_cmd {
     int input;        /* channel: 1, 2, 3, 4 */
     int att;          /* attenuation, steps 0-64; -1==NULL */
     int agc;          /* gain control 0=man, 1=agc */
     int target_null;  /* 1==NULL */
     unsigned target;  /* target value for AGC, 0-65535 */
    };

struct dbbc3_ifx_mon {
     unsigned tp;      /* tpi , 0-65535 counts */
    };
