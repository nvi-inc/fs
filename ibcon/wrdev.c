/*
   It assumes you will use the configuration 'ibboard' for the 
   board. 

 */
#include <memory.h>
#include <string.h>
#include <errno.h>

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
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

int wrdev_(mode,devid,buffer,buflen,error,ipcode,timeout)

int *mode,*devid;
long *ipcode;
unsigned char *buffer;
int *buflen;  		/* length of the message in buffer, characters */
int *error;
int *timeout;
{
  int val;
  char locbuf[BSIZE];
  int ierr;
  int len;

  *error = 0;
  *ipcode = 0;

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
    ierr=sib(ID_hpib,"cm \n_?\r",0,0,100);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"WC",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logit(NULL,-(540 + ibser),"WC");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"WC",2);
      return -1;
    }
  }
#endif
  if (*mode == 2){
    if(!serial) {
#ifdef CONFIG_GPIB
      memcpy(locbuf,buffer,*buflen);
      memcpy(locbuf+*buflen,"\r\n",2);
      ibwrt(*devid,locbuf,*buflen+2);
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
      ierr=sib(ID_hpib,locbuf,len+*buflen+2,0,100);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"W1",2);
	return -1;
      } else if ((ibsta & S_TIMO) != 0) {
	*error = TIMEOUT;
	memcpy((char *)ipcode,"W1",2);
	return -1;
      } else if ((ibsta & S_ERR) != 0) {
	if(ibser!=0)
	  logit(NULL,-(540 + ibser),"W1");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W1",2);
	return -1;
      }
    }
  } else {
    if(!serial) {
#ifdef CONFIG_GPIB  
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
      ierr=sib(ID_hpib,locbuf,*buflen+len,0,*timeout);
      if ((ibsta & S_TIMO) != 0) {	/* timeout ? */ 
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
      } else if ((ibsta & S_ERR) != 0) {		/* bus error ? */ 
	if(ibser!=0)
	  logit(NULL,-(540 + ibser),"W2");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"W2",2);
      }
    }
  }
  if(!serial) {
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
    ierr=sib(ID_hpib,"cm \n_?\r",0,0,100);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"WF",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logit(NULL,-(540 + ibser),"WF");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"WF",2);
      return -1;
    }
#endif
  }
  return 0;
}

