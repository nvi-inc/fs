/* header file for k3 formatter data structures */

struct k3fm_cmd {   /* command parameters */
  int mode;
  int rate;
  int input;
  char aux[12];
  int synch;
  int aux_start;
  int output;
};

struct k3fm_mon {   /* monitor parameters */
  char daytime[15];
  unsigned char status[3];
};
