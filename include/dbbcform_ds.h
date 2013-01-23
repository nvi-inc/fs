/* dbbcform data structures */

struct dbbcform_cmd {
  int mode;         /* 0=astro, 1=geo, 2=wastro, 3=test, 4=lba */
  int test;         /* 0=0, 1=1, 2=bin, 3=tvg */  
};
