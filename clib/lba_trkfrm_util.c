/*
 * Copyright (c) 2020 NVI, Inc.
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
/* lba_trkfrm_util.c lba das trackform parsing utilities */

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <string.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"

extern unsigned short track_mask;

int lba_trkfrm_dec(lcl,count,ptr)
struct das *lcl;
int *count;
char *ptr;
{
    int ierr, code, i, ifp, sb, b, fo;
    static int itrk;

    ierr=0;

    if(ptr == NULL) {
      if(*count%2 == 0)
	ierr = -100;
      *count=-1;
      return ierr;
    }

    switch (*count%2) {
    case 1:
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr == 0 && (itrk < 0 || itrk > 15))
	ierr = -200;
      if(ierr == 0 && (track_mask&(0x01<<itrk)) != 0)
	ierr = -201;
      break;
    case 0:
      code=bsfo2vars(ptr,&ifp,&sb,&b,&fo);
      if (ifp/2 >= shm_addr->n_das)
         ierr = -903;
      else {
        if (lcl[ifp/2].ifp[ifp%2].bandwidth == _32D00) fo=fo*2;
        if(code < -1)
          ierr=-299+code;
        else if (!lcl[ifp/2].ifp[ifp%2].initialised)
          ierr=-304;
        else if (lcl[ifp/2].ifp[ifp%2].bandwidth > _16D00 && sb != _USB)
          ierr=-305;
        else if (lcl[ifp/2].ifp[ifp%2].bandwidth > _32D00 && b != 0)
          ierr=-306;
        else if ((lcl[ifp/2].ifp[ifp%2].bandwidth < _32D00 && fo > 0) || fo > 3)
          ierr=-307;
        else if ((b+fo)%2 != itrk%2)
          ierr=-308;
        else if (((track_mask&(0x01<<(itrk%2?itrk-1:itrk+1))) ||
                  lcl[ifp/2].ifp[ifp%2].track[(2*sb+b+fo)/2] != -1) &&
                 lcl[ifp/2].ifp[ifp%2].track[(2*sb+b+fo)/2] != 2*(itrk/2))
          ierr=-309;
        else {
          lcl[ifp/2].ifp[ifp%2].track[(2*sb+b+fo)/2] = 2*(itrk/2);
          track_mask |= (0x01 << itrk);
        }
      }
      break;
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void lba_trkfrm_enc(output,count,lcl)
char *output;
int *count;
struct das *lcl;
{
    int itrk, ifp, sb;
    static int ilast;

    if(*count==1)
      ilast = -1;

    if (ilast >= 16) {
      *count= -1;
      return;
    }

    output=output+strlen(output);
    
    for (itrk=ilast+1;itrk<16;itrk++)
      if (track_mask&(0x01<<itrk)) for (ifp=0;ifp<2*shm_addr->n_das;ifp++)
        for (sb=0;sb<2;sb++)
          if (lcl[ifp/2].ifp[ifp%2].track[sb] == 2*(itrk/2)){
	    ilast=itrk;
	    sprintf(output,"%3d,%6s",itrk,vars2bsfo(lcl[ifp/2].ifp[ifp%2].bandwidth,ifp,sb,itrk%2));
	    goto done;
          }
    if(ilast==-1)
      strcpy(output,"disabled");

    *count=-1;
    return;

  done:
   if(*count>0)
     *count++;

   return;
}
