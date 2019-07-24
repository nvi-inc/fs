/* header file for vlba capture data structures */

struct capture_mon {         /* monitor only parameters */
     struct {
        int drive;           /* drive in use 1 or 2 */
        int chan;            /* capture channel */
     } qa;
     struct {                /* general capture values from 0x48 & 0x49 */
       unsigned word1;
       unsigned word2;
     } general;
     struct {                /* time lsbs capture values from 0x4a & 0x4b */
       unsigned word3;
       unsigned word4;
     } time;
     };
