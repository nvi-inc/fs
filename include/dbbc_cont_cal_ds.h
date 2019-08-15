/* dbbc_cont_cal data structures */

struct dbbc_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int polarity;     /* 0 no polarity change, no on/off swap 
                       1    polarity change, no on/off swap 
                       2 no polarity change,    on/off swap 
                       3    polarity change,    on/off swap */
  int samples;      /* number of samples for Tsys */
};
