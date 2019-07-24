/* header file for mcbcn response data structures */

#define RES_MAX_BUF  512

struct res_buf {
     int class;
     int count;
     int ifc;
     int nchars;
     unsigned char buf[ RES_MAX_BUF];
     };

struct res_rec {
     int state;
     int code;
     unsigned data;
     unsigned char array[48];
     };
