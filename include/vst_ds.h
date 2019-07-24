/* header file for vlba st data structures */

struct vst_cmd {         /* command parameters */
     int dir;            /* direction of tape 0|1 rev|for */
     int speed;          /* tape speed inches/sec */
     int rec;            /* record 0|1 off|on */
     };
