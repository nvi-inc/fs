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
#include <stdio.h>
#include <string.h>

#ifdef CONFIG_GPIB
#ifdef NI_DRIVER
#include <sys/ugpib.h>
#else
#ifdef REV_3
#include <gpib/ib.h>
#else
#include <ib.h>
#include <ibP.h>
#endif
#endif
#else
int ibsta;
int iberr;
int ibcnt;
#endif

#define BSIZE    256

int ibser;
#include "sib.h"

int sib(int hpib, char *buffer, int len_in, int max_out, int timeout,
	int itime, int centisec[2])
{

  int lf=0x0a;
  int m1=-1,term;
  int len, ierr, icount, lenr;
  char locbuf[BSIZE];
  int p100=100;
  int tim;

  ierr = portflush_(&hpib);
  if (ierr<0)
    return -1;

  if(len_in <0)
    len=strlen(buffer);
  else
    len=len_in;

  if(len>0) {
    if(itime) {
      rte_ticks(centisec);
    }
    ierr = portwrite_(&hpib,buffer,&len);
    if(itime) {
      rte_ticks(centisec+1);
    }
    if(ierr<0)
      return -2;
  }

/* get data read from device */

  if(max_out!=0) {
    if(max_out >0 ) {
      len=max_out;
      term=-1;
    } else {
      len=-max_out;
      term=lf;
    }
    tim=timeout+30;
    ierr = portread_(&hpib,buffer,&lenr,&len,&term,&tim);

    if(ierr<0)
      return -2+ierr;

    if(max_out>0) {

      /* count */
      
      len=BSIZE-1;
      ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
      if(ierr<0)
	return -2+ierr;
    }
  }

  if(max_out >=0) {
    /* status */

    len=BSIZE-1;
    tim=timeout+30;
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&tim);
    if(ierr<0)
      return -2+ierr;

    locbuf[lenr]='\0';
    icount=sscanf(locbuf,"%d\r",&ibsta);
    if(icount !=1)
      return -6;

    /* IB error */

    len=BSIZE-1;
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
    if(ierr<0)
      return -2+ierr;

    locbuf[lenr]='\0';
    icount=sscanf(locbuf,"%d\r",&iberr);
    if(icount !=1)
      return -7;

    /* serial error */
    
    len=BSIZE-1;
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
    if(ierr<0)
      return -2+ierr;

    locbuf[lenr]='\0';
    icount=sscanf(locbuf,"%d\r",&ibser);
    if(icount !=1)
      return -8;

    /* count */

    len=BSIZE-1;
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
    if(ierr<0)
      return -2+ierr;

    locbuf[lenr]='\0';
    icount=sscanf(locbuf,"%d\r",&ibcnt);
    if(icount !=1)
      return -9;

  }

  return 0;
}
