/* header file for k4 vc lo data structures */

struct k4vclo_cmd {   /* command parameters */
  int freq[16];
};

struct k4vclo_mon {   /* monitor parameters */
  char yes[16];
  char lock[16];
};
