/* f2ctmp_drudg.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Main program */ MAIN__(void)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    integer s_rnge(char *, integer, char *, integer);
    /* Subroutine */ int s_copy(char *, char *, ftnlen, ftnlen);

    /* Local variables */
    static integer i;
    static char arg[256*7];
    extern integer iargc_(void);
    extern /* Subroutine */ int getarg_(integer *, char *, ftnlen), fdrudg_(
	    char *, char *, char *, char *, char *, char *, char *, ftnlen, 
	    ftnlen, ftnlen, ftnlen, ftnlen, ftnlen, ftnlen);



    for (i = 1; i <= 7; ++i) {
	if (i > iargc_()) {
	    s_copy(arg + (((i__1 = i - 1) < 7 && 0 <= i__1 ? i__1 : s_rnge(
		    "arg", i__1, "drudg_", 11L)) << 8), " ", 256L, 1L);
	} else {
	    getarg_(&i, arg + (((i__1 = i - 1) < 7 && 0 <= i__1 ? i__1 : 
		    s_rnge("arg", i__1, "drudg_", 13L)) << 8), 256L);
	}
    }
    fdrudg_(arg, arg + 256, arg + 512, arg + 768, arg + 1024, arg + 1280, arg 
	    + 1536, 256L, 256L, 256L, 256L, 256L, 256L, 256L);

    return 0;
} /* MAIN__ */

/* Main program alias */ int drudg_ () { MAIN__ (); return 0; }
