/* header file for onoff data structures */

struct onoff_cmd {
  int rep;              /* repetitions, number */
  int intp;             /* integration period, seconds */
  float cutoff;         /* angle to switch to el instead of az offs, degrees */
  float step;           /* step size in FWHMs */
  int wait;             /* wait time for on to off transition */
  float ssize;           /* source size, radians */
  struct onoff_devices {
    char lwhat[2];      /* device ID */
    char pol;           /* polarization */
    int ifchain;        /* which IF */
    float flux;         /* source flux */
    float corr;         /* source structure correction */
    double center;      /* detector center frequency */
    float fwhm;         /* full width half maximum (degrees) */
    float tcal;        /* cal temperature */
    float dpfu;         /* degrees per flux unit (gain) */
    float gain;        /* gain curve, maximum=1.0 */
  } devices[38];
  int itpis[38];        /* control array for which devices */
  float fwhm;        /* FWHM for detector with the widest beam */
  int stop_request;     /* stop request issued? */
  int setup;            /* have we been set-up */
};

