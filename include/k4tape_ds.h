/* header file for k4 tape data structures */

struct k4tape_mon {   /* monitor parameters */
  char pos[9];
  int drum;
  int synch;
  char lost[3];
  int stat1;
  int stat2;
};
