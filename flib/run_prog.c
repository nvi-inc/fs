/* f2ctmp_run_prog.f -- translated by f2c (version 19940714).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Subroutine */ int run_prog__(char *name, char *wait, integer *ip1, integer 
	*ip2, integer *ip3, integer *ip4, integer *ip5, ftnlen name_len, 
	ftnlen wait_len)
{
    static integer ip[5];
    extern /* Subroutine */ int fc_skd_run__(char *, char *, integer *, 
	    ftnlen, ftnlen);



    ip[0] = *ip1;
    ip[1] = *ip2;
    ip[2] = *ip3;
    ip[3] = *ip4;
    ip[4] = *ip5;
    fc_skd_run__(name, wait, ip, name_len, wait_len);

    return 0;
} /* run_prog__ */

