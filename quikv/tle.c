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
/* tle snap command */

#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <errno.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int check_tle(char *ptr)
{
  int i,check;

  check=0;
  for (i=0;i<68;i++) {
    switch (ptr[i]) {
    case '9': check+=9; break;
    case '8': check+=8; break;
    case '7': check+=7; break;
    case '6': check+=6; break;
    case '5': check+=5; break;
    case '4': check+=4; break;
    case '3': check+=3; break;
    case '2': check+=2; break;
    case '1': check+=1; break;
    case '-': check+=1; break;
    default: break;
    }
  }
  return check%10;
}

void tle(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
  int i, ierr, ilast, iline, catnum, num, check;
  char *ptr, buf[120], *start;
  size_t sizebuf;

  char *arg_next();
  
  ierr=0;
  
  if (command->equal != '=' ||
      (command->argv[0] != NULL &&
       *command->argv[0] == '?' && command->argv[1] == NULL)) {

    /* display */

    for (i=0;i<5;i++) ip[i]=0;
    strcpy(buf,command->name);
    strcat(buf,"/");
    start=buf+strlen(buf);
    sizebuf=sizeof(buf)-strlen(buf)-1;

    snprintf(start,sizebuf,"0,%d,%s",
	     shm_addr->tle.catnum[0],shm_addr->tle.tle0);
    cls_snd(&ip[0],buf,strlen(buf),0,0);

    snprintf(start,sizebuf,"1,%d,%s",
	     shm_addr->tle.catnum[1],shm_addr->tle.tle1);
    cls_snd(&ip[0],buf,strlen(buf),0,0);

    snprintf(start,sizebuf,"2,%d,%s",
	     shm_addr->tle.catnum[2],shm_addr->tle.tle2);
    cls_snd(&ip[0],buf,strlen(buf),0,0);

    ip[1]=3;
    return;
  }
  
  /* if we get this far it is a set-up command so parse it */
  
 parse:
  ilast=0;                                      /* last argv examined */

  ptr=arg_next(command,&ilast);
  ierr=arg_int(ptr,&iline,1,FALSE);
  if(ierr!=0) {
    ierr=-101;
    goto error;
  } else if(iline < 0 || 2 < iline) {
    ierr=-201;
    goto error;
  }

  ptr=arg_next(command,&ilast);
  ierr=arg_int(ptr,&catnum,1,FALSE);
  if(ierr!=0) {
    ierr=-102;
    goto error;
  } else if(catnum <= 0) {
    ierr=-202;
    goto error;
  }

  ptr=arg_next(command,&ilast);
  if(ptr==NULL || *ptr==0) {
    ierr=-103;
    goto error;
  } else
    for(i=0;i<strlen(ptr);i++)
      ptr[i]=toupper(ptr[i]);
    switch (iline) {
    case 0:
      if(strlen(ptr)+1 >sizeof(shm_addr->tle.tle0))
	ierr=-203;
      else {
	strncpy(shm_addr->tle.tle0,ptr,sizeof(shm_addr->tle.tle0));
	shm_addr->tle.catnum[0]=catnum;
      }
      break;
    case 1:
      if(strlen(ptr)+1 >sizeof(shm_addr->tle.tle1))
	ierr=-213;
      else if(ptr[0]!='1')
	ierr=-313;
      else if(1!=sscanf(ptr+2,"%5d",&num))
	ierr=-413;
      else if(num!=catnum)
	ierr=-513;
      else if(1!=sscanf(ptr+68,"%1d",&check))
	ierr=-613;
      else if(check!=check_tle(ptr))
	ierr=-713;
      else {
	strncpy(shm_addr->tle.tle1,ptr,sizeof(shm_addr->tle.tle1));
	shm_addr->tle.catnum[1]=catnum;
      }
      break;
    case 2:
      if(strlen(ptr)+1 >sizeof(shm_addr->tle.tle2))
	ierr=-223;
      else if(ptr[0]!='2')
	ierr=-323;
      else if(1!=sscanf(ptr+2,"%5d",&num))
	ierr=-423;
      else if(num!=catnum)
	ierr=-523;
      else if(1!=sscanf(ptr+68,"%1d",&check))
	ierr=-623;
      else if(check!=check_tle(ptr))
	ierr=-723;
      else {
	strncpy(shm_addr->tle.tle2,ptr,sizeof(shm_addr->tle.tle2));
	shm_addr->tle.catnum[2]=catnum;
      }
      break;
    default:
      ierr=-301;
      break;
    }
  if(ierr !=0 ) goto error;

  /* all parameters parsed okay */

  
  ip[0]=ip[1]=ip[2]=0;
  
  return;
  
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"q4",2);
  return;
}
