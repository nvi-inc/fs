/* header file for k4 rec_mode data structures */

struct k4rec_mode_cmd {   /* command parameters */
  int bw;
  int bt;
  int ch;
  int im;
  int nm;
};

struct k4rec_mode_mon {   /* monitor parameters */
  int ts;
  int fm;
  int ta;
  int pb;
};

