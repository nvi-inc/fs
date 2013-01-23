/* dbbc_cont_cal data structures */

struct dbbc_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int samples;      /* number of samples for Tsys */
};
