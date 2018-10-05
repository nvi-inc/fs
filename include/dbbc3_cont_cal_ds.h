/* dbbc3_cont_cal data structures */

struct dbbc3_cont_cal_cmd {
  int mode;         /* 0=off, 1=on */
  int polarity;     /* 0 no polarity change, no on/off swap 
                       1    polarity change, no on/off swap 
                       2 no polarity change,    on/off swap 
                       3    polarity change,    on/off swap */
  int freq;         /* cont cal signal frequency, 8-300000 Hz */
  int option;       /* 0 = output pulsed, 1 - output always on */
  int samples;      /* number of samples for Tsys */
};
