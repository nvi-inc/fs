/* dbbcifX data structures */

struct dbbcifx_cmd {
     int input;        /* channel: 1, 2, 3, 4 */
     int att;          /* attenuation, steps 0-64; -1==NULL */
     int agc;          /* gain control 0=man, 1=agc */
     int filter;       /* 1=512-1024, 2=10-512, 3=1536-2048, 4=1024-1536 */ 
     int target_null;  /* 1==NULL */
     unsigned target;  /* target value for AGC, 0-65535 */
    };

struct dbbcifx_mon {
     unsigned tp;      /* tpi , 0-65535 counts */
    };
