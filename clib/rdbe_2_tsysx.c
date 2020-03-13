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
/* rdbe dbe_tsys parsing util */

#include <stdio.h>
#include <string.h>

#include "../include/params.h"

int rdbe_2_tsysx(char *buf, int *ifc, int ip[5], int on[],int off[], char *who)
{
  char *ptr;
  int value;
  int i, ierr;

  ptr=strtok(buf,"?");
  if(NULL==ptr) {
    ierr=-501;
    goto error;
  }

  for(i=0;i<2;i++) {  /* parse return code and channel */
    ptr=strtok(NULL,":");
    if(1!=sscanf(ptr,"%d",&value)) {
      ierr=-501;
      goto error;
    }
    switch (i) {
    case 0:
      if(value!=0) {
	ierr=-502;
	goto error;
      }
      break;
    case 1:
      *ifc=value;
      break;
    default:
      ierr=-503;
      goto error;
      break;
    }
  }

  for(i=0;i<2*MAX_RDBE_CH;i++) { /*parse values: on, then off */
    ptr=strtok(NULL,":;");
    if(ptr==NULL) {
	ierr=-504;
	goto error;
    }

    if(1!=sscanf(ptr,"%d",&value)) {
      ierr=-501;
      goto error;
    }
    
    if(i<MAX_RDBE_CH)   /* diode on */
      on[i]=value;
    else          /* diode off */
      off[i-MAX_RDBE_CH]=value;
  }
  return 0;

 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2t",2);
  memcpy(ip+4,who,2);
  return -1;

}
