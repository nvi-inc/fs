/* f2ctmp_crprc.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__40 = 40;
static integer c__9 = 9;
static integer c__12 = 12;
static integer c__23 = 23;
static integer c__34 = 34;
static integer c__17 = 17;

/* Subroutine */ int crprc_(integer *lu, integer *lnamep)
{
    /* Initialized data */

    static integer z20 = 32;

    extern integer ichmv_ch__(shortint *, integer *, char *, ftnlen);
    extern /* Subroutine */ int hol2lower_(shortint *, integer *), 
	    writf_asc__(integer *, integer *, shortint *, integer *), inc_(
	    integer *, integer *);
    static shortint ibuf[20];
    static integer ierr;
    extern /* Subroutine */ int ifill_(shortint *, integer *, integer *, 
	    integer *);
    extern integer ichmv_(shortint *, integer *, integer *, integer *, 
	    integer *);
    static integer idummy;

/*      DIMENSION IBUF(20) */
    ifill_(ibuf, &c__1, &c__40, &z20);
    idummy = ichmv_ch__(ibuf, &c__1, "DEFINE  ", 8L);
    idummy = ichmv_(ibuf, &c__9, lnamep, &c__1, &c__12);
    idummy = ichmv_ch__(ibuf, &c__23, "00000000000X", 12L);
    hol2lower_(ibuf, &c__34);
    writf_asc__(lu, &ierr, ibuf, &c__17);
    inc_(lu, &ierr);

/* L32767: */
    return 0;
} /* crprc_ */

