#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 120
#define MAX_BUF 256

void logmatmsgfm(output,command,ip)
char *output;
struct cmd_ds *command;
long ip[5];
{
  char buff[MAX_BUF];

  int i, nchar, ilen, idum, icopy, nrec, cls_rcv(), iend, iack;
  long iclass;
  void cls_clr();

  strcpy(output,command->name);
  strcat(output,"/");
  iend=strlen(output);
  
  iclass=ip[0];
  nrec=ip[1];

  ip[0]=ip[1]=0;

  iack=0;
  for (i=0;i<nrec;i++) {
    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
    if(i == 0) {
      struct form4_cmd lclc;
      struct form4_mon lclm;
      int i, icount;
      maSTAform4(&lclc,&lclm,buff);
      if(lclm.error & (1<<15))
	logit(NULL,-501,"4f");
      icount=0;
      for (i=0;i<8;i++)
	if(! (lclm.rack_ids & 1<<i))
	  icount++;
      if(icount < 2) 
	logit(NULL,-503,"4f");
      if(lclm.version != shm_addr->imk4fmv)
	logitn(NULL,-504,"4f",lclm.version);
      continue;
    }

    if(memcmp(buff+2,"ack",3)!=0 ) {
      if(iack) {
	 cls_snd(ip,output,strlen(output),0,0);
	 ip[1]++;
      }
      ilen=strlen(output);
      icopy=MAX_OUT-(ilen+1);
      icopy= icopy < (nchar-2) ? icopy : (nchar-2);
      strncat(output,buff+2,icopy);
      output[ilen+icopy]=0;
      cls_snd(ip,output,strlen(output),0,0);
      ip[1]++;
      iack=0;
    } else {
      if(iack)
	strcat(output,",");
      else
	output[iend]=0;
      strcat(output,"ack");
      iack=1;
    }
    
  }

  if(iack) {
    cls_snd(ip,output,strlen(output),0,0);
    ip[1]++;
  }

  cls_clr(iclass);
  
  return;
}



