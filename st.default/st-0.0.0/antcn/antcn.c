/* antcn.c 
 *
 * This is the stub version of antcn (ANTenna CoNtrol program).
 * This version sends a log message whenever it is called.
 *
 * This file is part of the station example code
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the public
 * domain worldwide. This software is distributed without any warranty.

 * You should have received a copy of the CC0 Public Domain Dedication along
 * with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 *
 */

/* antcn should follow "no news is good news",
 * except mode 7, which is intended to provide more detail
 * on the antenna status. errors are reported in ip[2...4]
 * if an error occurs, it may may helpful to send messages
 * and/or additional errors with logit() before returning,
 * like:
 *          logit("Message to send",0,NULL);
 * and/or
 *          logit(NULL,ierr,"st");
 */

/* Input */
/* ip[0] = mode
             0 = initialize LU
             1 = pointing (from SOURCE command)
             2 = offset (from RADECOFF, AZELOFF, or XYOFF commands)
             3 = on/off source status (from ONSOURCE command)
             4 = direct communications (from ANTENNA command)
             5 = on/off source status for pointing programs
             6 = reserved for future focus control
             7 = log tracking data (from TRACK command)
             8 = Station detectors, see /usr2/fs/misc/stndet.txt
             9 = Satellite traking, see /usr2/fs/misc/satellites.txt
            10 = termination mode, must return promptly
       11 - 99 = reserved for future use
  100 - 32767 = for site specific use

  all modes aren't required; 0, 1, 2, 3, and 5 are a useful minimum

   ip[1] = class number (mode 4 only)
   ip[2] = number of records in class (mode 4 only)
   ip[3] - not used
   ip[4] - not used
*/

/* Output */
/*  ip[0] = class with returned message
      [1] = number of records in class
      [2] = error number
            0 - ok
           -1 - illegal or unimplemented mode
           -2 - timeout
           -3 - wrong number of characters in response
           -4 - interface not set to remote
           -5 - error return from antenna
           -6 - error in pointing model initialization
            others as defined locally
      [3] = "an" for above errors, found in fserr.ctl
          = "st" for site defined errors, found in sterr.ctl
      [4] = not used
*/

/* Defined variables */
#define MINMODE 0  /* min,max modes for our operation */
#define MAXMODE 10

/* Include files */

#include <stdio.h>
#include <string.h>

#include "../../fs/include/params.h" /* FS parameters            */
#include "../../fs/include/fs_types.h" /* FS header files        */
#include "../../fs/include/fscom.h"  /* FS shared mem. structure */
#include "../../fs/include/shm_addr.h" /* FS shared mem. pointer */

struct fscom *fs;

/* Subroutines called */
void setup_ids();
void putpname();
void skd_run(), cls_clr();
int nsem_test();
void logit();

/* antcn main program starts here */
main()
{
  int ierr, nrec, nrecr;
  int dum = 0;
  int r1, r2;
  int imode,i,nchar;
  int ip[5], class, clasr;
  char buf[80], buf2[100];

/* Set up IDs for shared memory, then assign the pointer to
   "fs", for readability.
*/
  setup_ids();
  fs = shm_addr;

/* Put our program name where logit can find it. */

  putpname("antcn");

/* Return to this point to wait until we are called again */

Continue:
  skd_wait("antcn",ip,(unsigned)0);

  imode = ip[0];
  class = ip[1];
  nrec = ip[2];

  nrecr = 0;
  clasr = 0;

  if (imode < MINMODE || imode > MAXMODE) {
    ierr = -1;
    goto End;
  }

/* Handle each mode in a separate section */

  switch (imode) {

    case 0:             /* initialize */
      ierr = 0;
      fs->ionsor = 0;
      break;

    case 1:             /* source= command */
      ierr = 0;
      fs->ionsor = 0;
      break;

    case 2:             /* offsets         */
      ierr = 0;
      fs->ionsor = 0;
      break;

    case 3:        /* onsource command with error message */
      ierr = 0;
      /* only set fs->ionsor to 1 if the antenna is at the position
       * specified by mode 1 and 2 information. Be careful of race conditions.
       * Only set the value to 1 if the antenna has reached the position
       * specified, not if it is still at the previous position specified.
       * Otherwise set it to 0, details on why the value is 0 can be provided
       * with logit(). Being off source is not an error in itself
       */
      fs->ionsor = 1;
      break;

    case 4:            /* direct antenna= command */
      if (class == 0)
        goto End;
      for (i=0; i<nrec; i++) {
        nchar = cls_rcv(class,buf,sizeof(buf),&r1,&r2,dum,dum);
        buf[nchar] = '\0';  /* make into a string */
        /* send buf to antenna, then report response */
        strcpy(buf,"response from antenna");
        cls_snd(&clasr,buf,3,dum,dum);
        nrecr += 1;
      }
      /* OR if not implenented:
         cls_clr(class);
         ierr -1
         */
      break;

    case 5:    /* onsource command with no error logging */
      ierr = 0;
      /* errors are returned through ip[2]
       *
       * for this mode, 5, no additional information on why off source should
       * be displayed
       *
       * see mode 3 for information on setting fs->ionsor
       */
      fs->ionsor = 1;
      break;

    case 6:            /* reserved */
      ierr = -1;
      goto End;
      break;

    case 7:    /* onsource command with additional info  */
      ierr = 0;
      /* this mode is to return additional detail on antenna tracking.
       * typically with logit() messages
       *
       * see mode 3 for information on setting fs->ionsor
       */
      fs->ionsor = 1;

  case 8: /* Station dependent detectors access" */
      ierr = 0;
      /* see /usr2/fs/misc/stndet.txt */
      break;

  case 9: /* satellite tracking mode */
      ierr = 0;
      /* see /usr2/fs/misc/satellites.txt */
      break;

  case 10:  /*normally triggered on FS termination if environment
	     variable FS_ANTCN_TERMINATION has been defined */
      ierr = 0;
      break;

  default: /* should not get here */
      ierr = -1;
      break;
  }  /* end of switch */

End:
  ip[0] = clasr;
  ip[1] = nrecr;
  ip[2] = ierr;
  memcpy(ip+3,"an",2);
  ip[4] = 0;
  goto Continue;

}
