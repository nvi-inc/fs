/* dbbc_vsix snap commands */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc_vsix(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
  int ilast, ierr,count,i,iend,j,found;
  char *ptr;
  struct dbbc_vsix_cmd lcl;  /* local instance of dbbc_vsix command struct */
  int out_recs, out_class;
  char outbuf[BUFSIZE];
  
  int dbbc_vsix_dec();               /* parsing utilities */
  char *arg_next();
  
  void dbbc_vsix_dis();
  void skd_run(), skd_par();      /* program scheduling utilities */
  
  if(DBBC!=shm_addr->equip.rack ||
     (DBBC_PFB != shm_addr->equip.rack_type &&
      DBBC_PFB_FILA10G != shm_addr->equip.rack_type)) {
    ierr=-501;
    goto error;
  }
  
  if (command->equal != '=') {            /* read module */
    ierr=-301;
    goto error;
    /*	out_recs=0;
	out_class=0;
	
	for(i=1;i<=shm_addr->dbbc_cores;i++) {
	sprintf(outbuf,"dbbctrk%d=%d",itask,i);
	cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
	out_recs++;
	}
	goto dbbcn;
    */
  } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
  else if (command->argv[1]==NULL) /* special cases */
    if (*command->argv[0]=='?') {
      dbbc_vsix_dis(command,itask,ip);
      return;
    }
  
  /* if we get this far it is a set-up command so parse it */
  
 parse:
  ilast=0;                                      /* last argv examined */
  memcpy(&lcl,&shm_addr->dbbc_vsix[itask],sizeof(lcl));
  
  count=1;
  while( count>= 0) {
    ptr=arg_next(command,&ilast);
    ierr=dbbc_vsix_dec(&lcl,&count, ptr);
    if(ierr !=0 ) goto error;
  }
  memcpy(&shm_addr->dbbc_vsix[itask],&lcl,sizeof(lcl));
      
  /* format buffer for dbbcn */
  
  iend=1; /* maske sure we stop at 1 if nothing is selected */
  for(i=1;i<=shm_addr->dbbc_cores;i++) { /*find lowest core with data */
    for(j=0;j<16 &&!(found=i==lcl.core[j]);j++) 
      ;
    if(found) {
      iend=i;
      break;
    }
  }
  
  out_recs=0;
  out_class=0;
  for(i=shm_addr->dbbc_cores; i>=iend ;i--) {
    dbbc_vsix_2_dbbc(outbuf,&lcl,itask,i);
    // printf(" outbuf '%s'\n",outbuf);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;
  }
  
  
dbbcn:
  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;
  skd_run("dbbcn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) {
    if(command->equal == '=' && -201 == ip[2]) {
      logitn(NULL,ip[2],ip+3,ip[4]);
      ip[2]=-302;
      memcpy(ip+3,"dv",2);
    }
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    return;
  }
  
  dbbc_vsix_dis(command,itask,ip);
  return;
  
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"dv",2);
  return;
}
