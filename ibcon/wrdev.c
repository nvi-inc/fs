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
/*
   It assumes you will use the configuration 'ibboard' for the 
   board. 

 */
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <errno.h>

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
extern int ibsta;
extern int iberr;
extern int ibcnt;
#endif

extern int ibser;
#include "sib.h"

#define LF		0x0A
#define	TIMEOUT		-4
#define	BUS_ERROR	-8
#define GEN_ERROR	-10
#define	IBCODE		300
#define	IBSCODE		400
#define ASCII		  0
#define BINARY		  1
#define BSIZE           256+17

extern int ID_hpib;
extern int serial;

/*----------------------------------------------------------------------*/

int wrdev_(mode,devid,buffer,buflen,error,ipcode,timeout, no_after, kecho,
	   itime, centisec,no_write_ren)

int *mode,*devid;
int *ipcode;
unsigned char *buffer;
int *buflen;  		/* length of the message in buffer, characters */
int *error;
int *timeout;
int *no_after;
int *kecho;
int *itime;
int centisec[2];
int *no_write_ren;
{
  int val;
  char locbuf[BSIZE];
  int ierr;
  int len;

  *error = 0;
  *ipcode = 0;

  if (serial) {
    ierr=sib(ID_hpib,"tmo .1\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"WT",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","WT");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"WT",2);
      return -1;
    }
  }

#if 0
  if(!serial) {
#ifdef CONFIG_GPIB
    ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"WC",2);
      return -1;
    } 
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    ierr=sib(ID_hpib,"cm \n_?\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"WC",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","WC");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"WC",2);
      return -1;
    }
  }
#endif
  if((!serial) && (!*no_write_ren)) {
#ifdef CONFIG_GPIB
    ibsre(ID_hpib,1);  	/* must turn REN on before addressing device */
    if ((ibsta & ERR) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"WS",2);
      return -1;
    } 
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  }

  if (*mode == 0){
    if(!serial) {
#ifdef CONFIG_GPIB
      memcpy(locbuf,buffer,*buflen);
      memcpy(locbuf+*buflen,"\r\n",2);
      if(*kecho)
	echo_out('w',*mode,*devid,locbuf,*buflen+2);
      if(*itime)
	rte_ticks(centisec);
      ibwrt(*devid,locbuf,*buflen+2);
      if(*itime)
	rte_ticks(centisec+1);
      if ((ibsta & TIMO) != 0) {
	*error = TIMEOUT;
	memcpy((char *)ipcode,"W1",2);
	return -1;
      } else if ((ibsta & ERR) != 0) {
	if(iberr==0)
	  logit(NULL,errno,"un");
	*error = -(IBCODE + iberr);
	memcpy((char *)ipcode,"W1",2);
	return -1;
      }
#else
      *error = -(IBCODE + 22);
      return -1;
#endif
    } else {
      sprintf(locbuf,"wrt #%d %d\n",*buflen+2,*devid);
      len=strlen(locbuf);
      memcpy(locbuf+len,buffer,*buflen);
      memcpy(locbuf+len+*buflen,"\r\n",2);
      if(*kecho)
	echo_out('w',*mode,*devid,locbuf+len,*buflen+2);
      ierr=sib(ID_hpib,locbuf,len+*buflen+2,0,*timeout,*itime,centisec);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"W1",2);
	return -1;
      } else if ((ibsta & S_TIMO) != 0) {
/* ignore
	*error = TIMEOUT;
	memcpy((char *)ipcode,"W1",2);
	return -1;
 */
      } else if ((ibsta & S_ERR) != 0) {
	if(ibser!=0)
	  logita(NULL,-(540 + ibser),"ib","W1");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W1",2);
	return -1;
      }
    }
  } else {
    if(!serial) {
#ifdef CONFIG_GPIB  
      if(*kecho)
	echo_out('w',*mode,*devid,buffer,*buflen);
      ibwrt(*devid,buffer,*buflen);
      if ((ibsta & TIMO) != 0) {	/* timeout ? */ 
	*error = -(IBCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
      } else if ((ibsta & ERR) != 0) {		/* bus error ? */ 
	if(iberr==0)
	  logit(NULL,errno,"un");
	*error = -(IBCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
      }
#else
      *error = -(IBCODE + 22);
      return -1;
#endif
    } else {
      sprintf(locbuf,"wrt #%d %d\n",*buflen,*devid);
      len=strlen(locbuf);
      memcpy(locbuf+len,buffer,*buflen);
      if(*kecho)
	echo_out('w',*mode,*devid,buffer,*buflen);
      ierr=sib(ID_hpib,locbuf,*buflen+len,0,*timeout,0,centisec);
      if ((ibsta & S_TIMO) != 0) {	/* timeout ? */ 
/* ignore
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
 */
      } else if ((ibsta & S_ERR) != 0) {		/* bus error ? */ 
	if(ibser!=0)
	  logita(NULL,-(540 + ibser),"ib","W2");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
      }
    }
  }
  if((!serial) && (!*no_write_ren)) {
#ifdef CONFIG_GPIB
    ibsre(ID_hpib,0);  	/* must turn REN off again */
    if ((ibsta & ERR) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"WR",2);
      return -1;
    } 
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  }
  if((!serial) && (!*no_after)) {
#ifdef CONFIG_GPIB
    ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"WF",2);
      return -1;
    } 
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
#if 0
  } else {
    ierr=sib(ID_hpib,"cm \n_?\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"WF",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","WF");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"WF",2);
      return -1;
    }
#endif
  }
  return 0;
}

