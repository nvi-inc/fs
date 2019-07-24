#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "fserr.h"

/*                                                                 */
/*  FSERR is the routine which sends DDOUT the appropriate error   */
/*  message for the given two character mnemonic and error number. */
/*  The error information is read into a large structure array     */
/*  from first the station error control file sterr.ctl and then   */
/*  the Field System error control file fserr.ctl. A Hash routine  */
/*  is used to set and find the position for each message in the   */
/*  array.                                                         */

/*                                                                 */
/*  HISTORY:                                                       */
/*  WHO  WHEN    WHAT                                              */
/*  gag  920917  Rewrote to use a structured array instead of the  */
/*               index files.                                      */
/*                                                                 */

extern struct fscom *shm_addr;

struct errorlist{       /* structure type to store error information */
  char mnemonic[2];
  int ierr;
  char message[120];
};

struct errorlist list[MAXERRORS];

FILE *dcbfs;

main(){
  int cls_rcv();
  int sscanf();
  long class, ip[5];
  int rtn1, rtn2;
  char inbuf[81];
  int i;
  int len;
  int hash;
  int hashcount;

  struct {
    char buf[2];
    int off;
  } entry;

  setup_ids();

/*  zero out the error number position in the error structure */
  for (i=0; i < MAXERRORS; i++)
    list[i].ierr=0;

/* Read in the error messages from station control file, sterr, first */
/* initializing the array with the error information using subroutine */
/* listinit.                                                          */

  if ((dcbfs=fopen(CTLST, "r"))==NULL) goto Suspend;
  listinit(dcbfs,list);
  fclose(dcbfs);

/* Read in the error messages from FS control file, fserr */

  if ((dcbfs=fopen(CTLFS, "r"))==NULL) goto Suspend;
  listinit(dcbfs,list);
  fclose(dcbfs);

  skd_wait("fserr", ip, 0);
  if(ip[0]==-1) exit(-1);

/* call to retrieve parameter string */
  cls_rcv(ip[0], inbuf, 80, &rtn1, &rtn2, 0, 0);
  inbuf[80]='\0';   /* make sure it is null terminated */

/* main rept-until loop done once for each err reported */

Repeat: 
  inbuf[48]='  ';
  if(memcmp(inbuf, "##", 2)==0){ 
    printf("number of entries = ");
    goto Suspend; 
  } 

  while(inbuf[0]!= ' ')     /* find the first space to delimit error code */
    for(i=0;i<79;++i)
      inbuf[i]=inbuf[i+1];

  if(inbuf[0]== ' ')       /* skip the space */
    for(i=0;i<79;++i)
      inbuf[i]=inbuf[i+1];

  for(i=0;i<80;++i)        /* use upper case for search */
      inbuf[i]=toupper(inbuf[i]);

  i = sscanf(inbuf,"%2s %d",entry.buf,&entry.off);

  hashcode(&entry,&hash);
  hashcount=1;
  while ((memcmp(entry.buf,list[hash].mnemonic,2)!=0) || 
          (entry.off!=list[hash].ierr)) {
    hash+=1;
    if (hash==MAXERRORS)
      hash=0;
    hashcount+=1;
    if (hashcount >= MAXERRORS) 
      break;
  }

  class = 0;
  if (hashcount==MAXERRORS){
    memcpy(inbuf,"nono",4);
    inbuf[4]='\0';
    len=4;
  }
  else {
    len = strlen(list[hash].message);
    memcpy(inbuf,list[hash].message,len);
    len-=1;
  }
  cls_snd(&class,inbuf,len,0,0);

Suspend:

  ip[0] = class;
  skd_wait("fserr", ip, 0);
  if(ip[0]!=-1) {
    cls_rcv(ip[0], inbuf, 80, &rtn1, &rtn2, 0, 0);
    goto Repeat; 
  }
}
