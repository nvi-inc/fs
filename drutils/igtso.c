/* f2ctmp_igtso.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    doublereal sorp50[210]	/* was [2][105] */, sorpda[210]	/* was [2][
	    105] */, satp50[35]	/* was [7][5] */, satdy[5];
    real flux[3780]	/* was [18][2][105] */;
    integer nsourc, nceles, nsatel, isaty[5], nflux[210]	/* was [2][
	    105] */;
    shortint lsorna[420]	/* was [4][105] */;
} sourc_;

#define sourc_1 sourc_

struct {
    char cfltype[210]	/* was [2][105] */;
} sourc_ch__;

#define sourc_ch__1 sourc_ch__

/* Table of constant values */

static integer c__4 = 4;
static integer c__1 = 1;
static integer c__8 = 8;

integer igtso_(shortint *lkeywd, integer *ikey)
{
    /* System generated locals */
    integer ret_val, i__1;

    /* Local variables */
    static integer i;
    extern integer ias2b_(shortint *, integer *, integer *), iflch_(shortint *
	    , integer *);
    extern logical knaeq_(shortint *, shortint *, integer *);

/* ******************************************************************** */

/*     SKPARM.FTNI HOLDS PARAMETERS FOR THE SKED FAMILY OF PROGRAMS. */
/*     Parameters which are used by SKED and/or DRUDG are */
/*     collected here. */

/*  Last modified:  890623 by NRV to add windows parameters */
/* 891113 NRV Add max base/flux parameter */
/* 900125 NRV added max tape length parameter */
/* 900206 NRV Modified to remove SOCAT, STCAT */
/* 900302 gag removed catalogs, luscn and luusr */
/* 911026 NRV Changed flux parameters */
/* 911215 NRV Changed max_chart to 100 (per Heinz) */
/* 920528 NRV Add MAX_SEFDPAR */
/* 920702 NRV Changed MAX_HOR,COR to 30 */
/* 930204 NRV Merged sked parameters into this version */
/* 930308 NRV Changed autosked max parameters to use previously */
/*            defined parameters for source and station numbers */
/* 930408 nrv Add oblank (single blank character) */
/*            Add octal constants */
/* 930506 nrv Changed max_stn to 14 */
/* 931015 nrv Add flcon1, flcon2 (removed from obsfl) */
/* 931223 nrv Change to 4000 scans (for test schedules) */
/* 940112 nrv Make the default be 100 celestial, 5 satellites */
/*            Change to 2000 scans as default. */
/* 940719 nrv Special version for 35 stations */
/* 940805 nrv Back to normal values */
/*            Add MAX_NRS parameter */
/* 950622 nrv Change MAX_PASS to 28 for 4-pass mode C with VLBA */

/* ******************************************************************** */


/*     The maximum number of stations which can be selected for */
/*     an experiment at one time.  Used in SKED and DRUDG. */

/*     PARAMETER (MAX_STN = 35) */

/*     The maximum number of baselines. */


/*     The maximum number of az/el and coordinate pairs for horizon */
/*     and coordinate masks. 18 is the maximum number allowed without */
/*     increasing the buffer size. */


/*     The maximum number of sources, celetial AND satellite */
/*     which can be selected for an experiment at one time. */
/*     This must be the largest parameter of the maximum */
/*     parameters used with the stations, frequencies and sources. */
/*     Used in SKED and DRUDG. */
/* *** NOTE: If this value is changed, then at least one of MAX_CEL */
/* *** and MAX_SAT must be changed, so that MAX_SOR = MAX_CEL + MAX_SAT. 
*/


/*     The maximum number of celestial (RA,DEC) sources which can */
/*    be selected for an experiment at one time. Used in SKED,SOCAT,DRUDG.
*/
/* *** NOTE: If this value is changed at least one of MAX_SOR */
/* *** and MAX_SAT must be changed, so that MAX_SOR = MAX_CEL + MAX_SAT. 
*/


/*     The maximum number of satellite (orbital element) sources which */
/*     can be selected for an experiment at one time. Used in SKED */
/*     and DRUDG. */
/* *** NOTE: If this value is changed, then at least one of MAX_SOR */
/* *** and MAX_CEL must be changed, so that MAX_SOR = MAX_CEL + MAX_SAT. 
*/


/*     The maximum number of frequency codes which can be selected */
/*     for use in an experiment at one time.  Used in SKED and DRUDG. */


/*     The maximum number of frequency bands within a schedule. */
/*       **NOTE** This is restricted to be no more than 2! */
/*       There are places in SKED that may appear to handle more */
/*       than two bands, but this feature is really tailored to */
/*       only S/X observations. *** */
/*     Several frequency codes may be selected, as long as they */
/*     are composed of a maximum of two bands, e.g. S and X. */


/*     The maximum size of flux arrays. For source models, this number */
/*     is the maximum number of model components times 6, because */
/*     there are 6 parameters for a gaussian model. The value of 18 */
/*     allows for 3 components, although no source models currently have 
*/
/*     more than 2 components. For baseline/flux profiles, this is the */
/*     maximum number of entries in the profile. The value of 18 allows */
/*     for 9 baselines and 8 fluxes, more than generous to describe a */
/*     source. */


/*     Maximum number of VLBA entries. */

/*     Maximum number of rise/set times in arrays. */

/*     Maximum number of parameters for the calculation of */
/*     elevation-dependent SEFDs. */

/*     Value for PI. */


/*     EPSILON FOR 23 DEG AND 27 MIN IN RADIANS */

/*     Speed of light */

/*     Degrees per radian */

/*     Seconds of time per radian */

/*     Seconds of arc per radian */

/*     Radians per second of arc */

/*     Radians per second of time */

/*     Note: 0.6931471=alog(2) */
/* marcsec --> radian */
/*     Maximum number of parameters that can be estimated. */
/*     PARAMETER (MAX_PAR_ESTI=20) */

/*     Maximum number of parameters that can be optimized */
/*     PARAMETER (MAX_PAR_OPTI=10) */

/*     Maximum dimension for arrays holding coefficients etc. */
/*     This parameter is = 269 for 100 sources, 8 stations */
/*                         277 for 100 sources, 9 stations */
/*                         285 for 100 sources, 10 stations */

/*     Maximum number of sources for which positions can be estimated */
/*     PARAMETER(MAX_SOR_ESTI=1) */

/*     Maximum number of subconfigurations that will be */
/*     examined for possible scheduling. */

/*     Default maximum tape length.  This value is usually */
/*     specified for each station in the equipment catalog. */


/*     Default maximum number of passes.  This is usally */
/*     specified for each station in the equipment catalog. */
/*     Since most stations have high density heads, the */
/*     default is set to 12 rather than 1. */


/*     Definitions for octal constants. */
/*     Unit 5 = standard input (keyboard) */
/*     Unit 6 = standard output (screen) */


/*     The lengths of the general purpose buffers IBUF and IBUFQ */
/*     are determined by MAX_STN as follows: */
/*     length of IBUF in chars must be >=60+MAX_STN*13 */
/*     IBUFQ is 1 word longer than IBUF */

/*     PARAMETER (IBUF_LEN = 256) */
/*     PARAMETER (IBUFQ_LEN = 257) */

/*     The maximum number of observations allowed in a schedule */


/*     The maximum number of entries in the source */
/*     catalog. CAUTION: YOU MUST ALSO CHANGE IBFCOM_LEN BELOW. */


/*     The length of array IBFCOM = 4*MAX_ENT_SOR */


/*     The maximum number of entries in the station */
/*     catalog. This must be no more than 108. This */
/*     is because the station and frequency selection */
/*     options only can display one page on the terminal. */
/*     (Limit set by NROWS*NCOLS in SEST) */


/*     The name of the control files. These files are */
/*     read at run time. cctfil is the default control */
/*     file that SKED reads each time it is run and should */
/*     be in the users path. cownctl is a */
/*     personal control file that should be in the */
/*     directory of the user when running SKED if it is */
/*     to be used. */


/*     CHECK THROUGH LIST OF SOURCES FOR A MATCH WITH LKEYWD */
/*     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0 */
/*     ALSO MAY HAVE A SOURCE INDEX NUMBER ALLOWED. */
/*     SOURCE INFORMATION COMMON BLOCK */








/*  NSOURC - number of sources selected */
/*  LSORNA - source IAU names, up to 8 chars */
/*  NCELES - number of celestial sources selected */
/*  SORP50 - positions, ra and dec of 2000.0, radians */
/*  SORPDA - positions, ra and dec of date, radians */
/*  flux   - flux density by frequency band for each source */
/*  nflux  - if cfltype=B, total number of baseline/flux entries */
/*           if cfltype=M, number of model components */

/*  NSATEL - number of stallites selected */
/*  SATP50 - orbital elements for staellites: */
/*         - (1) orbital inclination */
/*         - (2) orbital eccentricity */
/*         - (3) arguement of preigee */
/*         - (4) right ascending node */
/*         - (5) mean anomaly */
/*         - (6) semimajor axis */
/*         - (7) orbital motion */
/*  ISATY  - epoch year for satellite orbital elements */
/*  SATDY  - day and fraction for satellite epoch */
    /* Parameter adjustments */
    --lkeywd;

    /* Function Body */
    *ikey = 0;
    ret_val = 0;
    if (sourc_1.nsourc <= 0) {
	return ret_val;
    }
    i__1 = sourc_1.nsourc;
    for (i = 1; i <= i__1; ++i) {
	if (knaeq_(&lkeywd[1], &sourc_1.lsorna[(i << 2) - 4], &c__4)) {
	    goto L110;
	}
/* L100: */
    }
    i__1 = iflch_(&lkeywd[1], &c__8);
    i = ias2b_(&lkeywd[1], &c__1, &i__1);
    if (i > 0 && i <= sourc_1.nsourc) {
	goto L110;
    }
    return ret_val;
L110:
    *ikey = i;
    ret_val = i;
    return ret_val;
} /* igtso_ */

