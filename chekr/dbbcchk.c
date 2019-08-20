/* chekr DAS rack routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 513

void dbbcchk_( char *lwho )
{
  int ip[5];
  int i,ierr;
  int rtn1;    /* argument for cls_rcv - unused */
  int rtn2;    /* argument for cls_rcv - unused */
  int msgflg=0;  /* argument for cls_rcv - unused */
  int save=0;    /* argument for cls_rcv - unused */
  int nchars;
  char inbuf[BUFSIZE];
  int out_recs, out_class;
  char outbuf[BUFSIZE];
  int ichold;

  ichold=shm_addr->check.dbbc_form;
  if(ichold<=0 )
    return; /* check is disabled */

  out_recs=0;
  out_class=0;
  strcpy(outbuf,"version");
  cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
  out_recs++;

dbbcn:

  ip[0]=1;
  ip[1]=out_class;
  ip[2]=out_recs;

  nsem_take( "fsctl" , 0 );
  skd_run("dbbcn",'w',ip);
  nsem_put( "fsctl" );

  skd_par(ip);


  if(ip[2]<0) {
    logitn(NULL,ip[2],ip+3,ip[4]);
    logit(NULL,-810,lwho);
    return;
  }

  ierr=0;
  for (i=0;i<ip[1];i++) {
    if ((nchars =
	 cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
      logit(NULL,-811,lwho);
      goto end;
    }
    inbuf[nchars]=0;
    /*                12345678 */
    if(strncmp(inbuf,"version/",8)==0) {
      ierr=dbbc_version_check(inbuf,NULL);
      if(ierr!=0 && ichold == shm_addr->check.dbbc_form) {
	logit(NULL,-813,lwho);
	goto end;
      }
    } else {
      logit(NULL,-813,lwho);
      goto end;
    }
  }
  return;

  end:
    if(i<ip[1]-1)
      cls_clr(ip[0]);
    return;

  }
