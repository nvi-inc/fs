//* mk5 in2net SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void in2net(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct in2net_cmd lcl;
      int nop, query;

      void skd_run(), skd_par();      /* program scheduling utilities */

      query=FALSE;
      if (command->equal != '=' ) {
	char *str;
	out_recs=0;
	out_class=0;
	str="in2net?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	goto mk5cn;
	query=TRUE;
      } else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  in2net_dis(command,itask,ip);
	  return;
	}

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->in2net,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=in2net_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      nop=lcl.control.control==3 &&
	strcmp(shm_addr->in2net.last_destination,
	       lcl.destination.destination)==0;

      memcpy(&shm_addr->in2net,&lcl,sizeof(lcl));
      
      if(nop) {
	ip[0]=ip[1]=ierr=0;
	return;
      }

      out_recs=0;
      out_class=0;

      in2net_2_m5(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

mk5cn:
      ip[0]=1;
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(!query)
	if(ip[2]>=0 && lcl.control.control==3) {
	  strncpy(shm_addr->in2net.last_destination,
		  lcl.destination.destination,
		  sizeof(shm_addr->in2net.last_destination));
	} else if((ip[2]<0 && lcl.control.control==3) ||
		  lcl.control.control==2)
	  shm_addr->in2net.last_destination[0]=0;

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }
      in2net_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5i",2);
      return;
}
