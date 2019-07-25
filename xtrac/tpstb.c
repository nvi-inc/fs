/* f2ctmp_tpstb.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__100 = 100;
static integer c_n8 = -8;
static integer c__4 = 4;
static integer c_n7 = -7;
static integer c_n6 = -6;
static integer c__3 = 3;

/* Subroutine */ int tpstb_(integer *lut, shortint *idcb, real *avglon, real *
	avglat, real *rmslon, real *rmslat, real *dirms, integer *inp, 
	integer *igp, char *iobuf, integer *lst, shortint *ibuf, integer *il, 
	ftnlen iobuf_len)
{
    extern /* Subroutine */ int ifill_ch__(shortint *, integer *, integer *, 
	    char *, ftnlen);
    extern integer ichmv_ch__(shortint *, integer *, char *, ftnlen), ib2as_(
	    integer *, shortint *, integer *, integer *), jr2as_(real *, 
	    shortint *, integer *, integer *, integer *, integer *);
    static logical kpret;
    static integer inext;
    extern logical kpout_(integer *, shortint *, shortint *, integer *, char *
	    , integer *, ftnlen);



    /* Parameter adjustments */
    --ibuf;
    --idcb;

    /* Function Body */
    ifill_ch__(&ibuf[1], &c__1, &c__100, " ", 1L);
    inext = 1;
    inext = ichmv_ch__(&ibuf[1], &inext, "     ", 5L);

    inext += jr2as_(avglon, &ibuf[1], &inext, &c_n8, &c__4, il);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += jr2as_(rmslon, &ibuf[1], &inext, &c_n8, &c__4, il);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += jr2as_(avglat, &ibuf[1], &inext, &c_n7, &c__4, il);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += jr2as_(rmslat, &ibuf[1], &inext, &c_n7, &c__4, il);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += jr2as_(dirms, &ibuf[1], &inext, &c_n6, &c__4, il);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += ib2as_(igp, &ibuf[1], &inext, &c__3);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    inext += ib2as_(inp, &ibuf[1], &inext, &c__3);
    inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);

    if (0 == inext % 2) {
	inext = ichmv_ch__(&ibuf[1], &inext, " ", 1L);
    }
    kpret = kpout_(lut, &idcb[1], &ibuf[1], &inext, iobuf, lst, iobuf_len);

    return 0;
} /* tpstb_ */

