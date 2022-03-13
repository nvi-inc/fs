/*
 * Copyright (c) 2020, 2022 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* antcn.c
 *
 * This is the stub version of antcn (ANTenna CoNtrol program). This
 * version sends a log message whenever it is called. This is only for
 * a demonstration without an antenna, real antcn programs, in /usr2/st,
 * should follow "no news is good news". For more details see the
 * comments below and the example:
 * /usr2/fs/st.default/st-0.0.0/antcn/antcn.c
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
             9 = Satellite tracking, see /usr2/fs/misc/satellites.txt
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
      [1] = error number
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

#include "../include/params.h" /* FS parameters            */
#include "../include/fs_types.h" /* FS header files        */
#include "../include/fscom.h"  /* FS shared mem. structure */
#include "../include/shm_addr.h" /* FS shared mem. pointer */

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
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
      strcpy(buf,"stub antcn: Initializing antenna interface");
      logit(buf,0,NULL);
      fs->ionsor = 0;
      break;

    case 1:             /* source= command */
      ierr = 0;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
      strcpy(buf,"stub antcn: Commanding to a new source");
      logit(buf,0,NULL);
      fs->ionsor = 0;
      break;

    case 2:             /* offsets         */
      ierr = 0;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
      strcpy(buf,"stub antcn: Commanding new offsets");
      logit(buf,0,NULL);
      fs->ionsor = 0;
      break;

    case 3:        /* onsource command with error message */
      ierr = 0;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       *
       * If the antenna is off source, direct logging with logit() of
       * information about why may be useful. Being off source is not
       * an error in itself.
       */
      strcpy(buf,"stub antcn: Checking onsource status, extended error logging");
      logit(buf,0,NULL);
      fs->ionsor = 1;
      break;

    case 4:            /* direct antenna= command */
      if (class == 0)
        goto End;
      for (i=0; i<nrec; i++) {
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
        strcpy(buf2,"stub antcn: Received message for antenna: ");
        nchar = cls_rcv(class,buf,sizeof(buf),&r1,&r2,dum,dum);
        buf[nchar] = 0;  /* make into a string */
        strcat(buf2,buf);
        logit(buf2,0,NULL);
        strcpy(buf,"ACK");
        cls_snd(&clasr,buf,3,dum,dum);
        nrecr += 1;
      }
      /* OR:
         cls_clr(class);
         */
      break;

    case 5:    /* onsource command with no error logging */
      ierr = 0;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       *
       * This particular mode, 5, should not report errors about
       * why the antenna is off source, which modes 3 and 7 can do.
       * It can however report more information about other errors
       * like antenna communication, if the return error code is
       * not sufficient. Being off source is not an error by itself.
       */
      strcpy(buf,"stub antcn: Checking onsource status, no error logging");
      logit(buf,0,NULL);
      fs->ionsor = 1;
      break;

    case 6:            /* reserved */
      ierr = -1;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
      strcpy(buf,"stub antcn: TBD focus control");
      logit(buf,0,NULL);
      goto End;
      break;

    case 7:    /* onsource command with additional info  */
      ierr = 0;
      strcpy(buf,"stub antcn: Checking onsource status, log tracking data");
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       *
       * If the antenna is off source, direct logging with logit() of
       * information about why may be useful. Being off source is not
       * an error in itself.
       */
      logit(buf,0,NULL);
      fs->ionsor = 1;
      break;

  case 8:
      ierr = 0;
      strcpy(buf,"stub antcn: Station dependent detectors access");
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       *
       * see /usr2/fs/misc/stndet.txt
       */
      logit(buf,0,NULL);
      break;

  case 9:
      ierr = 0;
      strcpy(buf,"stub antcn: Satellite tracking mode");
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       *
       * see /usr2/fs/misc/satellites.txt
       */
      logit(buf,0,NULL);
      break;

  case 10: /*normally triggered on FS termination if environment variable
	     FS_ANTCN_TERMINATION has been defined */
      ierr = 0;
      /* real antcn programs should follow "no news is good news",
       * see the comments above in the header
       */
      strcpy(buf,"stub antcn: Termination mode");
      logit(buf,0,NULL);
      break;

  default: /* should not get here */
      ierr = -1;
      strcpy(buf,"stub antcn: should not get here");
      logit(buf,0,NULL);
      break;
  }  /* end of switch */

End:
  ip[0] = clasr;
  ip[1] = nrecr;
  ip[2] = ierr;
  memcpy(ip+3,"AN",2);
  ip[4] = 0;
  goto Continue;

}
