/* dbbc_cont_cal data structures */

struct dbbc_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int polarity;     /* not present before v105x_1
                       as of v105x_1:
                         0 no polarity change
                         1    polarity change
                       as of v106:
                         0 no polarity change, no on/off swap 
                         1    polarity change, no on/off swap 
                         2 no polarity change,    on/off swap 
                         3    polarity change,    on/off swap 
                       as of v107:
                         0 no 1 pps embedded, no on/off swap 
                         1    1 pps embedded, no on/off swap 
                         2 no 1 pps embedded,    on/off swap 
                         3    1 pps embedded,    on/off swap 
                    */
  int freq;         /* not present before v106
                       8-300000 Hz */
  int option;       /* not present before v106
                       0=pulsed, 1= output always on */

  int samples;      /* number of samples for Tsys */
};
