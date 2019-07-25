/* f2ctmp_error.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__32774 = 32774;
static integer c__0 = 0;

/* Main program */ MAIN__(void)
{
    /* Initialized data */

    static integer mc = 5;
    static integer npar = 20;
    static real feclon = 0.f;
    static real feclat = 0.f;
    static struct {
	shortint e_1;
	char e_2[32];
	} equiv_90 = { 32, "too man input points, limit is _" };

#define l2mny ((shortint *)&equiv_90)

    static struct {
	shortint e_1;
	char e_2[16];
	} equiv_91 = { 15, "no input points " };

#define lnopt ((shortint *)&equiv_91)

    static integer il = 50;
    static integer mpts = 600;
    static integer mpar = 20;
    static integer itry = -1;
    static real tol = .001f;

    /* Format strings */
    static char fmt_9905[] = "(\002 iteration \002,i3,\002       fec:\002,2("
	    "1x,f10.5))";

    /* System generated locals */
    integer i__1, i__2;
    real r__1, r__2;
    doublereal d__1, d__2;
    logical L__1;
    static real equiv_0[2];

    /* Builtin functions */
    double cos(doublereal), sqrt(doublereal);
    /* Subroutine */ int s_stop(char *, ftnlen);
    integer s_wsfe(cilist *), do_fio(integer *, char *, ftnlen), e_wsfe(void);

    /* Local variables */
    extern integer ichcm_ch__(shortint *, integer *, char *, ftnlen);
    extern /* Subroutine */ int fmpclose_(integer *, integer *), po_put_c__(
	    char *, ftnlen);
    extern logical kpout_ch__(integer *, integer *, char *, char *, integer *,
	     ftnlen, ftnlen);
    static doublereal a[210], b[20];
    static integer i, j, ic, it[6], lu;
    extern logical kif_(shortint *, shortint *, integer *, integer *, integer 
	    *, logical *, integer *);
#define reg (equiv_0)
    extern doublereal fln_(integer *, doublereal *, doublereal *, doublereal *
	    , integer *, doublereal *);
    static doublereal lat[600], phi;
    static integer igp, inp;
    static real div;
    static doublereal lon[600];
    static integer ito[6];
    static doublereal aux[20];
    static real wln[600];
    static integer lst;
    static real wlt[600];
    extern /* Subroutine */ int fc_rte_time__(integer *, integer *), fit2_(
	    doublereal *, doublereal *, real *, real *, real *, real *, 
	    integer *, doublereal *, doublereal *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, integer *,
	     real *, integer *, D_fp, D_fp, real *, real *, real *, integer *,
	     integer *, integer *, integer *, real *, real *, real *, real *, 
	    real *);
    extern doublereal flt0_(integer *, doublereal *, doublereal *, doublereal 
	    *, integer *, doublereal *);
    static real cond;
    static integer imdl;
#define ireg ((integer *)equiv_0)
    static shortint jbuf[50];
    static doublereal pcof[20];
    extern logical kbit_(integer *, integer *);
    static doublereal ddum;
    static integer ipar[20], iapp, ilen;
    static shortint lant[4];
    static integer ldum[3];
    static real latr;
    static integer ierr;
    extern /* Subroutine */ int sbit_(integer *, integer *, integer *);
    static integer idum;
    static real rchi;
    extern logical kopn_(integer *, integer *, char *, integer *, ftnlen);
    static logical kuse;
    static integer luse[32];
    static real lonr;
    extern logical kpst_(integer *, integer *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, integer *, integer *, 
	    char *, integer *, shortint *, integer *, ftnlen);
    static real wlnr, wltr;
    extern integer ib2as_(integer *, integer *, integer *, integer *);
    extern /* Subroutine */ int fc_setup_ids__(void);
    static integer idcbo[2];
    static doublereal scale[20];
    extern /* Subroutine */ int fecon_(real *, real *, real *, real *, real *,
	     real *, integer *, integer *, real *, real *);
    static char iibuf[64];
    static integer nfree;
    static char imbuf[64];
    extern logical kpdat_(integer *, integer *, logical *, doublereal *, 
	    doublereal *, real *, real *, real *, integer *, char *, integer *
	    , shortint *, integer *, ftnlen), kgant_(integer *, integer *, 
	    shortint *, shortint *, char *, shortint *, integer *, ftnlen);
    static char iobuf[64];
    static real rcond;
    extern logical kgetm_(integer *, char *, shortint *, integer *, integer *,
	     integer *, doublereal *, integer *, integer *, doublereal *, 
	    integer *, integer *, ftnlen);
    static real emnln;
    extern logical kpcon_(integer *, integer *, real *, doublereal *, integer 
	    *, char *, integer *, shortint *, integer *, ftnlen);
    static doublereal spcof[20];
    extern /* Subroutine */ int incsm_(integer *, doublereal *, doublereal *, 
	    doublereal *, real *, real *, doublereal *, doublereal *, 
	    doublereal *, real *, real *, doublereal *, doublereal *, real *, 
	    integer *, integer *, real *, real *, real *);
    extern logical kplin_(integer *, integer *, doublereal *, integer *, 
	    doublereal *, integer *, integer *, integer *, integer *, 
	    doublereal *, char *, integer *, shortint *, integer *, ftnlen), 
	    kinit_(integer *, char *, char *, integer *, char *, integer *, 
	    ftnlen, ftnlen, ftnlen), kpfit_(integer *, integer *, integer *, 
	    real *, real *, real *, integer *, real *, real *, integer *, 
	    char *, integer *, shortint *, integer *, ftnlen), kpant_(integer 
	    *, integer *, shortint *, shortint *, shortint *, integer *, 
	    integer *, char *, ftnlen);
    static doublereal dirms;
    static real lnofr;
    extern logical kgpnt_(integer *, integer *, logical *, real *, real *, 
	    real *, real *, real *, real *, integer *, integer *, integer *, 
	    char *, shortint *, integer *, ftnlen);
    static shortint laxis[2];
    static integer ispar[20];
    static real ltofr, emnlt;
    extern /* Subroutine */ int inism_(doublereal *, doublereal *, doublereal 
	    *, doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, integer *);
    extern logical kptri_(integer *, integer *, doublereal *, integer *, char 
	    *, integer *, shortint *, integer *, ftnlen);
    static real coslt, distr;
    extern /* Subroutine */ int rstat_(doublereal *, doublereal *, doublereal 
	    *, doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, integer *, integer *);
    static integer iftry;
    static real rlnnr, rltnr;
    extern logical koutp_(integer *, integer *, integer *, integer *, char *, 
	    ftnlen);
    static integer nxpnt, idcbos;
    static real feclnn;
    static logical kfixed;
    static real latoff[600], fecltn;
    static doublereal pcofer[20];
    static real lonoff[600], latres[600];
    static doublereal latrms;
    static real lonres[600];
    static integer itryfe;
    static doublereal latsum, lonrms, wdisum, lonsum, wlnsum, wltsum;
    extern /* Subroutine */ int fmpopen_(integer *, char *, integer *, char *,
	     integer *, ftnlen, ftnlen);

    /* Fortran I/O blocks */
    static cilist io___76 = { 0, 0, 0, fmt_9905, 0 };




/* DPI.I SOME USEFUL CONSTANTS RELATED TO PI */









/*          too man input points, limit is */
/*          no input points */

    fc_setup_ids__();

    ic = ib2as_(&mpts, ldum, &c__1, &c__32774);
    fc_rte_time__(it, &it[5]);

    if (kinit_(&lu, iibuf, iobuf, &iapp, imbuf, &lst, 64L, 64L, 64L)) {
	goto L10010;
    }

    if (kgetm_(&lu, imbuf, jbuf, &il, idcbo, &idcbos, pcof, &mpar, ipar, &phi,
	     &imdl, ito, 64L)) {
	goto L10010;
    }

    fmpopen_(idcbo, iibuf, &ierr, "r+", &idcbos, 64L, 2L);
    if (kopn_(&lu, &ierr, iibuf, &c__0, 64L)) {
	goto L10010;
    }

    if (kgant_(&lu, idcbo, lant, laxis, iibuf, jbuf, &il, 64L)) {
	goto L10000;
    }

    inp = 0;

L10:
    if (kgpnt_(&lu, idcbo, &kuse, &lonr, &latr, &lnofr, &ltofr, &wlnr, &wltr, 
	    &mc, &ilen, &inp, iibuf, jbuf, &il, 64L)) {
	goto L10000;
    }
    if (ilen < 0 || ichcm_ch__(jbuf, &c__1, "$", 1L) == 0) {
	goto L20;
    }
    L__1 = inp >= mpts;
    if (kif_(&l2mny[1], l2mny, ldum, &c__1, &ic, &L__1, &lu)) {
	goto L10000;
    }
    ++inp;

    if (inp == 1) {
	emnln = wlnr;
	emnlt = wltr;
    }

    sbit_(luse, &inp, &c__0);
    if (kuse) {
	sbit_(luse, &inp, &c__1);
	emnln = min(emnln,wlnr);
	emnlt = min(emnlt,wltr);
    }
    lon[inp - 1] = lonr;
    lat[inp - 1] = latr;
    lonoff[inp - 1] = lnofr;
    latoff[inp - 1] = ltofr;
    wln[inp - 1] = wlnr;
    wlt[inp - 1] = wltr;
    goto L10;

L20:
    L__1 = inp == 0;
    if (kif_(&lnopt[1], lnopt, &idum, &c__0, &c__0, &L__1, &lu)) {
	goto L10000;
    }
    fmpclose_(idcbo, &ierr);
    if (koutp_(&lu, idcbo, &idcbos, &iapp, iobuf, 64L)) {
	goto L10000;
    }

    if (kpout_ch__(&lu, idcbo, "$antenna", iobuf, &lst, 8L, 64L)) {
	goto L10000;
    }
    if (kpant_(&lu, idcbo, lant, laxis, jbuf, &il, &lst, iobuf, 64L)) {
	goto L10000;
    }

    if (kpout_ch__(&lu, idcbo, "$observed ", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }
    inism_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp);
    i__1 = inp;
    for (i = 1; i <= i__1; ++i) {
	coslt = cos(lat[i - 1]);
	distr = sqrt(lonoff[i - 1] * lonoff[i - 1] * coslt * coslt + latoff[i 
		- 1] * latoff[i - 1]);
	incsm_(luse, &lonsum, &lonrms, &wlnsum, &lonoff[i - 1], &wln[i - 1], &
		latsum, &latrms, &wltsum, &latoff[i - 1], &wlt[i - 1], &dirms,
		 &wdisum, &distr, &i, &igp, &feclon, &feclat, &coslt);
	kuse = kbit_(luse, &i);
	if (kpdat_(&lu, idcbo, &kuse, &lon[i - 1], &lat[i - 1], &lonoff[i - 1]
		, &latoff[i - 1], &distr, &mc, iobuf, &lst, jbuf, &il, 64L)) {
	    goto L10000;
	}
    }

    if (kpout_ch__(&lu, idcbo, "$observed_stats ", iobuf, &lst, 16L, 64L)) {
	goto L10000;
    }

    rstat_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp, &lu);

    if (kpst_(&lu, idcbo, &lonsum, &lonrms, &latsum, &latrms, &dirms, &igp, &
	    inp, iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

    inism_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp);

    if (kpout_ch__(&lu, idcbo, "$old_model", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }
    if (kplin_(&lu, idcbo, pcof, &mpar, &ddum, &c__0, &imdl, ito, ipar, &phi, 
	    iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }
    if (kpout_ch__(&lu, idcbo, "$uncorrected", iobuf, &lst, 12L, 64L)) {
	goto L10000;
    }

/* PARAMETER FLAGS: */

/*    0 = DON'T USE */
/*    1 = USE */
/*    2 = HARDWIRED */
/*    3 = IF PRESENT, HARDWIRE OTHER PARMATERS WITH VALUES LESS THAN 3 */
/*    4 = USE TO UNCORRECT DATA BUT DON'T RE-ESTIMATE */

    kfixed = FALSE_;
    i__1 = mpar;
    for (i = 1; i <= i__1; ++i) {
	kfixed = kfixed || ipar[i - 1] == 3;
	if (ipar[i - 1] < 0 || ipar[i - 1] > 4) {
	    po_put_c__("parameter flag values must be 0 to 4 inclusive.", 47L)
		    ;
	    s_stop("", 0L);
	}
    }
    i__1 = mpar;
    for (i = 1; i <= i__1; ++i) {
	ispar[i - 1] = ipar[i - 1];
	spcof[i - 1] = pcof[i - 1];
	if (kfixed && ipar[i - 1] < 3 || ipar[i - 1] == 2) {
	    ipar[i - 1] = 0;
	    pcof[i - 1] = 0.;
	}
    }

    i__1 = inp;
    for (i = 1; i <= i__1; ++i) {
	lonoff[i - 1] += fln_(&c__0, &lon[i - 1], &lat[i - 1], pcof, ipar, &
		phi);
	latoff[i - 1] += flt0_(&c__0, &lon[i - 1], &lat[i - 1], pcof, ipar, &
		phi);
	coslt = cos(lat[i - 1]);
	distr = sqrt(lonoff[i - 1] * lonoff[i - 1] * coslt * coslt + latoff[i 
		- 1] * latoff[i - 1]);

	incsm_(luse, &lonsum, &lonrms, &wlnsum, &lonoff[i - 1], &wln[i - 1], &
		latsum, &latrms, &wltsum, &latoff[i - 1], &wlt[i - 1], &dirms,
		 &wdisum, &distr, &i, &igp, &feclon, &feclat, &coslt);
	kuse = kbit_(luse, &i);
	if (kpdat_(&lu, idcbo, &kuse, &lon[i - 1], &lat[i - 1], &lonoff[i - 1]
		, &latoff[i - 1], &distr, &mc, iobuf, &lst, jbuf, &il, 64L)) {
	    goto L10000;
	}

    }

    rstat_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp, &lu);

    if (kpout_ch__(&lu, idcbo, "$uncorrected_stats", iobuf, &lst, 18L, 64L)) {
	goto L10000;
    }

    if (kpst_(&lu, idcbo, &lonsum, &lonrms, &latsum, &latrms, &dirms, &igp, &
	    inp, iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

/*  FIX IPAR */

    i__1 = mpar;
    for (i = 1; i <= i__1; ++i) {
	if (ipar[i - 1] == 4) {
	    ipar[i - 1] = 0;
	    ispar[i - 1] = 0;
	    spcof[i - 1] = 0.;
	    pcof[i - 1] = 0.;
	}
	if (ipar[i - 1] != 0) {
	    npar = i;
	}
    }


    for (itryfe = 1; itryfe <= 10; ++itryfe) {
	if (itryfe == 1) {
	    goto L205;
	}
	if (nfree <= 0) {
	    goto L211;
	}
	iftry = itryfe;

	fecon_(&feclnn, &fecltn, lonres, wln, latres, wlt, &inp, luse, &emnln,
		 &emnlt);

	if ((r__1 = feclnn - feclon, abs(r__1)) <= feclnn * .01f && (r__2 = 
		fecltn - feclat, abs(r__2)) <= fecltn * .01f) {
	    goto L211;
	}

	feclon = feclnn;
	feclat = fecltn;

L205:
	if (lst != 0) {
	    io___76.ciunit = lst;
	    s_wsfe(&io___76);
	    do_fio(&c__1, (char *)&itryfe, (ftnlen)sizeof(integer));
	    d__1 = feclon * 57.295779513082323;
	    do_fio(&c__1, (char *)&d__1, (ftnlen)sizeof(doublereal));
	    d__2 = feclat * 57.295779513082323;
	    do_fio(&c__1, (char *)&d__2, (ftnlen)sizeof(doublereal));
	    e_wsfe();
	}
	fit2_(lon, lat, lonoff, latoff, wln, wlt, &inp, pcof, pcofer, ipar, &
		phi, aux, scale, a, b, &npar, &tol, &itry, (D_fp)fln_, (D_fp)
		flt0_, &rchi, &rlnnr, &rltnr, &nfree, &ierr, luse, &igp, &
		feclon, &feclat, lonres, latres, &rcond);
    }
    iftry = 0;
/* L2105: */
    feclon = 0.f;
    feclat = 0.f;
    fit2_(lon, lat, lonoff, latoff, wln, wlt, &inp, pcof, pcofer, ipar, &phi, 
	    aux, scale, a, b, &npar, &tol, &itry, (D_fp)fln_, (D_fp)flt0_, &
	    rchi, &rlnnr, &rltnr, &nfree, &ierr, luse, &igp, &feclon, &feclat,
	     lonres, latres, &rcond);
L211:

    ++imdl;

    if (kpout_ch__(&lu, idcbo, "$fit_data ", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }

    if (kplin_(&lu, idcbo, pcof, &mpar, pcofer, &mpar, &imdl, it, ipar, &phi, 
	    iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

    if (kpout_ch__(&lu, idcbo, "$fit_stats", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }
    if (kpfit_(&lu, idcbo, &ierr, &rchi, &rlnnr, &rltnr, &nfree, &feclon, &
	    feclat, &iftry, iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

    if (rcond != 0.f) {
	cond = 1.f / rcond;
    }
    if (kpout_ch__(&lu, idcbo, "$conditions ", iobuf, &lst, 12L, 64L)) {
	goto L10000;
    }
    if (kpcon_(&lu, idcbo, &cond, scale, &npar, iobuf, &lst, jbuf, &il, 64L)) 
	    {
	goto L10000;
    }

/*     IF(KPOUT(LU,IDCBO,12H$COVARIANCE ,-12,IOBUF,LST)) GOTO 10000 */
/*     IF(KPTRI(LU,IDCBO,A,NPAR,IOBUF,LST,JBUF,IL)) GOTO 10000 */

    nxpnt = 0;
    i__1 = npar;
    for (i = 1; i <= i__1; ++i) {
	nxpnt += i;
	aux[i - 1] = 1.;
	div = sqrt(a[nxpnt - 1]);
	if (div > 1e-10f) {
	    aux[i - 1] = 1. / div;
	}
    }

    nxpnt = 0;
    i__1 = npar;
    for (i = 1; i <= i__1; ++i) {
	i__2 = i;
	for (j = 1; j <= i__2; ++j) {
	    a[nxpnt + j - 1] = a[nxpnt + j - 1] * aux[i - 1] * aux[j - 1];
	}
	nxpnt += i;
    }
    if (kpout_ch__(&lu, idcbo, "$correlation", iobuf, &lst, 12L, 64L)) {
	goto L10000;
    }
    if (kptri_(&lu, idcbo, a, &npar, iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

    inism_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp);

    if (kpout_ch__(&lu, idcbo, "$corrected", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }

    i__1 = inp;
    for (i = 1; i <= i__1; ++i) {
	coslt = cos(lat[i - 1]);
	distr = sqrt(lonres[i - 1] * lonres[i - 1] * coslt * coslt + latres[i 
		- 1] * latres[i - 1]);

	incsm_(luse, &lonsum, &lonrms, &wlnsum, &lonres[i - 1], &wln[i - 1], &
		latsum, &latrms, &wltsum, &latres[i - 1], &wlt[i - 1], &dirms,
		 &wdisum, &distr, &i, &igp, &feclon, &feclat, &coslt);

	kuse = kbit_(luse, &i);
	if (kpdat_(&lu, idcbo, &kuse, &lon[i - 1], &lat[i - 1], &lonres[i - 1]
		, &latres[i - 1], &distr, &mc, iobuf, &lst, jbuf, &il, 64L)) {
	    goto L10000;
	}
    }

    rstat_(&lonsum, &lonrms, &wlnsum, &latsum, &latrms, &wltsum, &dirms, &
	    wdisum, &igp, &lu);

    if (kpout_ch__(&lu, idcbo, "$corrected_stats", iobuf, &lst, 16L, 64L)) {
	goto L10000;
    }

    if (kpst_(&lu, idcbo, &lonsum, &lonrms, &latsum, &latrms, &dirms, &igp, &
	    inp, iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }

    i__1 = mpar;
    for (i = 1; i <= i__1; ++i) {
	if (ispar[i - 1] < 3 && kfixed || ispar[i - 1] == 2) {
	    ipar[i - 1] = ispar[i - 1];
	    pcof[i - 1] = spcof[i - 1];
	} else if (ispar[i - 1] == 3) {
	    ipar[i - 1] = 1;
	}
    }

    if (kpout_ch__(&lu, idcbo, "$new_model", iobuf, &lst, 10L, 64L)) {
	goto L10000;
    }
    if (kplin_(&lu, idcbo, pcof, &mpar, &ddum, &c__0, &imdl, it, ipar, &phi, 
	    iobuf, &lst, jbuf, &il, 64L)) {
	goto L10000;
    }


L10000:
    fmpclose_(idcbo, &ierr);

L10010:
    return 0;
} /* MAIN__ */

#undef ireg
#undef reg
#undef lnopt
#undef l2mny


/* Main program alias */ int error_ () { MAIN__ (); return 0; }
