#line 1 "f2ctmp_bsort.f"
/* f2ctmp_bsort.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

#line 1 "f2ctmp_bsort.f"
/* Table of constant values */

static integer c__1 = 1;
static integer c__7 = 7;
static integer c__10 = 10;
static integer c__17 = 17;

/* Subroutine */ int bsort_(integer *istart, integer *length, integer *ncode, 
	shortint *bufr)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    extern /* Subroutine */ int ichmv_ch__(integer *, integer *, char *, 
	    ftnlen);
    static integer i, itmp;
    extern integer ichcm_(shortint *, integer *, shortint *, integer *, 
	    integer *);
    extern /* Subroutine */ int mcoma_(integer *, integer *), ichmv_(integer *
	    , integer *, shortint *, integer *, integer *), copin_(integer *, 
	    integer *);
    static integer lmess[8], lendif;
    static logical changes;
    static integer lasttap;


/* Sort bar codes by length and ASCII order        Lloyd Rawley    March 1
988*/

/*  Calls COPIN and character subroutines, called by RWAND. */

/*  Input parameters: */
/*   bufr:    ASCII array containing all of the bar codes */
/*   ncode:   Number of bar codes */
/*   istart:  Array of indexes within bufr of the beginning of a bar code 
*/
/*   length:  Array of lengths of the bar codes */

/* On output, ncode and bufr are unchanged.  The other arrays are reorgani
zed*/
/*  so that the shortest strings come first, and each group of strings of 
the*/
/*  same length is alphabetized by ASCII collating sequence.  In addition,
 if*/
/*   more than one tape label (distinguished from other bar codes by its 
*/
/*  length) is present in the list, all except the last one are considered
*/
/*  errors and are replaced with the last value.  This value is sent to th
e*/
/*   LABEL command for logging. */

/*  8 characters plus space plus che */
/*  used to determine when the sort is comp */

/*  1. Make all tape label references refer to the last label. */

/*  ersatz message from operator to boss */
#line 29 "f2ctmp_bsort.f"
    /* Parameter adjustments */
#line 29 "f2ctmp_bsort.f"
    --bufr;
#line 29 "f2ctmp_bsort.f"
    --length;
#line 29 "f2ctmp_bsort.f"
    --istart;
#line 29 "f2ctmp_bsort.f"

#line 29 "f2ctmp_bsort.f"
    /* Function Body */
#line 29 "f2ctmp_bsort.f"
    lasttap = 0;
#line 30 "f2ctmp_bsort.f"
    for (i = *ncode; i >= 1; --i) {
#line 31 "f2ctmp_bsort.f"
	if (length[i] == 10) {
#line 32 "f2ctmp_bsort.f"
	    if (lasttap == 0) {
#line 33 "f2ctmp_bsort.f"
		lasttap = i;
#line 34 "f2ctmp_bsort.f"
	    } else {
#line 35 "f2ctmp_bsort.f"
		istart[i] = istart[lasttap];
#line 36 "f2ctmp_bsort.f"
	    }
#line 37 "f2ctmp_bsort.f"
	}
#line 38 "f2ctmp_bsort.f"
    }

/*  2. Send the tape label (if any) to the QUIKR LABEL command via COPIN. 
*/

#line 42 "f2ctmp_bsort.f"
    if (lasttap != 0) {
#line 43 "f2ctmp_bsort.f"
	ichmv_ch__(lmess, &c__1, "label=", 6L);
#line 44 "f2ctmp_bsort.f"
	ichmv_(lmess, &c__7, &bufr[1], &istart[lasttap], &c__10);
#line 45 "f2ctmp_bsort.f"
	mcoma_(lmess, &c__17);
#line 46 "f2ctmp_bsort.f"
	copin_(lmess, &c__17);
#line 47 "f2ctmp_bsort.f"
    }

/*  3. Bubble sort */

#line 51 "f2ctmp_bsort.f"
    changes = TRUE_;
#line 52 "f2ctmp_bsort.f"
    while(changes) {
#line 53 "f2ctmp_bsort.f"
	changes = FALSE_;
#line 54 "f2ctmp_bsort.f"
	i__1 = *ncode;
#line 54 "f2ctmp_bsort.f"
	for (i = 2; i <= i__1; ++i) {
#line 55 "f2ctmp_bsort.f"
	    lendif = length[i] - length[i - 1];
#line 56 "f2ctmp_bsort.f"
	    if (lendif < 0) {
/*  if shorter string comes later, */
#line 57 "f2ctmp_bsort.f"
		itmp = length[i];
#line 58 "f2ctmp_bsort.f"
		length[i] = length[i - 1];
#line 59 "f2ctmp_bsort.f"
		length[i - 1] = itmp;
#line 60 "f2ctmp_bsort.f"
		itmp = istart[i];
#line 61 "f2ctmp_bsort.f"
		istart[i] = istart[i - 1];
#line 62 "f2ctmp_bsort.f"
		istart[i - 1] = itmp;
#line 63 "f2ctmp_bsort.f"
		changes = TRUE_;
/*    Don't sort 8-character codes so that VC's can be display
ed in order */
#line 65 "f2ctmp_bsort.f"
	    } else if (lendif == 0 && length[i] != 8 && ichcm_(&bufr[1], &
#line 65 "f2ctmp_bsort.f"
		    istart[i], &bufr[1], &istart[i - 1], &length[i]) > 0) {
/*  ascii compa */
#line 67 "f2ctmp_bsort.f"
		itmp = istart[i];
/*  swap */
#line 68 "f2ctmp_bsort.f"
		istart[i] = istart[i - 1];
#line 69 "f2ctmp_bsort.f"
		istart[i - 1] = itmp;
#line 70 "f2ctmp_bsort.f"
		changes = TRUE_;
#line 71 "f2ctmp_bsort.f"
	    }
#line 72 "f2ctmp_bsort.f"
	}
#line 73 "f2ctmp_bsort.f"
    }

#line 75 "f2ctmp_bsort.f"
    return 0;
} /* bsort_ */

