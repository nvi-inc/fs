/* header file for calrx data structures */

struct calrx_cmd {  /* command parameters */
  char file[65];    /* file name */
  int  type;        /* type 0=fixed 1=range */
  double lo[2];     /* upper and lower for range  or 1 or 2 values for fixed */
};
