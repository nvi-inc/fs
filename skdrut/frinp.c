/* f2ctmp_frinp.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    doublereal effreq[1400]	/* was [2][35][20] */, ffact[700]	/* 
	    was [35][20] */, freqrf[11200]	/* was [16][35][20] */, 
	    freqlo[11200]	/* was [16][35][20] */, bitdens[700]	/* 
	    was [35][20] */;
    real vcband[11200]	/* was [16][35][20] */, wavei[1400]	/* was [2][35]
	    [20] */, bwrms[1400]	/* was [2][35][20] */, trkn[1400]	
	    /* was [2][35][20] */, samprate[20];
    integer ncodes, nband, nfreq[1400]	/* was [2][35][20] */, npassf[700]	
	    /* was [35][20] */, ntrakf[700]	/* was [35][20] */, nchan[700]
	    	/* was [35][20] */, invcx[11200]	/* was [16][35][20] */
	    , ibbcx[11200]	/* was [16][35][20] */, itras[1612800]	/* 
	    was [2][2][1][16][36][35][20] */, ihdpos[352800]	/* was [1][
	    504][35][20] */, ihddir[352800]	/* was [1][504][35][20] */, 
	    nstsav, istsav[35], ifan[700]	/* was [35][20] */, npassl[
	    700]	/* was [35][20] */;
    shortint lnafrq[80]	/* was [4][20] */, lnafrsub[2800]	/* was [4][35]
	    [20] */, lcode[20], lmode[2800]	/* was [4][35][20] */, lmfmt[
	    2800]	/* was [4][35][20] */, lsubvc[11200]	/* was [16][
	    35][20] */, lifinp[11200]	/* was [16][35][20] */, lpol[11200]	
	    /* was [16][35][20] */, lnetsb[11200]	/* was [16][35][20] */
	    , losb[11200]	/* was [16][35][20] */, lband[2], lbarrel[
	    1400]	/* was [2][35][20] */, ls2mode[5600]	/* was [8][35]
	    [20] */, lprefix[2800]	/* was [4][35][20] */;
} freqs_;

#define freqs_1 freqs_

struct {
    char cset[33600]	/* was [16][35][20] */, modedefnames[2560], 
	    cpassorderl[1058400]	/* was [504][35][20] */;
} freqs_ch__;

#define freqs_ch__1 freqs_ch__

struct {
    doublereal stnxyz[105]	/* was [3][35] */, baselen[595], axisof[35], 
	    glong[35], phi[35], hgt[35], r1[35], r2[35], bx[595], by[595], bz[
	    595];
    real stnpos[70]	/* was [2][35] */, stnlim[140]	/* was [2][2][35] */, 
	    stnrat[70]	/* was [2][35] */, stnelv[35], azhorz[2100]	/* 
	    was [60][35] */, elhorz[2100]	/* was [60][35] */, co1mask[
	    1050]	/* was [30][35] */, co2mask[1050]	/* was [30][
	    35] */, sefdst[70]	/* was [2][35] */, diaman[35], sefdpar[350]	
	    /* was [5][2][35] */, sefdstel[70]	/* was [2][35] */;
    integer nstatn, iaxis[35], maxpas[35], istcon[70]	/* was [2][35] */, 
	    nhorz[35], ncord[35], maxtap[35], nsefdpar[70]	/* was [2][35]
	     */, nrecst[35], nheads[35], ibitden_save__[35], itearl_save__, 
	    itearl[35], itlate[35], itgap[35], ns2tapes[35];
    shortint lstnna[140]	/* was [4][35] */, lstcod[35], lpocod[35], 
	    lposid[35], lantna[140]	/* was [4][35] */, lterid[70]	/* 
	    was [2][35] */, lstrec[140]	/* was [4][35] */, lstrack[140]	/* 
	    was [4][35] */, loccup[140]	/* was [4][35] */, lhccod[35], lterna[
	    140]	/* was [4][35] */, lbsefd[70]	/* was [2][35] */, 
	    ls2speed[70]	/* was [2][35] */;
    logical klineseg[35];
} statn_;

#define statn_1 statn_

struct {
    char stndefnames[4480], tape_motion_type__[4480];
} statn_ch__;

#define statn_ch__1 statn_ch__

/* Table of constant values */

static integer c__1 = 1;
static integer c__2 = 2;
static integer c__8 = 8;
static integer c__4 = 4;

/* Subroutine */ int frinp_(shortint *ibuf, integer *ilen, integer *lu, 
	integer *ierr)
{
    /* Format strings */
    static char fmt_9201[] = "(\002FRINP01 - Error in field \002,i3,\002 of "
	    "this line:\002/40a2)";
    static char fmt_9202[] = "(\002FRINP02 - Too many frequency codes.  Max "
	    "is \002,i3,\002 codes.\002)";
    static char fmt_9203[] = "(\002FRINP03 - Warning! A new frequency code w"
	    "as found out of order on the following line and was ignored:\002"
	    "/40a2)";
    static char fmt_9400[] = "(\002FRINP04 - Station \002,4a2,\002 not selec"
	    "ted. \002,\002Frequency sequence for this station ignored.\002)";
    static char fmt_9401[] = "(\002FRINP06 - Station \002,4a2,\002 not selec"
	    "ted. \002,\002Barrel roll for this station ignored.\002)";
    static char fmt_9402[] = "(\002FRINP07 - Station \002,4a2,\002 not selec"
	    "ted. \002,\002Recording format for this station ignored.\002)";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4, i__5, i__6, i__7, i__8;
    doublereal d__1;

    /* Builtin functions */
    integer s_wsfe(cilist *), do_fio(integer *, char *, ftnlen), e_wsfe(void),
	     s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    extern integer ichcm_ch__(shortint *, integer *, char *, ftnlen), 
	    ichmv_ch__(shortint *, integer *, char *, ftnlen);
    static doublereal f;
    static integer i, j, n;
    extern /* Subroutine */ int hol2upper_(shortint *, integer *);
    static doublereal f1;
    static real f2;
    static integer ib, ic;
    static shortint lc;
    static integer ii;
    static char cs[3];
    static real vb;
    static integer is;
    static shortint lm[4];
    static integer iv;
    static shortint ls;
    static integer ix, ns;
    static shortint lid, lna[4];
    static integer ivc, icx;
    static shortint lin, lsg, lst[140]	/* was [4][35] */;
    static logical kmk3;
    static integer ibad;
    static real rbbc;
    static shortint lbar[70]	/* was [2][35] */;
    static integer idum;
    static shortint lfmt[70]	/* was [2][35] */;
    static integer inum, itrk[144]	/* was [4][36][1] */, istn;
    extern integer ias2b_(shortint *, integer *, integer *);
    static integer icode, itype;
    static logical kvlba;
    static real srate;
    extern integer jchar_(shortint *, integer *), ichmv_(shortint *, integer *
	    , shortint *, integer *, integer *), igtfr_(shortint *, integer *)
	    , igtst_(shortint *, integer *);
    extern logical knaeq_(shortint *, shortint *, integer *);
    extern /* Subroutine */ int unpco_(shortint *, integer *, integer *, 
	    shortint *, shortint *, doublereal *, real *, integer *, shortint 
	    *, real *, integer *, char *, integer *, ftnlen), unplo_(shortint 
	    *, integer *, integer *, shortint *, shortint *, shortint *, 
	    shortint *, doublereal *, integer *, shortint *, integer *);
    static doublereal bitden;
    static integer nvlist, ivlist[16];
    extern /* Subroutine */ int unpfsk_(shortint *, integer *, integer *, 
	    shortint *, shortint *, shortint *, integer *), unprat_(shortint *
	    , integer *, integer *, shortint *, real *), unpbar_(shortint *, 
	    integer *, integer *, shortint *, shortint *, integer *, shortint 
	    *), unpfmt_(shortint *, integer *, integer *, shortint *, 
	    shortint *, integer *, shortint *);
    extern integer iscn_ch__(shortint *, integer *, integer *, char *, ftnlen)
	    ;
    extern /* Subroutine */ int char2hol_(char *, shortint *, integer *, 
	    integer *, ftnlen);

    /* Fortran I/O blocks */
    static cilist io___24 = { 0, 0, 0, fmt_9201, 0 };
    static cilist io___27 = { 0, 0, 0, fmt_9202, 0 };
    static cilist io___28 = { 0, 0, 0, fmt_9203, 0 };
    static cilist io___36 = { 0, 0, 0, "(\"FRINP03 - Station \",a2,\" not se"
	    "lected.\",              \" LO entry on the following line ignore"
	    "d:\"/40a2)", 0 };
    static cilist io___40 = { 0, 0, 0, "(\"FRINP04 - Subgroup \",a2,\" incon"
	    "sistent with \"         ,a2,\" for channel \",i3,\", station \","
	    "4a2)", 0 };
    static cilist io___41 = { 0, 0, 0, "(\"FRINP05 - Code \",a2,\" inconsist"
	    "ent with \",            a2,\" for channel \",i3,\", station \",4"
	    "a2)", 0 };
    static cilist io___42 = { 0, 0, 0, "(\"FRINP04 - Subgroup \",a2,\" incon"
	    "sistent with \"         ,a2,\" for channel \",i3,\", station \","
	    "4a2)", 0 };
    static cilist io___43 = { 0, 0, 0, "(\"FRINP05 - Code \",a2,\" inconsist"
	    "ent with \",            a2,\" for channel \",i3,\", station \",4"
	    "a2)", 0 };
    static cilist io___48 = { 0, 0, 0, fmt_9400, 0 };
    static cilist io___50 = { 0, 0, 0, fmt_9401, 0 };
    static cilist io___51 = { 0, 0, 0, fmt_9402, 0 };


/*     This routine reads and decodes one line in the $CODES section. */
/*     Call in a loop to get all values in freqs.ftni filled in, */
/*     then call SETBA to figure out which frequency bands are there. */

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
/* 951018 nrv Add obar */
/* 951019 nrv Add MAX_CHAN to replace hard-coded "14"'s */
/* 960226 nrv Increase MAX_HOR to 40 */
/* 960412 nrv Test 300 sources */
/* 960516 nrv Add MAX_FLD, set to 20 */
/* 960522 nrv Add lots of max's, change max_pass to index*subpasses */
/* 960628 nrv Allow more modes in catalog. */
/* 970114 nrv Add MAX_SORLEN, length of source names. */
/* 970204 nrv Change max_subpass to 36, max_frq to 20 */
/* 970206 nrv Chage max_headstack to 1 */

/* ******************************************************************** */


/*     The maximum number of stations which can be selected for */
/*     an experiment at one time.  Used in SKED and DRUDG. */

/*     PARAMETER (MAX_STN = 16) */

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

/*     The maximum number of CHARACTERS in a source name. Should be */
/*     an even integer. Maximum size now is 26, to be cmpatible with */
/*     the multiple-use arrays in skcom. Increase the LNASEx arrays if */
/*     you need longer source names. */

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

/*     Maximum number of headstacks. Limited to 2 within sked/drudg */
/*     for now. Change to 1 to save space. */
/*     Maximum number of tracks on a headstack. */
/*     Maximum number of index positions for the headstacks. */
/*     Maximum number of subpasses per index position. Set to */
/*     4 for now, to save array space. Increase to 8. */

/*     Maximum number of passes that are possible. */
/*     Maximum number of IFs in a system. */
/*     Maximum number of BBCs in a system. */
/*     Maximum number of video channels. */

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



/*     Definitions for octal constants. */
/*     Unit 5 = standard input (keyboard) */
/*     Unit 6 = standard output (screen) */


/*     The lengths of the general purpose buffers IBUF and IBUFQ */
/*     are determined by MAX_STN as follows: */
/*     length of IBUF in chars must be >=60+MAX_STN*13 */
/*     IBUFQ is 1 word longer than IBUF. */
/*     ***NOTE*** You must modify the read/write statements in */
/*     readf_asc and writf_asc to extend the buffer size als. */

/*     PARAMETER (IBUF_LEN = 256) */
/*     PARAMETER (IBUFQ_LEN = 257) */

/*     The maximum number of scans allowed in a schedule */


/*     The maximum number of entries in the source */
/*     catalog. CAUTION: YOU MUST ALSO CHANGE IBFCOM_LEN BELOW. */


/*     The length of array IBFCOM = 4*MAX_ENT_SOR */


/*     The maximum number of entries in the station */
/*     catalog. This must be no more than 108. This */
/*     is because the station and frequency selection */
/*     options only can display one page on the terminal. */
/*     (Limit set by NROWS*NCOLS in SEST) */


/*     The maximum number of entries in the modes catalog that */
/*     will be read for selection. */
/*     The maximum size of the selection array, for all types of */
/*     selection. This must be the larger of MAX_ENT_SOR, and */
/*     MAX_FRQ*MAX_STN. */
/*     The name of the control files. These files are */
/*     read at run time. cctfil is the default control */
/*     file that SKED reads each time it is run and should */
/*     be in the users path. cownctl is a */
/*     personal control file that should be in the */
/*     directory of the user when running SKED if it is */
/*     to be used. */

/* this path is for Goddard's HPUX */
/* this path is for Linux FS */
/*     parameter(cctfil = '/usr2/control/skedf.ctl') */

/*     FREQUENCY CODE INFORMATION COMMON BLOCK */

/*891117 nrv Added dimension to change NFREQ from total number of frequenc
ies*/
/* 910702 nrv changed VLBA-related arrays to correspond to PC version */
/*910709 NRV Changed FREQLO,LSGINP to allow 3 LO frequencies, removed PATC
H*/
/* 910924 NRV Add WAVEI */
/* 930802 NRV Add ihdpos, ihddir to hold head position information */
/* 940620 nrv Add trkn to hold number of tracks being recorded */
/* 950303 nrv Add variables effreq, ffact for ionosphere S/X correction. 
*/
/* 950405 nrv Change index on head arrays for mode E (4*max_pass) */
/*951018 nrv Remove special VLBA arrays and add LO per channel and 8-lette
r*/
/*           recording modes. Change "14" to MAX_CHAN. Change "2" to MAX_B
AND.*/
/* 951020 nrv Remove lsb and isyn -- not needed */
/* 951115 nrv Make frequency sequences indexed by station. Add SB. */
/* 960321 nrv Add SAMPRATE */
/* 960409 nrv Add IHDPO2 and IHDDI2 for headstack 2 */
/* 960510 nrv Add IFAN for fan-out factor */
/* 960517 nrv Add def names */
/* 960527 nrv Add cpassorderl */
/* 960610 nrv Change first index on ihddir etc. to max_pass instead of */
/*           4*max_pass because max_pass is now set to max_subpass*max_ind
ex.*/
/* 960709 nrv Add barrel roll by station and code */
/* 961031 nrv Add LMFMT for recording format. LMODE should be reserved for
 */
/*            the mode name if any. */
/* 970110 nrv Add icode index to cpassorderl */
/* 970114 nrv Add LPREFIX. */
/* 970121 nrv Add station and code indices to npassl */
/* 970206 nrv Remove ihdpo2,itra2,ihddi2 and add an index to */
/*            ihdpos,itras,ihddir */
/* 970718 nrv Change FREQLO and FREQRF to double precision */

/*     ffact   - frequency factor, for S/X ionosphere corrections */
/*     effreq  - effective frequency for each band, for S/X ionosphere */
/*               corrections */
/*     bitdens - bit density by station and code */

/*     VCBAND - final video bandwidth, MHz */
/*     FREQRF - observing frequency for each VC, in each code, MHz */
/*    FREQLO - LO frequencies, for each channel, by station, for each code
, MHz*/
/*     wavei   - constant to convert baseline length to wavelengths */
/*     bwrms - rms bandwidth */
/*     trkn    - total number of tracks recorded per band, per station */
/*               (may be non-integer in the case of switching), used */
/*               for calculating SNR. Each track is assumed to be recorded
 */
/*               at the sample rate. */
/*     samprate - sample rate, per frequency code, Mb/s. */
/*     nband  - number of entries in lband */
/*     NCODES - number of codes filled in */
/*     NFREQ - number of frequencies in each subgroup in each code */
/*     NPASSF - number of passes per head position for this code */
/*     nchan  - total number of frequency channels per station and code */
/*             (not this is NOT the number of VCs but the number of channe
ls)*/
/*     invcx  - index number of each frequency channel, if zero then */
/*              this channel is not recorded at this station */
/*     ibbcx - physical BBC number of each channel */
/*     itras  - track assignments (s,b,p,c,f), i.e. track number on */
/*              which the following signals are recorded: */
/*          s = sideband, U/L */
/*          b = bit, sign/magnitude */
/*          p = corresponding pass, forward/reverse (1 to max_subpass, */
/*              e.g. 1 for mode A, 1 or 2 for B and C, 1 to 28 for D, */
/*              1 to 4 for E) */
/*          c = channel (1 to max_chan) */
/*          f = frequency code (1 to max_frq) */
/*     ihdpos - head position offsets */
/*     ihddir - corresponding pass number */
/*     ntrakf - number of tracks recorded per pass for this code */
/*    nstsav,istsav - number and indices of station names found on the "F"
 line*/
/*     ifan - fan-out factor, 1, 2, or 4, taken from the mode name */
/*     npassl - number of passes in the pass order list */

/*     LCODE - the 2-character frequency codes */
/*     LMODE - the observing mode name for each code */
/*     LMFMT - the observing mode format for each code */
/*     LS2MODE - the S2 recording mode for each code */
/*     LSUBVC - sub-group code for each VC, in each code */
/*     lifinp - hollerith IF input, e.g. A,B,C,D,1A,1N,2A,2N,3A,3N */
/*     LNAFRQ - 8-char name for this code */
/*     LNAFRSUB - 8-char name for this sub-code (subset of frequencies) */
/*      lnafrq      lnafrsub (can be a different subcode name for each sta
tion)*/
/*       ------      ---------------------- */
/*       code1       stn1  stn2  stn3 ... */
/*       code2       stn1  stn2  stn3 ... */
/*        etc. */
/*     lband  - all bands in all codes */
/*     lpol - polarization per channel */
/*     lnetsb - net sideband for each channel */
/*     losb - net sideband for each station's lo */
/*     lbarrel - barrel roll for each station */
/*     lprefix - procedure name prefix */

/* switch set per channel */
/* def names from the vex file */

/* pass order list */


/*  INPUT: */
/*     STATION INFORMATION COMMON BLOCK */

/* 960817 nrv Add S2 variables */





/*  NSTN   - number of stations */
/*  LSTNNA - position names, up to 8 chars */
/*  STNPOS - station longitude and latitude, geodetic, radians */
/*  STNLIM - limit stops: (1,1) lower limit, axis 1 */
/*           (degrees)    (2,1) upper limit, axis 1 */
/*                        (1,2) lower limit, axis 2 */
/*                        (2,2) upper limit, axis 2 */
/*  STNRAT - slew rates: (1) axis 1, (2) axis 2 (degrees per minute) */
/*  IAXIS  - axis type: 1=hadec, 2=xy, 3=azel */
/*  LSTCOD - station codes, 2 characters */
/*  LITERID - terminal ID, up to 4 characters */
/*  LSTREC - recorder type */
/*  LSTRACK - rack type */
/*  STNELV - station elevation limit, assigned in SKED */
/*  ISTCON - slew overhead time, seconds */
/*  NHORZ - number of az, el pairs in horizon mask */
/*  AZHORZ, ELHORZ - as, el of horizon mask */
/*  NCORD - number of pairs in coordinate mask */
/*  CO1MASK, CO2MASK - mask for antenna coordinates */
/*  LPOSID - position ID's */
/*  SEFDST - System Equiv. Flux Densities by observing band. */
/*  baselen - baseline lengths, meters */
/*  stnxyz - station position x,y,z in meters */
/*  lantna - antenna names */
/*  axisof - axis offset */
/*  diaman - antenna diameter */
/*  loccup - occupation code */
/*  lhccod - code for horizon/coordinate mask */
/*  LPOCOD - position codes */
/*  maxtap - maximum tape length for each station */
/*  lterna - terminal name */
/*  lbsefd - band names for sefds, storage until frequencies are known */
/*  klineseg - true if this station's horizon mask is line segments, */
/*             false if it's step functions */
/*      - buffer holding source entry */
/*     ILEN - length of IBUF in WORDS */
/*     LU - unit for error messages */

/*  OUTPUT: */
/*     IERR - error number */


/*  LOCAL: */

/*  History */
/*     880310 NRV DE-COMPC'D */
/*     891116 NRV Cleaned up format, added fill-in of LBAND */
/*            nrv implicit none */
/*     930421 nrv Re-added: store track assignments */
/* 951019 nrv Add extension of LO lines to include per channel */
/* 951116 nrv Change to frequency sequencey per station */
/* 960124 nrv Missing argument in call to UNPLO */
/* 960212 nrv Missing argument in UNPLO */
/* 960213 nrv Uppercase the frequency code */
/* 960220 nrv Save LNAFRSUB even if no station names on the "F" line. */
/* 960221 nrv Read switching from "C" lines, also BBC index. */
/* 960223 nrv Fill in "L" line info on per channel basis */
/* 960228 nrv Change unplo call to include VC assignments from PC-SCHED */
/*            patching info. */
/* 960321 nrv Add "R" line for sample rate */
/* 960405 nrv Remove "subcode" from reading by UNPFSK */
/* 960405 nrv Check for valid station index from "F" line before filling 
*/
/*            in frequency sequences etc. */
/*960409 nrv Allow for headstack 2 in call to UNPCO and setting ITRAS,ITRA
2*/
/* 960516 nrv Crosscheck sub-groups on "L" lines and "C" lines using */
/*            channel numbers not BBC numbers */
/* 960709 nrv Add "B" line for barrel roll */
/* 960709 nrv Initialize fanout factor to 0, for Mark III modes. */
/*            It is reset to 1,2,4 if it's a VLBA mode. */
/* 961020 nrv Set the BBC sideband to "U" for non-Vex input. */
/* 970115 nrv Add UNPFMT for recording format by station line. */
/* 970117 nrv Add IF3O and IF3I to Mk3-4 allowed values. */
/* 970206 nrv Change itra2 to itras and add headstack index */


/*     1. Find out what type of entry this is.  Decode as appropriate. */

    itype = 0;
    if (jchar_(ibuf, &c__1) == 70) {
	itype = 3;
    }
/* F frequency name, code and s */
    if (jchar_(ibuf, &c__1) == 67) {
	itype = 1;
    }
/* C frequency sequence lines */
    if (jchar_(ibuf, &c__1) == 76) {
	itype = 2;
    }
/* L LO lines */
    if (jchar_(ibuf, &c__1) == 82) {
	itype = 4;
    }
/* R sample rate lines */
    if (jchar_(ibuf, &c__1) == 66) {
	itype = 5;
    }
/* B barrel roll lines */
    if (jchar_(ibuf, &c__1) == 68) {
	itype = 6;
    }
/* D recording format lines */
    if (itype == 1) {
	i__1 = *ilen - 1;
	unpco_(&ibuf[1], &i__1, ierr, &lc, &lsg, &f1, &f2, &icx, lm, &vb, 
		itrk, cs, &ivc, 3L);
    }
    if (itype == 2) {
	i__1 = *ilen - 1;
	unplo_(&ibuf[1], &i__1, ierr, &lid, &lc, &lsg, &lin, &f, ivlist, &ls, 
		&nvlist);
    }
    if (itype == 3) {
	i__1 = *ilen - 1;
	unpfsk_(&ibuf[1], &i__1, ierr, lna, &lc, lst, &ns);
    }
    if (itype == 4) {
	i__1 = *ilen - 1;
	unprat_(&ibuf[1], &i__1, ierr, &lc, &srate);
    }
    if (itype == 5) {
	i__1 = *ilen - 1;
	unpbar_(&ibuf[1], &i__1, ierr, &lc, lst, &ns, lbar);
    }
    if (itype == 6) {
	i__1 = *ilen - 1;
	unpfmt_(&ibuf[1], &i__1, ierr, &lc, lst, &ns, lfmt);
    }
    hol2upper_(&lc, &c__2);

/* 1.5 If there are errors, handle them first. */

/* uppercase frequency code */
    if (*ierr != 0) {
	*ierr = -(*ierr + 100);
	io___24.ciunit = *lu;
	s_wsfe(&io___24);
	do_fio(&c__1, (char *)&(*ierr), (ftnlen)sizeof(integer));
	i__1 = *ilen;
	for (i = 2; i <= i__1; ++i) {
	    do_fio(&c__1, (char *)&ibuf[i - 1], (ftnlen)sizeof(shortint));
	}
	e_wsfe();
	return 0;
    }
/*  Lines need not be in order, so we may encounter a new code */
/*  on any line. But this is a bad practice. */
    if (igtfr_(&lc, &icode) == 0) {
/* a new code */
	if (itype == 3) {
/* "F" line */
	    ++freqs_1.ncodes;
	    if (freqs_1.ncodes > 20) {
/* too many codes */
		*ierr = 20;
		--freqs_1.ncodes;
		io___27.ciunit = *lu;
		s_wsfe(&io___27);
		do_fio(&c__1, (char *)&(*ierr), (ftnlen)sizeof(integer));
		e_wsfe();
		return 0;
	    }
/* too many codes */
	    icode = freqs_1.ncodes;
	} else {
/* not allowed */
	    io___28.ciunit = *lu;
	    s_wsfe(&io___28);
	    i__1 = *ilen;
	    for (i = 2; i <= i__1; ++i) {
		do_fio(&c__1, (char *)&ibuf[i - 1], (ftnlen)sizeof(shortint));
	    }
	    e_wsfe();
	    return 0;
	}
    }

/*     2. Now decide what to do with this information. */
/*     First, handle code type entries, "C" with frequencies. */

/* a new code */
    if (itype == 1) {
/* code entry */
	i__1 = freqs_1.nstsav;
	for (j = 1; j <= i__1; ++j) {
/* apply to each station on the preceding "F" line */
	    is = freqs_1.istsav[(i__2 = j - 1) < 35 && 0 <= i__2 ? i__2 : 
		    s_rnge("istsav", i__2, "frinp_", 125L)];
	    if (is > 0) {
/* valid station */
		freqs_1.nchan[(i__2 = is + icode * 35 - 36) < 700 && 0 <= 
			i__2 ? i__2 : s_rnge("nchan", i__2, "frinp_", 127L)] =
			 freqs_1.nchan[(i__3 = is + icode * 35 - 36) < 700 && 
			0 <= i__3 ? i__3 : s_rnge("nchan", i__3, "frinp_", 
			127L)] + 1;
/* count them */
		freqs_1.invcx[(i__3 = freqs_1.nchan[(i__2 = is + icode * 35 - 
			36) < 700 && 0 <= i__2 ? i__2 : s_rnge("nchan", i__2, 
			"frinp_", 128L)] + (is + icode * 35 << 4) - 577) < 
			11200 && 0 <= i__3 ? i__3 : s_rnge("invcx", i__3, 
			"frinp_", 128L)] = icx;
/* channel index number */
		freqs_1.lsubvc[(i__2 = icx + (is + icode * 35 << 4) - 577) < 
			11200 && 0 <= i__2 ? i__2 : s_rnge("lsubvc", i__2, 
			"frinp_", 129L)] = lsg;
/* sub-group, i.e. S or X */
		freqs_1.freqrf[(i__2 = icx + (is + icode * 35 << 4) - 577) < 
			11200 && 0 <= i__2 ? i__2 : s_rnge("freqrf", i__2, 
			"frinp_", 130L)] = f1;
		freqs_1.vcband[(i__2 = icx + (is + icode * 35 << 4) - 577) < 
			11200 && 0 <= i__2 ? i__2 : s_rnge("vcband", i__2, 
			"frinp_", 131L)] = vb;
		freqs_1.lcode[(i__2 = icode - 1) < 20 && 0 <= i__2 ? i__2 : 
			s_rnge("lcode", i__2, "frinp_", 132L)] = lc;
/*         All listed Mk3 frequencies are for USB recording. 
*/
/*         LSB is specified in track assignments. */
/* 2-letter code for the sequence */
		idum = ichmv_ch__(&freqs_1.lnetsb[(i__2 = icx + (is + icode * 
			35 << 4) - 577) < 11200 && 0 <= i__2 ? i__2 : s_rnge(
			"lnetsb", i__2, "frinp_", 135L)], &c__1, "U", 1L);
		idum = ichmv_(&freqs_1.lmode[(i__2 = (is + icode * 35 << 2) - 
			144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmode", 
			i__2, "frinp_", 136L)], &c__1, lm, &c__1, &c__8);
/*         This should be "VLBA" for NDR, otherwise it's DR. d
rudg will */
/*         modify this when it gets user input on the formatte
r type. */
/*         This is used by SPEED. */
/* recording mode */
		idum = ichmv_(&freqs_1.lmfmt[(i__2 = (is + icode * 35 << 2) - 
			144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmfmt", 
			i__2, "frinp_", 140L)], &c__1, lm, &c__1, &c__8);
/*         Determine fanout factor here. Fan-in code is commen
ted for now. */
/* recording format */
		freqs_1.ifan[(i__2 = is + icode * 35 - 36) < 700 && 0 <= i__2 
			? i__2 : s_rnge("ifan", i__2, "frinp_", 142L)] = 0;
		ix = iscn_ch__(&freqs_1.lmode[(i__2 = (is + icode * 35 << 2) 
			- 144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmode", 
			i__2, "frinp_", 143L)], &c__1, &c__8, "1:", 2L);
/*         iy = iscn_ch(lmode(1,is,icode),1,8,':1') */
		if (ix != 0) {
/* possible fan-out */
		    i__3 = ix + 2;
		    n = ias2b_(&freqs_1.lmode[(i__2 = (is + icode * 35 << 2) 
			    - 144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmode"
			    , i__2, "frinp_", 146L)], &i__3, &c__1);
		    if (n > 0) {
			freqs_1.ifan[(i__2 = is + icode * 35 - 36) < 700 && 0 
				<= i__2 ? i__2 : s_rnge("ifan", i__2, "frinp_"
				, 147L)] = n;
		    }
/*         else if (iy.ne.0) then ! possible fan-in */
/*           n=ias2b(lmode(1,is,icode),iy+2,1) */
/*           if (n.gt.0) ifan(is,icode)=n */
		}
/*         Set bit density depending on the mode */
		if (ichcm_ch__(&freqs_1.lmode[(i__2 = (is + icode * 35 << 2) 
			- 144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmode", 
			i__2, "frinp_", 153L)], &c__1, "V", 1L) == 0) {
		    bitden = 34020.;
/* VLBA non-data replacement */
		} else {
		    bitden = 33333.;
/* Mark3/4 data replacement */
		}
/*         If "56000" was specified, use higher station bit de
nsity */
		if (statn_1.ibitden_save__[(i__2 = is - 1) < 35 && 0 <= i__2 ?
			 i__2 : s_rnge("ibitden_save", i__2, "frinp_", 159L)] 
			== 56000) {
		    if (ichcm_ch__(&freqs_1.lmode[(i__2 = (is + icode * 35 << 
			    2) - 144) < 2800 && 0 <= i__2 ? i__2 : s_rnge(
			    "lmode", i__2, "frinp_", 160L)], &c__1, "V", 1L) 
			    == 0) {
			bitden = 56700.;
/* VLBA non-data replacement */
		    } else {
			bitden = 56250.;
/* Mark3/4 data replacement */
		    }
		}
/*         Store the bit density by station */
		freqs_1.bitdens[(i__2 = is + icode * 35 - 36) < 700 && 0 <= 
			i__2 ? i__2 : s_rnge("bitdens", i__2, "frinp_", 167L)]
			 = bitden;
/*         Store the track assignments. */
		for (i = 1; i <= 36; ++i) {
		    for (ix = 1; ix <= 1; ++ix) {
			if (itrk[(i__2 = (i + ix * 36 << 2) - 148) < 144 && 0 
				<= i__2 ? i__2 : s_rnge("itrk", i__2, "frinp_"
				, 171L)] != -99) {
			    freqs_1.itras[(i__3 = ((ix + (icx + (i + (is + 
				    icode * 35) * 36 << 4)) << 1) + 1 << 1) - 
				    83018) < 1612800 && 0 <= i__3 ? i__3 : 
				    s_rnge("itras", i__3, "frinp_", 171L)] = 
				    itrk[(i__4 = (i + ix * 36 << 2) - 148) < 
				    144 && 0 <= i__4 ? i__4 : s_rnge("itrk", 
				    i__4, "frinp_", 171L)];
			}
			if (itrk[(i__2 = (i + ix * 36 << 2) - 147) < 144 && 0 
				<= i__2 ? i__2 : s_rnge("itrk", i__2, "frinp_"
				, 173L)] != -99) {
			    freqs_1.itras[(i__3 = ((ix + (icx + (i + (is + 
				    icode * 35) * 36 << 4)) << 1) + 1 << 1) - 
				    83017) < 1612800 && 0 <= i__3 ? i__3 : 
				    s_rnge("itras", i__3, "frinp_", 173L)] = 
				    itrk[(i__4 = (i + ix * 36 << 2) - 147) < 
				    144 && 0 <= i__4 ? i__4 : s_rnge("itrk", 
				    i__4, "frinp_", 173L)];
			}
			if (itrk[(i__2 = (i + ix * 36 << 2) - 146) < 144 && 0 
				<= i__2 ? i__2 : s_rnge("itrk", i__2, "frinp_"
				, 175L)] != -99) {
			    freqs_1.itras[(i__3 = ((ix + (icx + (i + (is + 
				    icode * 35) * 36 << 4)) << 1) + 2 << 1) - 
				    83018) < 1612800 && 0 <= i__3 ? i__3 : 
				    s_rnge("itras", i__3, "frinp_", 175L)] = 
				    itrk[(i__4 = (i + ix * 36 << 2) - 146) < 
				    144 && 0 <= i__4 ? i__4 : s_rnge("itrk", 
				    i__4, "frinp_", 175L)];
			}
			if (itrk[(i__2 = (i + ix * 36 << 2) - 145) < 144 && 0 
				<= i__2 ? i__2 : s_rnge("itrk", i__2, "frinp_"
				, 177L)] != -99) {
			    freqs_1.itras[(i__3 = ((ix + (icx + (i + (is + 
				    icode * 35) * 36 << 4)) << 1) + 2 << 1) - 
				    83017) < 1612800 && 0 <= i__3 ? i__3 : 
				    s_rnge("itras", i__3, "frinp_", 177L)] = 
				    itrk[(i__4 = (i + ix * 36 << 2) - 145) < 
				    144 && 0 <= i__4 ? i__4 : s_rnge("itrk", 
				    i__4, "frinp_", 177L)];
			}
		    }
		}
		s_copy(freqs_ch__1.cset + ((i__2 = icx + (is + icode * 35 << 
			4) - 577) < 11200 && 0 <= i__2 ? i__2 : s_rnge("cset",
			 i__2, "frinp_", 181L)) * 3, cs, 3L, 3L);
		if (ivc == 0) {
		    freqs_1.ibbcx[(i__2 = icx + (is + icode * 35 << 4) - 577) 
			    < 11200 && 0 <= i__2 ? i__2 : s_rnge("ibbcx", 
			    i__2, "frinp_", 183L)] = icx;
		} else {
		    freqs_1.ibbcx[(i__2 = icx + (is + icode * 35 << 4) - 577) 
			    < 11200 && 0 <= i__2 ? i__2 : s_rnge("ibbcx", 
			    i__2, "frinp_", 185L)] = ivc;
/* BBC number */
		}
	    }
/* valid station */
	}
/* each station on "F" line */
    }


/*     3. Next, LO type entries, from the "L" lines. */

/* code entry */
    if (itype == 2) {
/* LO entry */
	if (igtst_(&lid, &istn) == 0) {
/* error */
	    io___36.ciunit = *lu;
	    s_wsfe(&io___36);
	    do_fio(&c__1, (char *)&lid, (ftnlen)sizeof(shortint));
	    i__1 = *ilen;
	    for (i = 2; i <= i__1; ++i) {
		do_fio(&c__1, (char *)&ibuf[i - 1], (ftnlen)sizeof(shortint));
	    }
	    e_wsfe();
	    *ierr = 35;
	    return 0;
	}

/* error */
	if (nvlist != 0) {
/* physical BBC info present */
	    if (nvlist == 1) {
/* one BBC on this line */
		i__2 = freqs_1.nchan[(i__1 = istn + icode * 35 - 36) < 700 && 
			0 <= i__1 ? i__1 : s_rnge("nchan", i__1, "frinp_", 
			205L)];
		for (iv = 1; iv <= i__2; ++iv) {
/* check all frequency channels */
		    ic = freqs_1.invcx[(i__1 = iv + (istn + icode * 35 << 4) 
			    - 577) < 11200 && 0 <= i__1 ? i__1 : s_rnge("inv"
			    "cx", i__1, "frinp_", 206L)];
/* channel index from "C" line */
		    ib = freqs_1.ibbcx[(i__1 = ic + (istn + icode * 35 << 4) 
			    - 577) < 11200 && 0 <= i__1 ? i__1 : s_rnge("ibb"
			    "cx", i__1, "frinp_", 207L)];
/* BBC index from "C" line */
		    if (ib > 0 && ib == ivlist[0]) {
/*                                    ! this channel o
n this BBC */
			if (lsg != freqs_1.lsubvc[(i__1 = ic + (istn + icode *
				 35 << 4) - 577) < 11200 && 0 <= i__1 ? i__1 :
				 s_rnge("lsubvc", i__1, "frinp_", 210L)]) {
			    io___40.ciunit = *lu;
			    s_wsfe(&io___40);
			    do_fio(&c__1, (char *)&lsg, (ftnlen)sizeof(
				    shortint));
			    do_fio(&c__1, (char *)&freqs_1.lsubvc[(i__3 = ic 
				    + (istn + icode * 35 << 4) - 577) < 11200 
				    && 0 <= i__3 ? i__3 : s_rnge("lsubvc", 
				    i__3, "frinp_", 210L)], (ftnlen)sizeof(
				    shortint));
			    do_fio(&c__1, (char *)&ic, (ftnlen)sizeof(integer)
				    );
			    for (i = 1; i <= 4; ++i) {
				do_fio(&c__1, (char *)&statn_1.lstnna[(i__4 = 
					i + (istn << 2) - 5) < 140 && 0 <= 
					i__4 ? i__4 : s_rnge("lstnna", i__4, 
					"frinp_", 210L)], (ftnlen)sizeof(
					shortint));
			    }
			    e_wsfe();
			}
			if (lc != freqs_1.lcode[(i__1 = icode - 1) < 20 && 0 
				<= i__1 ? i__1 : s_rnge("lcode", i__1, "frin"
				"p_", 214L)]) {
			    io___41.ciunit = *lu;
			    s_wsfe(&io___41);
			    do_fio(&c__1, (char *)&lc, (ftnlen)sizeof(
				    shortint));
			    do_fio(&c__1, (char *)&freqs_1.lcode[(i__3 = 
				    icode - 1) < 20 && 0 <= i__3 ? i__3 : 
				    s_rnge("lcode", i__3, "frinp_", 214L)], (
				    ftnlen)sizeof(shortint));
			    do_fio(&c__1, (char *)&ic, (ftnlen)sizeof(integer)
				    );
			    for (i = 1; i <= 4; ++i) {
				do_fio(&c__1, (char *)&statn_1.lstnna[(i__4 = 
					i + (istn << 2) - 5) < 140 && 0 <= 
					i__4 ? i__4 : s_rnge("lstnna", i__4, 
					"frinp_", 214L)], (ftnlen)sizeof(
					shortint));
			    }
			    e_wsfe();
			}
			freqs_1.lifinp[(i__1 = ic + (istn + icode * 35 << 4) 
				- 577) < 11200 && 0 <= i__1 ? i__1 : s_rnge(
				"lifinp", i__1, "frinp_", 218L)] = lin;
/* IF input channel */
			freqs_1.freqlo[(i__1 = ic + (istn + icode * 35 << 4) 
				- 577) < 11200 && 0 <= i__1 ? i__1 : s_rnge(
				"freqlo", i__1, "frinp_", 219L)] = f;
/* LO freq */
			freqs_1.losb[(i__1 = ic + (istn + icode * 35 << 4) - 
				577) < 11200 && 0 <= i__1 ? i__1 : s_rnge(
				"losb", i__1, "frinp_", 220L)] = ls;
/* sideband */
		    }
		}
	    } else {
/* many BBCs on this line (from PC-SCHED) */
		i__2 = nvlist;
		for (iv = 1; iv <= i__2; ++iv) {
		    ic = ivlist[(i__1 = iv - 1) < 16 && 0 <= i__1 ? i__1 : 
			    s_rnge("ivlist", i__1, "frinp_", 225L)];
		    if (lsg != freqs_1.lsubvc[(i__1 = ic + (istn + icode * 35 
			    << 4) - 577) < 11200 && 0 <= i__1 ? i__1 : s_rnge(
			    "lsubvc", i__1, "frinp_", 226L)]) {
			io___42.ciunit = *lu;
			s_wsfe(&io___42);
			do_fio(&c__1, (char *)&lsg, (ftnlen)sizeof(shortint));
			do_fio(&c__1, (char *)&freqs_1.lsubvc[(i__3 = ic + (
				istn + icode * 35 << 4) - 577) < 11200 && 0 <=
				 i__3 ? i__3 : s_rnge("lsubvc", i__3, "frinp_"
				, 226L)], (ftnlen)sizeof(shortint));
			do_fio(&c__1, (char *)&ic, (ftnlen)sizeof(integer));
			for (i = 1; i <= 4; ++i) {
			    do_fio(&c__1, (char *)&statn_1.lstnna[(i__4 = i + 
				    (istn << 2) - 5) < 140 && 0 <= i__4 ? 
				    i__4 : s_rnge("lstnna", i__4, "frinp_", 
				    226L)], (ftnlen)sizeof(shortint));
			}
			e_wsfe();
		    }
		    if (lc != freqs_1.lcode[(i__1 = icode - 1) < 20 && 0 <= 
			    i__1 ? i__1 : s_rnge("lcode", i__1, "frinp_", 
			    230L)]) {
			io___43.ciunit = *lu;
			s_wsfe(&io___43);
			do_fio(&c__1, (char *)&lc, (ftnlen)sizeof(shortint));
			do_fio(&c__1, (char *)&freqs_1.lcode[(i__3 = icode - 
				1) < 20 && 0 <= i__3 ? i__3 : s_rnge("lcode", 
				i__3, "frinp_", 230L)], (ftnlen)sizeof(
				shortint));
			do_fio(&c__1, (char *)&ic, (ftnlen)sizeof(integer));
			for (i = 1; i <= 4; ++i) {
			    do_fio(&c__1, (char *)&statn_1.lstnna[(i__4 = i + 
				    (istn << 2) - 5) < 140 && 0 <= i__4 ? 
				    i__4 : s_rnge("lstnna", i__4, "frinp_", 
				    230L)], (ftnlen)sizeof(shortint));
			}
			e_wsfe();
		    }
		    freqs_1.lifinp[(i__1 = ic + (istn + icode * 35 << 4) - 
			    577) < 11200 && 0 <= i__1 ? i__1 : s_rnge("lifinp"
			    , i__1, "frinp_", 234L)] = lin;
/* IF input channel */
		    freqs_1.freqlo[(i__1 = ic + (istn + icode * 35 << 4) - 
			    577) < 11200 && 0 <= i__1 ? i__1 : s_rnge("freqlo"
			    , i__1, "frinp_", 235L)] = f;
/* LO freq */
		    freqs_1.losb[(i__1 = ic + (istn + icode * 35 << 4) - 577) 
			    < 11200 && 0 <= i__1 ? i__1 : s_rnge("losb", i__1,
			     "frinp_", 236L)] = ls;
/* sideband */
		}
	    }
/* one/many */
	} else {
/* fill physical BBC/IF/LO info assuming all channels get sa */
	    i__1 = freqs_1.nchan[(i__2 = istn + icode * 35 - 36) < 700 && 0 <=
		     i__2 ? i__2 : s_rnge("nchan", i__2, "frinp_", 240L)];
	    for (i = 1; i <= i__1; ++i) {
		iv = freqs_1.invcx[(i__2 = i + (istn + icode * 35 << 4) - 577)
			 < 11200 && 0 <= i__2 ? i__2 : s_rnge("invcx", i__2, 
			"frinp_", 241L)];
/* channel index assumed same as BBC# */
		if (lsg == freqs_1.lsubvc[(i__2 = iv + (istn + icode * 35 << 
			4) - 577) < 11200 && 0 <= i__2 ? i__2 : s_rnge("lsub"
			"vc", i__2, "frinp_", 242L)]) {
/* match sub-group */
		    if (ichcm_ch__(&freqs_1.lifinp[(i__2 = iv + (istn + icode 
			    * 35 << 4) - 577) < 11200 && 0 <= i__2 ? i__2 : 
			    s_rnge("lifinp", i__2, "frinp_", 243L)], &c__1, 
			    "  ", 2L) == 0) {
/* fi */
			freqs_1.lifinp[(i__2 = iv + (istn + icode * 35 << 4) 
				- 577) < 11200 && 0 <= i__2 ? i__2 : s_rnge(
				"lifinp", i__2, "frinp_", 244L)] = lin;
			freqs_1.freqlo[(i__2 = iv + (istn + icode * 35 << 4) 
				- 577) < 11200 && 0 <= i__2 ? i__2 : s_rnge(
				"freqlo", i__2, "frinp_", 245L)] = f;
			char2hol_("U ", &freqs_1.losb[(i__2 = iv + (istn + 
				icode * 35 << 4) - 577) < 11200 && 0 <= i__2 ?
				 i__2 : s_rnge("losb", i__2, "frinp_", 246L)],
				 &c__1, &c__2, 2L);
		    } else {
/* had a previous LO already */
			rbbc = (d__1 = freqs_1.freqlo[(i__2 = iv + (istn + 
				icode * 35 << 4) - 577) < 11200 && 0 <= i__2 ?
				 i__2 : s_rnge("freqlo", i__2, "frinp_", 248L)
				] - freqs_1.freqrf[(i__3 = i + (istn + icode *
				 35 << 4) - 577) < 11200 && 0 <= i__3 ? i__3 :
				 s_rnge("freqrf", i__3, "frinp_", 248L)], abs(
				d__1));
			kmk3 = ichcm_ch__(&freqs_1.lifinp[(i__2 = iv + (istn 
				+ icode * 35 << 4) - 577) < 11200 && 0 <= 
				i__2 ? i__2 : s_rnge("lifinp", i__2, "frinp_",
				 249L)], &c__1, "1N", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__3 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__3 ? i__3 : 
				s_rnge("lifinp", i__3, "frinp_", 249L)], &
				c__1, "2N", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__4 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__4 ? i__4 : 
				s_rnge("lifinp", i__4, "frinp_", 249L)], &
				c__1, "3N", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__5 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__5 ? i__5 : 
				s_rnge("lifinp", i__5, "frinp_", 249L)], &
				c__1, "1A", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__6 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__6 ? i__6 : 
				s_rnge("lifinp", i__6, "frinp_", 249L)], &
				c__1, "2A", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__7 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__7 ? i__7 : 
				s_rnge("lifinp", i__7, "frinp_", 249L)], &
				c__1, "3O", 2L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__8 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__8 ? i__8 : 
				s_rnge("lifinp", i__8, "frinp_", 249L)], &
				c__1, "3I", 2L) == 0;
			kvlba = ichcm_ch__(&freqs_1.lifinp[(i__2 = iv + (istn 
				+ icode * 35 << 4) - 577) < 11200 && 0 <= 
				i__2 ? i__2 : s_rnge("lifinp", i__2, "frinp_",
				 256L)], &c__1, "A", 1L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__3 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__3 ? i__3 : 
				s_rnge("lifinp", i__3, "frinp_", 256L)], &
				c__1, "B", 1L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__4 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__4 ? i__4 : 
				s_rnge("lifinp", i__4, "frinp_", 256L)], &
				c__1, "C", 1L) == 0 || ichcm_ch__(&
				freqs_1.lifinp[(i__5 = iv + (istn + icode * 
				35 << 4) - 577) < 11200 && 0 <= i__5 ? i__5 : 
				s_rnge("lifinp", i__5, "frinp_", 256L)], &
				c__1, "D", 1L) == 0;
			if (rbbc > 1e3f && kvlba || rbbc > 500.f && kmk3) {
			    freqs_1.lifinp[(i__2 = iv + (istn + icode * 35 << 
				    4) - 577) < 11200 && 0 <= i__2 ? i__2 : 
				    s_rnge("lifinp", i__2, "frinp_", 262L)] = 
				    lin;
			    freqs_1.freqlo[(i__2 = iv + (istn + icode * 35 << 
				    4) - 577) < 11200 && 0 <= i__2 ? i__2 : 
				    s_rnge("freqlo", i__2, "frinp_", 263L)] = 
				    f;
			}
		    }
/* previous LO/first time */
		}
/* match sub-group */
	    }
	}
    }


/*     4. This is the name type entry section. */
/*        Index for icode has already been found above. */

/* LO entry */
    if (itype == 3) {
/*       Check the list of station names. */
/* name entry */
	ibad = 0;
	if (ns > 0) {
/* station names on "F" line */
	    i__1 = ns;
	    for (is = 1; is <= i__1; ++is) {
/* for each station name found on the line */
		i = 1;
		while(i <= statn_1.nstatn && ! knaeq_(&lst[(i__2 = (is << 2) 
			- 4) < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", i__2, 
			"frinp_", 281L)], &statn_1.lstnna[(i__3 = (i << 2) - 
			4) < 140 && 0 <= i__3 ? i__3 : s_rnge("lstnna", i__3, 
			"frinp_", 281L)], &c__4)) {
		    ++i;
		}
		if (i > statn_1.nstatn) {
/* no match */
		    io___48.ciunit = *lu;
		    s_wsfe(&io___48);
		    for (ii = 1; ii <= 4; ++ii) {
			do_fio(&c__1, (char *)&lst[(i__2 = ii + (is << 2) - 5)
				 < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", 
				i__2, "frinp_", 286L)], (ftnlen)sizeof(
				shortint));
		    }
		    e_wsfe();
		    freqs_1.istsav[(i__2 = is - 1) < 35 && 0 <= i__2 ? i__2 : 
			    s_rnge("istsav", i__2, "frinp_", 289L)] = -1;
		} else {
		    freqs_1.istsav[(i__2 = is - 1) < 35 && 0 <= i__2 ? i__2 : 
			    s_rnge("istsav", i__2, "frinp_", 291L)] = i;
/*            idum= ICHMV(LNAFRsub(1,i,ICODE),1,lsub,1,8) 
*/
/* save the station index */
		}
	    }
	    freqs_1.nstsav = ns;

	} else {
/* no stations listed, assume all */
	    freqs_1.nstsav = statn_1.nstatn;
	    i__1 = statn_1.nstatn;
	    for (i = 1; i <= i__1; ++i) {
		freqs_1.istsav[(i__2 = i - 1) < 35 && 0 <= i__2 ? i__2 : 
			s_rnge("istsav", i__2, "frinp_", 299L)] = i;
/*           idum= ICHMV(LNAFRsub(1,i,ICODE),1,lsub,1,8) */
/* save the station index */
	    }
	}
	idum = ichmv_(&freqs_1.lnafrq[(i__1 = (icode << 2) - 4) < 80 && 0 <= 
		i__1 ? i__1 : s_rnge("lnafrq", i__1, "frinp_", 303L)], &c__1, 
		lna, &c__1, &c__8);
	freqs_1.lcode[(i__1 = icode - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge(
		"lcode", i__1, "frinp_", 304L)] = lc;
    }

/* 5. This is the sample rate line. */
/* name entry */
    if (itype == 4) {
/* sample rate */
	freqs_1.samprate[(i__1 = icode - 1) < 20 && 0 <= i__1 ? i__1 : s_rnge(
		"samprate", i__1, "frinp_", 310L)] = srate;
    }
/* 6. This section for the barrel roll line. */
/* sample rate */
    if (itype == 5) {
/* barrel */
	if (ns > 0) {
/* station names on "B" line */
	    i__1 = ns;
	    for (is = 1; is <= i__1; ++is) {
/* for each station name found on the line */
		i = 1;
		while(i <= statn_1.nstatn && ! knaeq_(&lst[(i__2 = (is << 2) 
			- 4) < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", i__2, 
			"frinp_", 319L)], &statn_1.lstnna[(i__3 = (i << 2) - 
			4) < 140 && 0 <= i__3 ? i__3 : s_rnge("lstnna", i__3, 
			"frinp_", 319L)], &c__4)) {
		    ++i;
		}
		if (i > statn_1.nstatn) {
/* no match */
		    io___50.ciunit = *lu;
		    s_wsfe(&io___50);
		    for (ii = 1; ii <= 4; ++ii) {
			do_fio(&c__1, (char *)&lst[(i__2 = ii + (is << 2) - 5)
				 < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", 
				i__2, "frinp_", 324L)], (ftnlen)sizeof(
				shortint));
		    }
		    e_wsfe();
		} else {
/* save it */
		    idum = ichmv_(&freqs_1.lbarrel[(i__2 = (i + icode * 35 << 
			    1) - 72) < 1400 && 0 <= i__2 ? i__2 : s_rnge(
			    "lbarrel", i__2, "frinp_", 328L)], &c__1, &lbar[(
			    i__3 = (is << 1) - 2) < 70 && 0 <= i__3 ? i__3 : 
			    s_rnge("lbar", i__3, "frinp_", 328L)], &c__1, &
			    c__4);
		}
	    }
	}
    }
/* 7. This section for the recording format line. */
    if (itype == 6) {
/* format */
	if (ns > 0) {
/* station names on the line */
	    i__1 = ns;
	    for (is = 1; is <= i__1; ++is) {
/* for each station name found on the line */
		i = 1;
		while(i <= statn_1.nstatn && ! knaeq_(&lst[(i__2 = (is << 2) 
			- 4) < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", i__2, 
			"frinp_", 340L)], &statn_1.lstnna[(i__3 = (i << 2) - 
			4) < 140 && 0 <= i__3 ? i__3 : s_rnge("lstnna", i__3, 
			"frinp_", 340L)], &c__4)) {
		    ++i;
		}
		if (i > statn_1.nstatn) {
/* no match */
		    io___51.ciunit = *lu;
		    s_wsfe(&io___51);
		    for (ii = 1; ii <= 4; ++ii) {
			do_fio(&c__1, (char *)&lst[(i__2 = ii + (is << 2) - 5)
				 < 140 && 0 <= i__2 ? i__2 : s_rnge("lst", 
				i__2, "frinp_", 345L)], (ftnlen)sizeof(
				shortint));
		    }
		    e_wsfe();
		} else {
/* save it */
		    if (ichcm_ch__(&lfmt[(i__2 = (is << 1) - 2) < 70 && 0 <= 
			    i__2 ? i__2 : s_rnge("lfmt", i__2, "frinp_", 349L)
			    ], &c__1, "N", 1L) == 0) {
/* force non-data */
			idum = ichmv_ch__(&freqs_1.lmfmt[(i__2 = (i + icode * 
				35 << 2) - 144) < 2800 && 0 <= i__2 ? i__2 : 
				s_rnge("lmfmt", i__2, "frinp_", 350L)], &c__1,
				 "M", 1L);
/* recording form */
		    }
		}
/*       RESet bit density depending on the recording format. 
*/
/*       Check once more on the bit density but this time use 
LMFMT. */
		if (ichcm_ch__(&freqs_1.lmfmt[(i__2 = (i + icode * 35 << 2) - 
			144) < 2800 && 0 <= i__2 ? i__2 : s_rnge("lmfmt", 
			i__2, "frinp_", 355L)], &c__1, "V", 1L) == 0) {
		    bitden = 34020.;
/* VLBA non-data replacement */
		} else {
		    bitden = 33333.;
/* Mark3/4 data replacement */
		}
/*           If "56000" was specified, use higher station bit 
density */
		if (statn_1.ibitden_save__[(i__2 = i - 1) < 35 && 0 <= i__2 ? 
			i__2 : s_rnge("ibitden_save", i__2, "frinp_", 361L)] 
			== 56000) {
		    if (ichcm_ch__(&freqs_1.lmfmt[(i__2 = (i + icode * 35 << 
			    2) - 144) < 2800 && 0 <= i__2 ? i__2 : s_rnge(
			    "lmfmt", i__2, "frinp_", 362L)], &c__1, "V", 1L) 
			    == 0) {
			bitden = 56700.;
/* VLBA non-data replacement */
		    } else {
			bitden = 56250.;
/* Mark3/4 data replacement */
		    }
		}
/*           Store the bit density by station */
		freqs_1.bitdens[(i__2 = i + icode * 35 - 36) < 700 && 0 <= 
			i__2 ? i__2 : s_rnge("bitdens", i__2, "frinp_", 369L)]
			 = bitden;
	    }
/* each station name on the line */
	}
    }
/* recording format line */
    *ierr = 0;
    inum = 0;

    return 0;
} /* frinp_ */

