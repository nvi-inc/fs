#define MAX_TCAL 400
#define MAX_SPILL 20

struct rxgain_ds {
  char type;   /* LO type 'f' for fixed, 'r' for range */
  float lo[2]; /* LO values (MHz), for type 'f' lo[0] fixed value
                *                  for type 'r' lo[0] minimum, lo[1] maximum */
  int year;    /* creation date: year, 4 digits */
  int month;   /* creation date: month 0->12, 0 = day is day of year */
  int day;     /* creation date: day of month or day of year if month = 0 */

  struct {
    char model;     /*fwhm model 'f' by freq or 'c' constant */
    float coeff;    /* scale factor for 'f' or simple degrees value for 'c' */
  } fwhm;
  char pol[2];         /* polarizations 'l' (lcp), 'r' (rcp), ' ' (none)  */
  float dpfu[2];        /* DPFU (gain) for polarizations in pol */
  struct {
    char form;            /* 'e' for elevation 'a' for altaz */
    char type;            /* 'p' for poly */
    float coeff[10]; /* polynomial coefficent, maximum 10 */
    int ncoeff;
    char opacity;         /* 'y' if opacity corrected, 'n' if not */
  } gain;

  int tcal_ntable;  /* number of points in table */
  int tcal_npol[2]; /* number of points in table for each pol */
  struct {
    char pol;       /* polarization 'l' (lcp) or 'r' (rcp) */
    float freq;     /* tabular point for frequency MNz */
    float tcal;     /* cal temperature (degrees K) */
  } tcal[MAX_TCAL]; /* group by polarization, then sorted by increasing freq */

  float trec;       /* receiver temperature (degrees K) < 0 undefined */

  int spill_ntable;  /* number of points in table */
  struct {
    float el;         /* tabular point for elevation (degrees) */
    float tk;         /* spill contribution temperature (degrees K) */
  } spill[MAX_SPILL]; /* sorted by increasing elevation */
};
