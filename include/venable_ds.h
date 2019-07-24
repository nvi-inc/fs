/* header file for vlba enable function data structures */

struct venable_cmd {     /* command parameters */
     int general;        /* software general enable 0=off,1=on */
     int group[4];       /* four groups */
     };
