/* header file for k4 rec data structures */

struct k4rec_mon {   /* monitor parameters */
  char pos[9];
  char aux[17];
  int drum;
  int synch;
  char lost[3];
  int stat1;
  int stat2;
};
