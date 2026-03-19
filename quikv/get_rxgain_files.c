/*
 * Copyright (c) 2026 NVI, Inc.
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
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int get_rxgain();

void get_rxgain_files(ierr,rxgain,rxgain_files)
int *ierr;
struct rxgain_ds *rxgain;
struct rxgain_files_ds *rxgain_files;
{
  char outbuf[513],logbuf[513];
  int freq, icount;
  int dirlen;
  FILE *idum;

  strcpy(outbuf,"ls ");
  dirlen=strlen(outbuf);
  strcat(outbuf,FS_ROOT);
  strcat(outbuf,"/control/rxg_files/");
  dirlen=strlen(outbuf)-dirlen;
  strcat(outbuf,"*.rxg");

  strcat(outbuf," > /tmp/LS.NUM 2> /dev/null");

  freq = system(outbuf);
  /*  printf(" freq %d outbuf %s\n",freq,outbuf); */
  idum=fopen("/tmp/LS.NUM","r");
  unlink("/tmp/LS.NUM");

  icount=-1;
  while(-1!=fscanf(idum,"%s",outbuf)){
    if(++icount < MAX_RXGAIN)
      *ierr=get_rxgain(outbuf,rxgain+icount);
    else
      *ierr=-22;
    if(*ierr==0) {
        if(strlen(outbuf)-dirlen<-1+sizeof(((struct rxgain_files_ds *) 0)->file)) {
            strcpy(rxgain_files[icount].file,outbuf+dirlen);
            rxgain_files[icount].logged=FALSE;
        } else
            *ierr=-21;
    }
    if(*ierr!=0) {
      if(*ierr != -22) {
        int len=sizeof(outbuf);
        while(--len>=0 && ' '==outbuf[len])
            outbuf[len]=0;
        snprintf(logbuf,sizeof(logbuf),"Failing rxg file: '%s'",outbuf);
        logite(logbuf,-20,"rg");
      }
      if(*ierr%100>=-3 || *ierr==-12 || *ierr==-11)
         logit(NULL,errno,"un");
      return;
    }

    /* test code
    printf(" file %s\n",outbuf);
    printf(" rxg icount %d name '%s'\n",icount,
            shm_addr->rxgain_files[icount].file);
    printf(" gain curve: ncoeff  %d\n", shm_addr->rxgain[icount].gain.ncoeff);
    printf(" gain curve: opacity corrected %c\n",
	   shm_addr->rxgain[icount].gain.opacity);
    for (i=0;i<shm_addr->rxgain[icount].gain.ncoeff;i++)
      printf(" %f ",shm_addr->rxgain[icount].gain.coeff[i]);
    printf(" \n");
    printf(" tcal table: ntable %d\n", shm_addr->rxgain[icount].tcal_ntable);
    for (i=0;i<shm_addr->rxgain[icount].tcal_ntable;i++)
      printf(" %c %f %f\n ",
	     shm_addr->rxgain[icount].tcal[i].pol,
	     shm_addr->rxgain[icount].tcal[i].freq,
	     shm_addr->rxgain[icount].tcal[i].tcal);
    printf(" trec %f\n",shm_addr->rxgain[icount].trec);
    printf(" spill table: ntable %d\n", shm_addr->rxgain[icount].spill_ntable);
    for (i=0;i<shm_addr->rxgain[icount].spill_ntable;i++)
      printf("%f %f\n ",
	     shm_addr->rxgain[icount].spill[i].el,
	     shm_addr->rxgain[icount].spill[i].tk);

    printf(" \n");
    *ierr=-999;
    return;
*/
  }
  *ierr=0;
  return;

}
