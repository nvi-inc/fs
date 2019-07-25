#line 1 "f2ctmp_lxplt.f"
/* f2ctmp_lxplt.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

#line 1 "f2ctmp_lxplt.f"
/* Common Block Declarations */

struct {
    real smax[5], smin[5];
    integer idcb[2], jdcb[2], idcbsk[2];
    shortint ibuf[50], jbuf[50];
    integer lcomnd[30]	/* was [6][5] */, lstrng[30]	/* was [6][5] */, 
	    lstatn[4], llogx[5];
    shortint ltype[5], i2dum;
    integer ncomnd[5], nparm[5], nstrng[5];
    shortint lsouon[4], lsourn[4], ltapen[4], logna[10], lskna[32];
    integer iblen, ieq, ikey, ilen, ite1, ite2, itl1, itl2, its1, its2, luusr,
	     ludsp, l6, nchar, ncmd, nlines, nlout, nstr, ntype, nintv, nump, 
	    iterm, isld, islhr, islmin, islsec, ield, ielhr, ielmin, ielsec;
    shortint lsft, left;
    integer ilrday, ilrhrs, ilrmin;
    shortint namf[10];
    integer icode, irtn1, irtn2, irtn4, irtn5, irtn6, ilxget, itcntl, lstat[3]
	    , iwidth, ihgt, ltapn[4], iout, idcbcm[2], iftype, isked;
    shortint namcm[32];
    integer il, icmd, it3, lstend, nscale[5], itsk1, itsk2, itske1, itske2;
    real sdelta[5];
} lxcom_;

#define lxcom_1 lxcom_

/* Table of constant values */

static integer c__1 = 1;
static integer c__32772 = 32772;
static integer c__5 = 5;
static integer c__130 = 130;
static integer c__2 = 2;
static integer c__20 = 20;
static integer c__8 = 8;
static integer c__12 = 12;
static integer c__37 = 37;
static integer c__11 = 11;
static integer c__77 = 77;
static integer c__78 = 78;
static integer c__4 = 4;

/* Subroutine */ int lxplt_(void)
{
    /* Initialized data */

    static char filename1[64] = "/tmp/loge1                                 "
	    "                     ";
    static char filename2[64] = "/tmp/loge2                                 "
	    "                     ";
    static struct {
	char e_1[10];
	shortint e_2;
	} equiv_67 = { "1 2 3 4 5 ", 0 };

#define iplch ((shortint *)&equiv_67)

    static real scale[5] = { 1.149253f,0.f,0.f,0.f,0.f };
    static struct {
	shortint e_1;
	char e_2[78];
	integer e_3;
	} equiv_11 = { 78, "                      [            ( )] sc (    "
		"       ,            ),  ch < >", 0 };


    /* System generated locals */
    integer i__1, i__2, i__3;
    real r__1, r__2;
    static shortint equiv_6[65], equiv_7[2];
    static real equiv_12[2], equiv_13[2];
    static doublereal equiv_15[4];

    /* Builtin functions */
    double r_lg10(real *);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern integer ichcm_ch__();
    extern /* Subroutine */ int ifill_ch__(), ichmv_ch__(shortint *, integer *
	    , char *, ftnlen), po_put_c__(char *, ftnlen), fmpclose_(integer *
	    , integer *);
    extern integer writestr_(integer *, integer *, char *, integer *, ftnlen);
    static integer i, j, k, n;
    extern integer fmpappend_(integer *, integer *);
    extern /* Subroutine */ int ftn_purge__(char *, integer *, ftnlen), 
	    fmprewind_(integer *, integer *);
    extern integer fmpreadxx_(integer *, integer *, doublereal *), fmpsetpos_(
	    integer *, integer *, integer *, integer *);
    static integer id, nc, im;
    static doublereal xa, xb, xc;
    static integer ix, iy[5];
#define xx (equiv_15)
#define yy ((real *)equiv_15 + 2)
    extern integer fmpsetline_(integer *, integer *, integer *), fmpreadstr_(
	    integer *, integer *, char *, ftnlen);
#define ibc ((char *)&lxcom_1 + 64)
#define jbc ((char *)&lxcom_1 + 164)
#define ihc ((char *)equiv_7)
    static integer ich, nch;
    extern integer fmpwritexx_(integer *, integer *, doublereal *);
    static shortint iqc;
    static integer len, ilg10, irec;
#define ihas (equiv_7)
#define line (equiv_6)
#define cmax ((char *)&equiv_11 + 58)
#define ival ((integer *)equiv_13)
#define cmin ((char *)&equiv_11 + 46)
#define imin ((integer *)((shortint *)&equiv_11 + 23))
#define imax ((integer *)((shortint *)&equiv_11 + 29))
#define parm (equiv_12)
    static integer ierr, jlen, idum;
    static real rlg10;
    static doublereal xmin;
    static real ymin[5];
    static doublereal xmax;
    static real ymax[5];
    static integer idcb1[2], idcb2[2], idcb3[2];
    extern integer ib2as_();
#define irec1 ((shortint *)equiv_15)
    extern /* Subroutine */ int jr2as_(real *, integer *, integer *, integer *
	    , integer *);
    static real y2min[5], y2max[5];
#define namfc ((char *)&lxcom_1 + 856)
    extern integer iflch_(shortint *, integer *), jchar_(shortint *, integer *
	    );
#define cline ((char *)equiv_6)
    extern integer mcoma_(shortint *, integer *);
#define lognc ((char *)&lxcom_1 + 636)
    static integer imagw;
    extern /* Subroutine */ int ichmv_();
    static shortint pline[6500]	/* was [65][100] */;
#define iparm ((integer *)equiv_12)
#define lsknc ((char *)&lxcom_1 + 656)
    static integer iprec;
#define value (equiv_13)
    static shortint isize;
    extern /* Subroutine */ int lxget_(void), gtprm_(shortint *, integer *, 
	    integer *, integer *, real *, integer *), lxhms_(doublereal *, 
	    shortint *, integer *);
    static integer nplot;
    extern /* Subroutine */ int lxwrt_(shortint *, integer *);
    static logical kpass2;
#define namcmc ((char *)&lxcom_1 + 964)
    static real scalex;
    static integer answer;
#define ltitle ((shortint *)&equiv_11)
    static char outbuf[79];
    extern integer iscn_ch__(shortint *, integer *, integer *, char *, ftnlen)
	    ;
    extern /* Subroutine */ int fmpopen_(integer *, char *, integer *, char *,
	     integer *, ftnlen, ftnlen);
    extern integer trimlen_(char *, ftnlen);
    extern /* Subroutine */ int char2hol_(), hol2char_(integer *, integer *, 
	    integer *, char *, ftnlen);

/*     LOGEX PLOTTING ROUTINE !<870115:05:35> */

/* LXPLT - LOGEX plotting routine */

/* MODIFICATIONS: */

/*    DATE     WHO  DESCRIPTION */
/*    820525   CAK  SUBROUTINE CREATED */
/*    820526   CAK  SCRATCH FILE FOR PLOT ADDED */
/*    820607   CAK  LXPLT HAS BEEN CHANGED FROM A SUBROUTINE TO A SEGMENT 
*/
/*                  PROGRAM OF LOGEX. */
/*    820923   KNM  THE STRIP-CHART PLOT AND THE SINGLE SCREEN PLOT ARE */
/*                  HANDLED IN THIS PROGRAM SEGMENT. LXTPL IS NOW */
/*                  OBSOLETE. */
/*    871130   LEF  Changed back to subroutine and added CDS. */

/* COMMON BLOCKS USED: */


/* SUBROUTINE INTERFACES: */
/*    CALLING SUBROUTINES: */
/*     LNFCH Utilities */

/* LOCAL VARIABLES: */


/*  COMMON STATEMENT FOR LOGEX */




/*     IBLEN - Buffer length in words. */
/*     IBUF - Buffer for input & log reading. */
/*     ICMD - A flag which indicates that a command file is being used. */
/*     ICODE - Error flag. */
/*     ICR - Logical unit where the log resides. */
/*     IDCB - DCB for the log file. */
/*     IDCBCM - DCB for command file. */
/*     IELD - SUMMARY stop time (the day) of an observation. */
/*     IELHR - SUMMARY stop time (the hour) of an observation. */
/*     IELMIN - SUMMARY stop time (the minutes) of an observation. */
/*     IELSEC - SUMMARY stop time (the seconds) of an observation. */
/*     IEQ - Character number of equals sign. */
/*     IFTYPE - Type of log file, 2-char or namr */
/*     IHGT - Height of the plot in lines. */
/*     IKEY - The command number determined in IGTCM. */
/*     IL - Number of words in a command file. */
/*     ILEN - Number of words in a log record. */
/*     ILRDAY,ILRHRS,ILRMIN - Time control command in day, hrs & mins */
/*     ILSEC - Log file security code. */
/*     ILXGET - Flag which indicates whether the log file requires re- */
/*              winding. */
/*     IOUT - A flag that indicates whether the Output file processing */
/*            statement has been written. */
/*     IRTN1,IRTN2,IRTN4,IRTN5,IRTN6 - Variables that define the return */
/*     return points for segments. */
/*     ISCR - Logical unit where the schedule file resides. */
/*     ISKSEC - Schedule file security code. */
/*     ISKED - Indicates whether a SKED file has been specified. */
/*     ISLD - SUMMARY start time (the day) of an observation. */
/*     ISLHR - SUMMARY start time (the hour) of an observation. */
/*     ISLMIN - SUMMARY start time (the minutes) of an observation. */
/*     ISLSEC - SUMMARY start time (the seconds) of an observation. */
/*     ITCNTL - A flag that indicates whether we have a time control */
/*              command for the SUMMARY. */
/*     ITERM - A flag that indicates whether an output file name */
/*             has been specified in the OUTPUT command. */
/*     IT3 - Seconds in a log record. */
/*     ITE1,ITE2 - Stop day, min. */
/*     ITL1,ITL2 - Log record day, min. */
/*     ITS1,ITS2 - Start day, min. */
/*     ITSK1,ITSK2 - Specified start day, minutes in schedule file */
/*     ITSKE1,ITSKE2 - Specified end day, minutes in schedule file */
/*     IWIDTH - Width of the plot in characters. */
/*     JBUF - Output file buffer. */
/*     JDCB - DCB for output file. */
/*     IDCBSK - DCB for schedule file. */
/*     LCOMND - This array stores a maximum of five commands to search */
/*              for with each command having a maximum of 12 characters. 
*/
/*     LEFT - Stop time footage count */
/*     LLOGX - Llogx (dB scale) plotting scale of each parameter. */
/*     LOGNA - File name of log. */
/*     LSFT - Start time footage count. */
/*     LSKNA - Schedule file name. */
/*     LSOUON - Contains the log tracking status. */
/*     LSOURN - Contains the source name found in the log entry. */
/*     LSTAT - Contains the status codes for the SKSUMMAY & SUMMARY cmds. 
*/
/*     LSTATN - Contains the station name. */
/*     LSTEND - A flag that indicates whether requested listing has been 
*/
/*              reached. */
/*     LSTRNG - This array stores five commands to search for after the */
/*              time field to end of the log entry. */
/*     LTAPEN - Contains the log tape number. */
/*     LTAPN - Contains the previous tape number. */
/*     LTYPE - This array stores five special characters to search for */
/*             in column 10 of a log entry. */
/*     LUDSP - Display LU. */
/*     LUUSR - User LU. */
/*     L6 - Carriage control. */
/*     NAMCM - Command file name. */
/*     NAMF - Output file name. */
/*     NCHAR - Total number of characters in a log entry. */
/*     NCMD - Total number of COMMAND commands specified. */
/*     NCOMND - Actual number of characters in each COMMAND command. */
/*     NERROR - Number of CHEKR errors. A maximum of five is written out. 
*/
/*     NINTV - A flag which indicates whether LOGEX is in the non- */
/*             interactive mode. */
/*     NLINES - A second parameter of the LIST, PLOT, or SUMMARY */
/*              commands that specifies a limited number of lines to */
/*              listed or plotted. */
/*     NLOUT - Number of lines in the log outputted. */
/*     NPARM - Contains the parameters specified in the PARM command */
/*             that corresponds to the parameters in the log entry. */
/*     NSCALE - The parameter the SCALE command applies to. */
/*     NSTR - Number of STRING commands specified. */
/*     NSTRNG - Actual number of characters in each STRING command. */
/*     NTYPE - Number of special characters specified in a TYPE command. 
*/
/*     NUMP - Total number of parameters specified. */
/*     SMAX - Maximum value of the plotting scale for each parameter. */
/*     SMIN - Minimum value of the plotting scale for each parameter. */
/*        - Scale values for each parameter */
/*        - Plotting character of each parameter. */
/*        - A SECOND PASS IS NEEDED TO HANDLE DELTAS */
/*        - TEMPORARY ARRAYS TO SUPPORT A SECOND PASS */

/*        - Buffer for plot. */

/*        - Contains the min,max scale values in double precision. */
/*          This is done because there are no routines to convert */
/*          double precision to ASCII. */


/*        - Y-Axis minimum, maximum, plotting locations for the data */
/*          points. */


/*          Parm value to plot. */
/*        - Log time in terms of days (& fractions of days). */
/*          X-Axis minimum, maximum. Log day. Log minutes. */



/*      data ltitle/78,'                      [            ( )] sc (', */
/*     .'           ,            ),  ch < >'/ */

/* INITIALIZED VARIABLES: */

/*       - Plot characters */



/* ************************************************************** */

/* 1. Create and open scratch files. */

/* ************************************************************** */


#line 107 "f2ctmp_lxplt.f"
    nc = ib2as_(&lxcom_1.ihgt, ihas, &c__1, &c__32772);
#line 108 "f2ctmp_lxplt.f"
    fmpopen_(idcb1, filename1, &ierr, "w+", &c__5, 64L, 2L);
#line 109 "f2ctmp_lxplt.f"
    if (ierr < 0) {
#line 109 "f2ctmp_lxplt.f"
	goto L1100;
#line 109 "f2ctmp_lxplt.f"
    }
#line 110 "f2ctmp_lxplt.f"
    fmpopen_(idcb2, filename2, &ierr, "w+", &c__5, 64L, 2L);
#line 111 "f2ctmp_lxplt.f"
    if (ierr < 0) {
#line 111 "f2ctmp_lxplt.f"
	goto L1100;
#line 111 "f2ctmp_lxplt.f"
    }


/* ************************************************************** */

/* 2. Make sure a PARM and a COMMAND command has been specified. */
/*    If that's ok, initialize variables & arrays. */

/* ************************************************************** */


#line 122 "f2ctmp_lxplt.f"
    if (lxcom_1.ncmd == 0 || lxcom_1.nump == 0) {
#line 122 "f2ctmp_lxplt.f"
	goto L1200;
#line 122 "f2ctmp_lxplt.f"
    }
#line 123 "f2ctmp_lxplt.f"
    imagw = (lxcom_1.iwidth + 1) / 2;
#line 124 "f2ctmp_lxplt.f"
    nplot = 0;
#line 125 "f2ctmp_lxplt.f"
    lxcom_1.nlout = 0;
#line 126 "f2ctmp_lxplt.f"
    lxcom_1.iout = 0;
#line 127 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &c__130, " ", 1L);
#line 128 "f2ctmp_lxplt.f"
    xmin = 1e20;
#line 129 "f2ctmp_lxplt.f"
    xmax = -1e20;
#line 130 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.nump;
#line 130 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 131 "f2ctmp_lxplt.f"
	ymin[i - 1] = 1e20f;
#line 132 "f2ctmp_lxplt.f"
	ymax[i - 1] = -1e20f;
#line 133 "f2ctmp_lxplt.f"
    }


/* ************************************************************** */

/* 3. Call LXGET to read log entries. */

/* ************************************************************** */


#line 143 "f2ctmp_lxplt.f"
    lxcom_1.lstend = 0;
#line 144 "f2ctmp_lxplt.f"
    lxcom_1.ilen = 0;
#line 145 "f2ctmp_lxplt.f"
    lxget_();
#line 146 "f2ctmp_lxplt.f"
    while(lxcom_1.lstend != -1 && lxcom_1.ilen >= 0) {
/* !!READ LOG ENTRIES */
#line 147 "f2ctmp_lxplt.f"
	*xx = 0.;
#line 148 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 148 "f2ctmp_lxplt.f"
	    goto L1200;
#line 148 "f2ctmp_lxplt.f"
	}

/* Count the number of entries & lines outputted. */

/* !!IF BREAK, PURGE SCRATCH FILES & RE */
#line 152 "f2ctmp_lxplt.f"
	++nplot;
#line 153 "f2ctmp_lxplt.f"
	++lxcom_1.nlout;

/* Pick up the decoded time from common and check XX for min & max */
/* time scale. */

#line 158 "f2ctmp_lxplt.f"
	xa = (doublereal) lxcom_1.itl1;
#line 159 "f2ctmp_lxplt.f"
	xb = (doublereal) lxcom_1.itl2;
#line 160 "f2ctmp_lxplt.f"
	xc = (doublereal) lxcom_1.it3;
#line 161 "f2ctmp_lxplt.f"
	*xx = xa + xb / 1440. + xc / 86400.;
#line 162 "f2ctmp_lxplt.f"
	if (*xx < xmin) {
#line 162 "f2ctmp_lxplt.f"
	    xmin = *xx;
#line 162 "f2ctmp_lxplt.f"
	}
#line 163 "f2ctmp_lxplt.f"
	if (*xx > xmax) {
#line 163 "f2ctmp_lxplt.f"
	    xmax = *xx;
#line 163 "f2ctmp_lxplt.f"
	}

/* Get specified parm store the value */

#line 167 "f2ctmp_lxplt.f"
	i__1 = lxcom_1.nump;
#line 167 "f2ctmp_lxplt.f"
	for (n = 1; n <= i__1; ++n) {

/*  Skip over the time field plus the number of characters in NCOM
ND */
/*  to begin the first character of the PARM at ICH. */

#line 172 "f2ctmp_lxplt.f"
	    ich = lxcom_1.ncomnd[0] + 11;
#line 173 "f2ctmp_lxplt.f"
	    if (lxcom_1.nparm[n - 1] == 1) {
#line 173 "f2ctmp_lxplt.f"
		goto L410;
#line 173 "f2ctmp_lxplt.f"
	    }

/*  If more than one PARM is specified, the following DO loop will
 */
/*  move ICH to the first character of that particular PARM. */

#line 178 "f2ctmp_lxplt.f"
	    i__2 = lxcom_1.nparm[n - 1] - 1;
#line 178 "f2ctmp_lxplt.f"
	    for (i = 1; i <= i__2; ++i) {
#line 179 "f2ctmp_lxplt.f"
		ich = iscn_ch__(lxcom_1.ibuf, &ich, &lxcom_1.nchar, ",", 1L) 
#line 179 "f2ctmp_lxplt.f"
			+ 1;
#line 180 "f2ctmp_lxplt.f"
	    }
#line 181 "f2ctmp_lxplt.f"
L410:
#line 181 "f2ctmp_lxplt.f"
	    gtprm_(lxcom_1.ibuf, &ich, &lxcom_1.nchar, &c__2, parm, &ierr);
#line 182 "f2ctmp_lxplt.f"
	    if (ierr != 0) {
#line 182 "f2ctmp_lxplt.f"
		goto L440;
#line 182 "f2ctmp_lxplt.f"
	    }
#line 183 "f2ctmp_lxplt.f"
	    *value = *parm;

/*  Determine if the logarithm scale is to be used */

#line 187 "f2ctmp_lxplt.f"
	    if (ichcm_ch__(&lxcom_1.llogx[n - 1], &c__2, "db", 2L) == 0) {
#line 188 "f2ctmp_lxplt.f"
		if (*value <= 0.f) {
#line 188 "f2ctmp_lxplt.f"
		    *value = 1.f;
#line 188 "f2ctmp_lxplt.f"
		}
#line 189 "f2ctmp_lxplt.f"
		*value = r_lg10(value) * 10.f;
#line 190 "f2ctmp_lxplt.f"
	    }

/* Store the value for later plotting & check Y scale min & max. 
*/

#line 194 "f2ctmp_lxplt.f"
	    yy[n - 1] = *value;
#line 195 "f2ctmp_lxplt.f"
	    if (yy[n - 1] < ymin[n - 1]) {
#line 195 "f2ctmp_lxplt.f"
		ymin[n - 1] = yy[n - 1];
#line 195 "f2ctmp_lxplt.f"
	    }
#line 196 "f2ctmp_lxplt.f"
	    if (yy[n - 1] > ymax[n - 1]) {
#line 196 "f2ctmp_lxplt.f"
		ymax[n - 1] = yy[n - 1];
#line 196 "f2ctmp_lxplt.f"
	    }
#line 197 "f2ctmp_lxplt.f"
L440:
#line 197 "f2ctmp_lxplt.f"
	    ;
#line 197 "f2ctmp_lxplt.f"
	}

/* Write scratch record. */

#line 201 "f2ctmp_lxplt.f"
	id = fmpwritexx_(idcb1, &ierr, xx);
#line 202 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 202 "f2ctmp_lxplt.f"
	    goto L1100;
#line 202 "f2ctmp_lxplt.f"
	}
#line 203 "f2ctmp_lxplt.f"
	lxget_();
#line 204 "f2ctmp_lxplt.f"
    }


/* ************************************************************ */

/* 6. Check for a sufficient number of points to plot. */

/* ************************************************************ */


/* !!READ LOG ENTRIES */
#line 214 "f2ctmp_lxplt.f"
/* L600: */
#line 215 "f2ctmp_lxplt.f"
    ierr = 0;
#line 216 "f2ctmp_lxplt.f"
    fmprewind_(idcb1, &ierr);
#line 217 "f2ctmp_lxplt.f"
    if (ierr < 0) {
#line 217 "f2ctmp_lxplt.f"
	goto L1100;
#line 217 "f2ctmp_lxplt.f"
    }
#line 218 "f2ctmp_lxplt.f"
    if (nplot <= 1) {
#line 219 "f2ctmp_lxplt.f"
	po_put_c__(" no plot points - plot deleted.", 31L);
#line 220 "f2ctmp_lxplt.f"
	goto L1200;
#line 221 "f2ctmp_lxplt.f"
    }


/* ************************************************************** */

/* 7. Check for auto-scaling */

/* ************************************************************** */


#line 231 "f2ctmp_lxplt.f"
    xa = (doublereal) lxcom_1.its1;
#line 232 "f2ctmp_lxplt.f"
    xb = (doublereal) lxcom_1.its2;
#line 233 "f2ctmp_lxplt.f"
    if (lxcom_1.its1 != 0) {
#line 233 "f2ctmp_lxplt.f"
	xmin = xa + xb / 1440.;
#line 233 "f2ctmp_lxplt.f"
    }
#line 234 "f2ctmp_lxplt.f"
    xa = (doublereal) lxcom_1.ite1;
#line 235 "f2ctmp_lxplt.f"
    xb = (doublereal) lxcom_1.ite2;
#line 236 "f2ctmp_lxplt.f"
    if (lxcom_1.ite1 != 9999 && lxcom_1.ite1 != 0) {
#line 236 "f2ctmp_lxplt.f"
	xmax = xa + xb / 1440.;
#line 236 "f2ctmp_lxplt.f"
    }
#line 237 "f2ctmp_lxplt.f"
    kpass2 = FALSE_;
#line 238 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.nump;
#line 238 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 239 "f2ctmp_lxplt.f"
	kpass2 = kpass2 || lxcom_1.sdelta[i - 1] != 0.f;
#line 240 "f2ctmp_lxplt.f"
    }
#line 241 "f2ctmp_lxplt.f"
    if (kpass2) {
#line 242 "f2ctmp_lxplt.f"
	i__1 = lxcom_1.nump;
#line 242 "f2ctmp_lxplt.f"
	for (i = 1; i <= i__1; ++i) {
#line 243 "f2ctmp_lxplt.f"
	    y2min[i - 1] = ymin[i - 1];
#line 244 "f2ctmp_lxplt.f"
	    y2max[i - 1] = ymax[i - 1];
#line 245 "f2ctmp_lxplt.f"
	    ymin[i - 1] = 1e20f;
#line 246 "f2ctmp_lxplt.f"
	    ymax[i - 1] = -1e20f;
#line 247 "f2ctmp_lxplt.f"
	}
#line 248 "f2ctmp_lxplt.f"
	ierr = 0;
#line 249 "f2ctmp_lxplt.f"
	fmprewind_(idcb1, &ierr);
#line 250 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 250 "f2ctmp_lxplt.f"
	    goto L1100;
#line 250 "f2ctmp_lxplt.f"
	}
#line 251 "f2ctmp_lxplt.f"
	i__1 = nplot;
#line 251 "f2ctmp_lxplt.f"
	for (i = 1; i <= i__1; ++i) {
#line 252 "f2ctmp_lxplt.f"
	    id = fmpreadxx_(idcb1, &ierr, xx);
#line 253 "f2ctmp_lxplt.f"
	    i__2 = lxcom_1.nump;
#line 253 "f2ctmp_lxplt.f"
	    for (n = 1; n <= i__2; ++n) {
#line 254 "f2ctmp_lxplt.f"
		if (lxcom_1.sdelta[n - 1] < 0.f && yy[n - 1] < y2max[n - 1] + 
#line 254 "f2ctmp_lxplt.f"
			lxcom_1.sdelta[n - 1]) {
#line 255 "f2ctmp_lxplt.f"
		    yy[n - 1] = y2max[n - 1];
#line 256 "f2ctmp_lxplt.f"
		} else if (lxcom_1.sdelta[n - 1] > 0.f && yy[n - 1] > y2min[n 
#line 256 "f2ctmp_lxplt.f"
			- 1] + lxcom_1.sdelta[n - 1]) {
#line 257 "f2ctmp_lxplt.f"
		    yy[n - 1] = y2min[n - 1];
#line 258 "f2ctmp_lxplt.f"
		}
#line 259 "f2ctmp_lxplt.f"
		if (yy[n - 1] < ymin[n - 1]) {
#line 259 "f2ctmp_lxplt.f"
		    ymin[n - 1] = yy[n - 1];
#line 259 "f2ctmp_lxplt.f"
		}
#line 260 "f2ctmp_lxplt.f"
		if (yy[n - 1] > ymax[n - 1]) {
#line 260 "f2ctmp_lxplt.f"
		    ymax[n - 1] = yy[n - 1];
#line 260 "f2ctmp_lxplt.f"
		}
#line 261 "f2ctmp_lxplt.f"
	    }
#line 262 "f2ctmp_lxplt.f"
	}
#line 263 "f2ctmp_lxplt.f"
	ierr = 0;
#line 264 "f2ctmp_lxplt.f"
	fmprewind_(idcb1, &ierr);
#line 265 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 265 "f2ctmp_lxplt.f"
	    goto L1100;
#line 265 "f2ctmp_lxplt.f"
	}
#line 266 "f2ctmp_lxplt.f"
    }
#line 267 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.nump;
#line 267 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 268 "f2ctmp_lxplt.f"
	if (lxcom_1.smax[i - 1] != lxcom_1.smin[i - 1]) {
#line 268 "f2ctmp_lxplt.f"
	    goto L710;
#line 268 "f2ctmp_lxplt.f"
	}
#line 269 "f2ctmp_lxplt.f"
	lxcom_1.smax[i - 1] = ymax[i - 1];
#line 270 "f2ctmp_lxplt.f"
	lxcom_1.smin[i - 1] = ymin[i - 1];
#line 271 "f2ctmp_lxplt.f"
L710:
#line 271 "f2ctmp_lxplt.f"
	;
#line 271 "f2ctmp_lxplt.f"
    }
#line 272 "f2ctmp_lxplt.f"
    if (lxcom_1.ikey == 6) {
#line 272 "f2ctmp_lxplt.f"
	isize = lxcom_1.iwidth - 11;
#line 272 "f2ctmp_lxplt.f"
    }
#line 273 "f2ctmp_lxplt.f"
    if (lxcom_1.ikey == 13) {
#line 273 "f2ctmp_lxplt.f"
	isize = lxcom_1.ihgt - 1;
#line 273 "f2ctmp_lxplt.f"
    }
#line 274 "f2ctmp_lxplt.f"
    scalex = (xmax - xmin) / (real) (lxcom_1.iwidth - 1);
#line 275 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.nump;
#line 275 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 276 "f2ctmp_lxplt.f"
	scale[i - 1] = (lxcom_1.smax[i - 1] - lxcom_1.smin[i - 1]) / isize;
#line 277 "f2ctmp_lxplt.f"
    }


/* ************************************************************** */

/* 8. Write out COMMAND and PARM specifications as a PLOT header */

/* ************************************************************** */


/* Write up to 5 plot titles giving Y-information. */
/* Write one line giving X-information. */

#line 290 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.nump;
#line 290 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 291 "f2ctmp_lxplt.f"
	jlen = iflch_(lxcom_1.logna, &c__20);
#line 292 "f2ctmp_lxplt.f"
	ichmv_(&ltitle[1], &c__1, lxcom_1.logna, &c__1, &jlen);
#line 293 "f2ctmp_lxplt.f"
	i__2 = jlen + 3;
#line 293 "f2ctmp_lxplt.f"
	idum = mcoma_(ltitle, &i__2);
#line 294 "f2ctmp_lxplt.f"
	i__2 = jlen + 4;
#line 294 "f2ctmp_lxplt.f"
	ichmv_(&ltitle[1], &i__2, lxcom_1.lstatn, &c__1, &c__8);
#line 295 "f2ctmp_lxplt.f"
	i__2 = jlen + 14;
#line 295 "f2ctmp_lxplt.f"
	ichmv_(&ltitle[1], &i__2, lxcom_1.lcomnd, &c__1, &c__12);
#line 296 "f2ctmp_lxplt.f"
	id = ib2as_(&lxcom_1.nparm[i - 1], &ltitle[1], &c__37, &c__1);
#line 297 "f2ctmp_lxplt.f"
	rlg10 = 0.f;
#line 298 "f2ctmp_lxplt.f"
	if (lxcom_1.smin[i - 1] != 0.f) {
#line 298 "f2ctmp_lxplt.f"
	    r__2 = (r__1 = lxcom_1.smin[i - 1], abs(r__1));
#line 298 "f2ctmp_lxplt.f"
	    rlg10 = r_lg10(&r__2);
#line 298 "f2ctmp_lxplt.f"
	}

#line 300 "f2ctmp_lxplt.f"
	if (rlg10 >= 0.f) {
#line 301 "f2ctmp_lxplt.f"
	    ilg10 = rlg10 + 1;
/* Computing MAX */
#line 302 "f2ctmp_lxplt.f"
	    i__2 = 6 - ilg10;
#line 302 "f2ctmp_lxplt.f"
	    iprec = max(i__2,0);
#line 303 "f2ctmp_lxplt.f"
	} else {
#line 304 "f2ctmp_lxplt.f"
	    ilg10 = rlg10 - 1;
#line 305 "f2ctmp_lxplt.f"
	    im = 9;
#line 306 "f2ctmp_lxplt.f"
	    if (lxcom_1.smin[i - 1] < 0.f) {
#line 306 "f2ctmp_lxplt.f"
		im = 8;
#line 306 "f2ctmp_lxplt.f"
	    }
/* Computing MIN */
#line 307 "f2ctmp_lxplt.f"
	    i__2 = 5 - ilg10;
#line 307 "f2ctmp_lxplt.f"
	    iprec = min(i__2,im);
#line 308 "f2ctmp_lxplt.f"
	}

#line 310 "f2ctmp_lxplt.f"
	ifill_ch__(imin, &c__1, &c__11, " ", 1L);
#line 311 "f2ctmp_lxplt.f"
	jr2as_(&lxcom_1.smin[i - 1], imin, &c__1, &c__11, &iprec);
#line 312 "f2ctmp_lxplt.f"
	rlg10 = 0.f;
#line 313 "f2ctmp_lxplt.f"
	if (lxcom_1.smax[i - 1] != 0.f) {
#line 313 "f2ctmp_lxplt.f"
	    r__2 = (r__1 = lxcom_1.smax[i - 1], abs(r__1));
#line 313 "f2ctmp_lxplt.f"
	    rlg10 = r_lg10(&r__2);
#line 313 "f2ctmp_lxplt.f"
	}

#line 315 "f2ctmp_lxplt.f"
	if (rlg10 >= 0.f) {
#line 316 "f2ctmp_lxplt.f"
	    ilg10 = rlg10 + 1;
/* Computing MAX */
#line 317 "f2ctmp_lxplt.f"
	    i__2 = 6 - ilg10;
#line 317 "f2ctmp_lxplt.f"
	    iprec = max(i__2,0);
#line 318 "f2ctmp_lxplt.f"
	} else {
#line 319 "f2ctmp_lxplt.f"
	    ilg10 = rlg10 - 1;
#line 320 "f2ctmp_lxplt.f"
	    im = 9;
#line 321 "f2ctmp_lxplt.f"
	    if (lxcom_1.smin[i - 1] < 0.f) {
#line 321 "f2ctmp_lxplt.f"
		im = 8;
#line 321 "f2ctmp_lxplt.f"
	    }
/* Computing MIN */
#line 322 "f2ctmp_lxplt.f"
	    i__2 = 5 - ilg10;
#line 322 "f2ctmp_lxplt.f"
	    iprec = min(i__2,im);
#line 323 "f2ctmp_lxplt.f"
	}

#line 325 "f2ctmp_lxplt.f"
	ifill_ch__(imax, &c__1, &c__11, " ", 1L);
#line 326 "f2ctmp_lxplt.f"
	jr2as_(&lxcom_1.smax[i - 1], imax, &c__1, &c__11, &iprec);
#line 327 "f2ctmp_lxplt.f"
	ichmv_(&ltitle[1], &c__77, &iplch[i - 1], &c__1, &c__1);
#line 328 "f2ctmp_lxplt.f"
	lxcom_1.nchar = iflch_(&ltitle[1], &c__78);
#line 329 "f2ctmp_lxplt.f"
	lxwrt_(&ltitle[1], &lxcom_1.nchar);
#line 330 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 330 "f2ctmp_lxplt.f"
	    goto L1200;
#line 330 "f2ctmp_lxplt.f"
	}
#line 331 "f2ctmp_lxplt.f"
    }

#line 333 "f2ctmp_lxplt.f"
    char2hol_(" ", &lxcom_1.l6, &c__1, &c__1, 1L);
#line 334 "f2ctmp_lxplt.f"
    if (lxcom_1.ikey == 13) {
#line 334 "f2ctmp_lxplt.f"
	goto L900;
#line 334 "f2ctmp_lxplt.f"
    }

/* Write a blank line, then a line of dashes for the strip-chart. */

#line 338 "f2ctmp_lxplt.f"
    lxwrt_(line, &lxcom_1.iwidth);
#line 339 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.iwidth - 12;
#line 339 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__12, &i__1, "--", 2L);
#line 340 "f2ctmp_lxplt.f"
    lxwrt_(line, &lxcom_1.iwidth);
#line 341 "f2ctmp_lxplt.f"
    goto L1000;


/* ************************************************************** */

/* 9. Reformat X-limits to DDD-HHMM.  Make the plot borders. */

/* ************************************************************** */


#line 351 "f2ctmp_lxplt.f"
L900:
#line 351 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &c__130, " ", 1L);
#line 352 "f2ctmp_lxplt.f"
    nch = 1;
#line 353 "f2ctmp_lxplt.f"
    lxhms_(&xmin, line, &nch);
#line 354 "f2ctmp_lxplt.f"
    nch = lxcom_1.iwidth - 7;
#line 355 "f2ctmp_lxplt.f"
    lxhms_(&xmax, line, &nch);
#line 356 "f2ctmp_lxplt.f"
    lxwrt_(line, &nch);
#line 357 "f2ctmp_lxplt.f"
    if (lxcom_1.icode == -1) {
#line 357 "f2ctmp_lxplt.f"
	goto L1200;
#line 357 "f2ctmp_lxplt.f"
    }

/* Clear page image */
/* Write <|> and <-> on plot borders */

#line 362 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 362 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &i__1, " ", 1L);
#line 363 "f2ctmp_lxplt.f"
    char2hol_("| ", line, &c__1, &c__2, 2L);
#line 364 "f2ctmp_lxplt.f"
    char2hol_(" |", &line[imagw - 1], &c__1, &c__2, 2L);

#line 366 "f2ctmp_lxplt.f"
    irec = 1;
#line 367 "f2ctmp_lxplt.f"
    i__1 = -irec;
#line 367 "f2ctmp_lxplt.f"
    id = fmpsetpos_(idcb2, &ierr, &irec, &i__1);
#line 368 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 368 "f2ctmp_lxplt.f"
    id = writestr_(idcb2, &ierr, cline, &i__1, 130L);
#line 369 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 369 "f2ctmp_lxplt.f"
    ichmv_(pline, &c__1, line, &c__1, &i__1);
#line 370 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.ihgt - 1;
#line 370 "f2ctmp_lxplt.f"
    for (i = 2; i <= i__1; ++i) {
#line 371 "f2ctmp_lxplt.f"
	i__2 = imagw << 1;
#line 371 "f2ctmp_lxplt.f"
	ichmv_(&pline[i * 65 - 65], &c__1, line, &c__1, &i__2);
#line 372 "f2ctmp_lxplt.f"
	i__2 = imagw << 1;
#line 372 "f2ctmp_lxplt.f"
	id = writestr_(idcb2, &ierr, cline, &i__2, 130L);
#line 373 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 373 "f2ctmp_lxplt.f"
	    goto L1100;
#line 373 "f2ctmp_lxplt.f"
	}
#line 374 "f2ctmp_lxplt.f"
    }

#line 376 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 376 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &i__1, "-", 1L);
#line 377 "f2ctmp_lxplt.f"
    irec = 1;
#line 378 "f2ctmp_lxplt.f"
    i__1 = -irec;
#line 378 "f2ctmp_lxplt.f"
    id = fmpsetpos_(idcb2, &ierr, &irec, &i__1);
#line 379 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 379 "f2ctmp_lxplt.f"
    id = writestr_(idcb2, &ierr, cline, &i__1, 130L);
#line 380 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 380 "f2ctmp_lxplt.f"
    ichmv_(pline, &c__1, line, &c__1, &i__1);
#line 381 "f2ctmp_lxplt.f"
    if (ierr < 0) {
#line 381 "f2ctmp_lxplt.f"
	goto L1100;
#line 381 "f2ctmp_lxplt.f"
    }
#line 382 "f2ctmp_lxplt.f"
    id = fmpappend_(idcb2, &ierr);
#line 383 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 383 "f2ctmp_lxplt.f"
    id = writestr_(idcb2, &ierr, cline, &i__1, 130L);
#line 384 "f2ctmp_lxplt.f"
    i__1 = imagw << 1;
#line 384 "f2ctmp_lxplt.f"
    ichmv_(&pline[lxcom_1.ihgt * 65 - 65], &c__1, line, &c__1, &i__1);
#line 385 "f2ctmp_lxplt.f"
    if (ierr < 0) {
#line 385 "f2ctmp_lxplt.f"
	goto L1100;
#line 385 "f2ctmp_lxplt.f"
    }


/* ************************************************************** */

/* 10. Plot the points for the plot depending on the type */
/*     specified. */

/* ************************************************************** */


#line 396 "f2ctmp_lxplt.f"
L1000:
#line 396 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &c__130, " ", 1L);
#line 397 "f2ctmp_lxplt.f"
    i__1 = nplot;
#line 397 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 398 "f2ctmp_lxplt.f"
	id = fmpreadxx_(idcb1, &ierr, xx);
/* xx        if(ifbrk(idum).lt.0) icode=-1 */
#line 400 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 400 "f2ctmp_lxplt.f"
	    goto L1200;
#line 400 "f2ctmp_lxplt.f"
	}
#line 401 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 401 "f2ctmp_lxplt.f"
	    goto L1100;
#line 401 "f2ctmp_lxplt.f"
	}

/* Determine the X-position for the single screen plot */

#line 405 "f2ctmp_lxplt.f"
	ix = (integer) ((*xx - xmin) / scalex + 1.f);
#line 406 "f2ctmp_lxplt.f"
	if (ix < 1) {
#line 406 "f2ctmp_lxplt.f"
	    ix = 1;
#line 406 "f2ctmp_lxplt.f"
	}
#line 407 "f2ctmp_lxplt.f"
	if (ix > lxcom_1.iwidth) {
#line 407 "f2ctmp_lxplt.f"
	    ix = lxcom_1.iwidth;
#line 407 "f2ctmp_lxplt.f"
	}

/* Determine the Y-positions for both plots. */

#line 411 "f2ctmp_lxplt.f"
	i__2 = lxcom_1.nump;
#line 411 "f2ctmp_lxplt.f"
	for (j = 1; j <= i__2; ++j) {
#line 412 "f2ctmp_lxplt.f"
	    iy[j - 1] = (yy[j - 1] - lxcom_1.smin[j - 1]) / scale[j - 1] + 
#line 412 "f2ctmp_lxplt.f"
		    1.f;
#line 413 "f2ctmp_lxplt.f"
/* L1010: */
#line 413 "f2ctmp_lxplt.f"
	}

/* Make and write the strip chart plot. */

#line 417 "f2ctmp_lxplt.f"
	if (lxcom_1.ikey != 6) {
#line 417 "f2ctmp_lxplt.f"
	    goto L1030;
#line 417 "f2ctmp_lxplt.f"
	}
#line 418 "f2ctmp_lxplt.f"
	nch = 1;
#line 419 "f2ctmp_lxplt.f"
	lxhms_(xx, line, &nch);
#line 420 "f2ctmp_lxplt.f"
	ichmv_ch__(line, &c__11, "|", 1L);
#line 421 "f2ctmp_lxplt.f"
	i__2 = lxcom_1.iwidth - 12;
#line 421 "f2ctmp_lxplt.f"
	ifill_ch__(line, &c__12, &i__2, " ", 1L);
#line 422 "f2ctmp_lxplt.f"
	ichmv_ch__(line, &lxcom_1.iwidth, "|", 1L);

#line 424 "f2ctmp_lxplt.f"
	i__2 = lxcom_1.nump;
#line 424 "f2ctmp_lxplt.f"
	for (k = 1; k <= i__2; ++k) {
#line 425 "f2ctmp_lxplt.f"
	    if (iy[k - 1] < 1) {
#line 425 "f2ctmp_lxplt.f"
		iy[k - 1] = 1;
#line 425 "f2ctmp_lxplt.f"
	    }
#line 426 "f2ctmp_lxplt.f"
	    if (iy[k - 1] > lxcom_1.iwidth) {
#line 426 "f2ctmp_lxplt.f"
		iy[k - 1] = isize;
#line 426 "f2ctmp_lxplt.f"
	    }
#line 427 "f2ctmp_lxplt.f"
	    i__3 = iy[k - 1] + 11;
#line 427 "f2ctmp_lxplt.f"
	    iqc = jchar_(line, &i__3);
#line 428 "f2ctmp_lxplt.f"
	    if (ichcm_ch__(&iqc, &c__1, " ", 1L) != 0 && ichcm_ch__(&iqc, &
#line 428 "f2ctmp_lxplt.f"
		    c__1, "|", 1L) != 0) {
#line 428 "f2ctmp_lxplt.f"
		goto L1015;
#line 428 "f2ctmp_lxplt.f"
	    }
#line 430 "f2ctmp_lxplt.f"
	    i__3 = iy[k - 1] + 11;
#line 430 "f2ctmp_lxplt.f"
	    ichmv_(line, &i__3, &iplch[k - 1], &c__1, &c__1);
#line 431 "f2ctmp_lxplt.f"
	    goto L1020;
#line 432 "f2ctmp_lxplt.f"
L1015:
#line 432 "f2ctmp_lxplt.f"
	    i__3 = iy[k - 1] + 11;
#line 432 "f2ctmp_lxplt.f"
	    ichmv_ch__(line, &i__3, "=", 1L);
#line 433 "f2ctmp_lxplt.f"
L1020:
#line 433 "f2ctmp_lxplt.f"
	    ;
#line 433 "f2ctmp_lxplt.f"
	}

#line 435 "f2ctmp_lxplt.f"
	lxwrt_(line, &lxcom_1.iwidth);
#line 436 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 436 "f2ctmp_lxplt.f"
	    goto L1200;
#line 436 "f2ctmp_lxplt.f"
	}
#line 437 "f2ctmp_lxplt.f"
	goto L1070;

/* The points for the single screen plot are written to the second */
/* scratch file here. */

#line 442 "f2ctmp_lxplt.f"
L1030:
#line 442 "f2ctmp_lxplt.f"
	i__2 = lxcom_1.nump;
#line 442 "f2ctmp_lxplt.f"
	for (n = 1; n <= i__2; ++n) {
#line 443 "f2ctmp_lxplt.f"
	    if (iy[n - 1] < 1) {
#line 443 "f2ctmp_lxplt.f"
		iy[n - 1] = 1;
#line 443 "f2ctmp_lxplt.f"
	    }
#line 444 "f2ctmp_lxplt.f"
	    if (iy[n - 1] > lxcom_1.ihgt) {
#line 444 "f2ctmp_lxplt.f"
		iy[n - 1] = lxcom_1.ihgt;
#line 444 "f2ctmp_lxplt.f"
	    }
#line 445 "f2ctmp_lxplt.f"
	    irec = lxcom_1.ihgt + 1 - iy[n - 1];
#line 446 "f2ctmp_lxplt.f"
	    i__3 = irec - 1;
#line 446 "f2ctmp_lxplt.f"
	    id = fmpsetline_(idcb2, &ierr, &i__3);
#line 447 "f2ctmp_lxplt.f"
	    id = fmpreadstr_(idcb2, &ierr, cline, 130L);
#line 448 "f2ctmp_lxplt.f"
	    i__3 = imagw << 1;
#line 448 "f2ctmp_lxplt.f"
	    ichmv_(line, &c__1, &pline[irec * 65 - 65], &c__1, &i__3);
#line 449 "f2ctmp_lxplt.f"
	    if (ierr < 0) {
#line 449 "f2ctmp_lxplt.f"
		goto L1100;
#line 449 "f2ctmp_lxplt.f"
	    }
#line 450 "f2ctmp_lxplt.f"
	    iqc = jchar_(line, &ix);
#line 451 "f2ctmp_lxplt.f"
	    if (ichcm_ch__(&iqc, &c__1, " ", 1L) == 0 || ichcm_ch__(&iqc, &
#line 451 "f2ctmp_lxplt.f"
		    c__1, "|", 1L) == 0 || ichcm_ch__(&iqc, &c__1, "-", 1L) ==
#line 451 "f2ctmp_lxplt.f"
		     0) {
#line 454 "f2ctmp_lxplt.f"
		ichmv_(line, &ix, &iplch[n - 1], &c__1, &c__1);
#line 455 "f2ctmp_lxplt.f"
	    } else {
#line 456 "f2ctmp_lxplt.f"
		ichmv_ch__(line, &ix, "=", 1L);
#line 457 "f2ctmp_lxplt.f"
	    }
#line 458 "f2ctmp_lxplt.f"
	    irec = lxcom_1.ihgt + 1 - iy[n - 1];
#line 459 "f2ctmp_lxplt.f"
	    i__3 = irec - 1;
#line 459 "f2ctmp_lxplt.f"
	    id = fmpsetline_(idcb2, &ierr, &i__3);
#line 460 "f2ctmp_lxplt.f"
	    i__3 = imagw << 1;
#line 460 "f2ctmp_lxplt.f"
	    ichmv_(&pline[irec * 65 - 65], &c__1, line, &c__1, &i__3);
#line 461 "f2ctmp_lxplt.f"
	    if (ierr < 0) {
#line 461 "f2ctmp_lxplt.f"
		goto L1100;
#line 461 "f2ctmp_lxplt.f"
	    }
#line 462 "f2ctmp_lxplt.f"
	}
#line 463 "f2ctmp_lxplt.f"
L1070:
#line 463 "f2ctmp_lxplt.f"
	;
#line 463 "f2ctmp_lxplt.f"
    }

#line 465 "f2ctmp_lxplt.f"
    if (lxcom_1.ikey == 13) {
#line 465 "f2ctmp_lxplt.f"
	goto L1080;
#line 465 "f2ctmp_lxplt.f"
    }
#line 466 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__1, &c__130, " ", 1L);
#line 467 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.iwidth - 12;
#line 467 "f2ctmp_lxplt.f"
    ifill_ch__(line, &c__12, &i__1, "-", 1L);
#line 468 "f2ctmp_lxplt.f"
    lxwrt_(line, &lxcom_1.iwidth);
#line 469 "f2ctmp_lxplt.f"
    goto L1200;

/* The Single-Screen plot scratch file is written out here */

#line 473 "f2ctmp_lxplt.f"
L1080:
#line 473 "f2ctmp_lxplt.f"
    i__1 = lxcom_1.ihgt;
#line 473 "f2ctmp_lxplt.f"
    for (i = 1; i <= i__1; ++i) {
#line 474 "f2ctmp_lxplt.f"
	i__2 = imagw << 1;
#line 474 "f2ctmp_lxplt.f"
	ichmv_(line, &c__1, &pline[i * 65 - 65], &c__1, &i__2);
#line 475 "f2ctmp_lxplt.f"
	i__2 = imagw << 1;
#line 475 "f2ctmp_lxplt.f"
	len = iflch_(line, &i__2);
/* xx        if(ifbrk(idum).lt.0) icode=-1 */
#line 477 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 477 "f2ctmp_lxplt.f"
	    goto L1200;
#line 477 "f2ctmp_lxplt.f"
	}
#line 478 "f2ctmp_lxplt.f"
	if (ierr < 0) {
#line 478 "f2ctmp_lxplt.f"
	    goto L1100;
#line 478 "f2ctmp_lxplt.f"
	}
#line 479 "f2ctmp_lxplt.f"
	lxwrt_(line, &len);
#line 480 "f2ctmp_lxplt.f"
	if (lxcom_1.icode == -1) {
#line 480 "f2ctmp_lxplt.f"
	    goto L1200;
#line 480 "f2ctmp_lxplt.f"
	}
#line 481 "f2ctmp_lxplt.f"
    }
#line 482 "f2ctmp_lxplt.f"
    goto L1200;



/* ************************************************************** */

/* 11. Errors encountered while using the scratch files are */
/*     written here. */

/* ************************************************************** */



#line 495 "f2ctmp_lxplt.f"
L1100:
#line 496 "f2ctmp_lxplt.f"
    s_copy(outbuf, " error ", 79L, 7L);
#line 497 "f2ctmp_lxplt.f"
    ib2as_(&ierr, &answer, &c__1, &c__4);
#line 498 "f2ctmp_lxplt.f"
    hol2char_(&answer, &c__1, &c__4, outbuf + 7, 72L);
#line 499 "f2ctmp_lxplt.f"
    lxcom_1.nchar = trimlen_(outbuf, 79L) + 1;
#line 500 "f2ctmp_lxplt.f"
    s_copy(outbuf + (lxcom_1.nchar - 1), " in scratch file - plot deleted.", 
#line 500 "f2ctmp_lxplt.f"
	    79 - (lxcom_1.nchar - 1), 32L);
#line 501 "f2ctmp_lxplt.f"
    po_put_c__(outbuf, 79L);


/* ************************************************************** */

/* 12. Purge the scratch files. */

/* ************************************************************** */


#line 511 "f2ctmp_lxplt.f"
L1200:
#line 512 "f2ctmp_lxplt.f"
    fmpclose_(idcb1, &ierr);
#line 513 "f2ctmp_lxplt.f"
    ftn_purge__(filename1, &ierr, 64L);
#line 514 "f2ctmp_lxplt.f"
    fmpclose_(idcb2, &ierr);
#line 515 "f2ctmp_lxplt.f"
    fmpclose_(idcb3, &ierr);
/* !!TEST!!! */
#line 516 "f2ctmp_lxplt.f"
    ftn_purge__(filename2, &ierr, 64L);
#line 517 "f2ctmp_lxplt.f"
    lxcom_1.ilxget = 0;
#line 518 "f2ctmp_lxplt.f"
    if (lxcom_1.nump == 0) {
#line 519 "f2ctmp_lxplt.f"
	po_put_c__(" parm command must be issued in order to plot", 45L);
#line 520 "f2ctmp_lxplt.f"
    }
#line 521 "f2ctmp_lxplt.f"
    if (lxcom_1.ncmd == 0) {
#line 522 "f2ctmp_lxplt.f"
	po_put_c__(" one command must be issued in order to p        lot", 
#line 522 "f2ctmp_lxplt.f"
		52L);
#line 524 "f2ctmp_lxplt.f"
    }
#line 525 "f2ctmp_lxplt.f"
    if (lxcom_1.ncmd == 0 || lxcom_1.nump == 0) {
#line 525 "f2ctmp_lxplt.f"
	lxcom_1.icode = -1;
#line 525 "f2ctmp_lxplt.f"
    }

#line 527 "f2ctmp_lxplt.f"
    return 0;
} /* lxplt_ */

#undef ltitle
#undef namcmc
#undef value
#undef lsknc
#undef iparm
#undef lognc
#undef cline
#undef namfc
#undef irec1
#undef parm
#undef imax
#undef imin
#undef cmin
#undef ival
#undef cmax
#undef line
#undef ihas
#undef ihc
#undef jbc
#undef ibc
#undef yy
#undef xx
#undef iplch


