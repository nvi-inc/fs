/* header file for vlba st data structures */

struct vst_cmd {         /* command parameters */
     int dir;            /* direction of tape 0|1 rev|for */
     int speed;          /* tape speed nominal */
     unsigned cips;      /* centi-inches per speed */
     int rec;            /* record 0|1 off|on */
     };
