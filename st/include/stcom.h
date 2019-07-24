/* stcom.h

   This file contains structure declarations for the
   Mojave antcn interface.

   NRV 920306
*/

typedef struct pnt {
  int itype;
  double a1;
  double a2;
  double ra_offset;
  double dc_offset;
  double az_offset;
  double el_offset;
  double x_offset;
  double y_offset;
  float tdegc;
  float rhum;
  float barmb;
  char oldlog[12];
  int kpoint;
} Pnt;

typedef struct xyt {
  double x;
  double y;
  int t[6];
} Xyt;

typedef struct ercr {
  double xerr;
  double yerr;
  double xcor;
  double ycor;
  double recor;
  int konsor;
} Ercr;

typedef struct stcom {
  int run_interval;
  int imode;
  int remote;
  double alat;
  double wlong;
  double ptol;
  struct xyt pos_cmd;
  int knewsr;
  int klost;
  int knewpo;
  int ioffsor;
  double azmask[37];
  double elmask[37];
  double elmin;
  double elplus;
  int nmask;
  double xmin,ymin,xmax,ymax;
 
  struct pmdl {
  double pcof[MAX_MODEL_PARAM];
  int ipar[MAX_MODEL_PARAM];
  double phi;
  int imdl;
  int t[6];
  } pmodel;

/* Real-time pointing calculation info */
  struct pnt point;

/* Real-time pointing position info    */
  struct ercr error;
  struct xyt pos;

/* New calculation info, set up by antcn   */
  struct pnt point_new;

/* Old position info, returned to antcn    */
  struct ercr ercr_old;
  struct xyt pos_old;

  int konsor_n;
  int konsor_p;
  int kfail;
  int knmov;
  int klims;
  int klow;

  struct xyt pos_actold; 
} Stcom;

