/* header file for flux data structures */

struct flux_ds {
  char name[11];
  char type;
  float fmin;
  float fmax;
  float fcoeff[3];
  float size;
  char model;
  float mcoeff[6];
};
