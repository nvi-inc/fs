/* Mark IV formmatter data structures */

struct form4_cmd {
  int mode;         /* MK3 mode 0=m,a,b1,b2,c1,c2,d1,...d28 */
  int rate;         /* (1<<rate)*0.125 MHz, 0<=rate<=8 */
  unsigned long enable[2]; /*track enables 1=enable, 0=off */
  unsigned aux[2];   /* aux data */
  int codes[64];      /* sampler pin codes for output tracks */
  int fan;           /* fan-in, fan-out mode */
  int barrel;        /* barrel-rolling mode */
  int last;         /* =1 if form4 was last, 0 if trackform */
};

struct form4_mon {
  int status;
  int error;
  int rack_ids;     /* MAT rack_ids */
  int version;      /* version number */
};
