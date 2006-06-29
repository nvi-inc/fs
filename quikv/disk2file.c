/* mk5 disk2file SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/wait.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void disk2file(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, i, count;
      char *ptr;
      char *arg_next();
      int out_recs, out_class;
      char outbuf[BUFSIZE];
      struct disk2file_cmd lcl;
      char destination[sizeof(shm_addr->disk2file.destination.destination)];
      char cmd[(sizeof(destination)-1)+(sizeof(shm_addr->mk5host)-1)+23+128];
      pid_t fork_result;  /*result of fork to create child process */
      int result;
      int rtn1;    /* argument for cls_rcv - unused */
      int rtn2;    /* argument for cls_rcv - unused */
      int msgflg=0;  /* argument for cls_rcv - unused */
      int save=0;    /* argument for cls_rcv - unused */
      int nchars;
      char inbuf[BUFSIZE];
      int iclass, nrecs;
      struct disk2file_cmd lclc;
      struct disk2file_mon lclm;

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=' ) {
	char *str;
	out_recs=0;
	out_class=0;
	str="disk2file?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	str="scan_set?\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	ip[0]=1;
	goto mk5cn;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL &&
	       *command->argv[0]=='?') { /* special cases */
	disk2file_dis(command,itask,ip);
	return;
      } else if(strcmp(command->argv[0],"abort")==0) {
	char *str;
	out_recs=0;
	out_class=0;
	str="reset=abort;\n";
	cls_snd(&out_class, str, strlen(str) , 0, 0);
	out_recs++;
	ip[0]=5;
	ip[1]=out_class;
	ip[2]=out_recs;
	skd_run("mk5cn",'w',ip);
	skd_par(ip);
	if(ip[2]<0) {
	  if(ip[0]!=0) {
	    cls_clr(ip[0]);
	    ip[0]=ip[1]=0;
	  }
	  return;
	}
	cls_clr(ip[0]);
	if (command->argv[1]!=NULL) {  /* runs script on Mark 5 */
	  if(strcmp(command->argv[1],"autoftp")!=0) {
	    ierr=-308;
	    goto error;
	  }
	  destination[0]=0;
	  if(shm_addr->disk2file.destination.state.known) {
	    strcpy(destination,shm_addr->disk2file.destination.destination);
	  }
	  if(strlen(destination)==0) {
	    char *str;
	    out_recs=0;
	    out_class=0;
	    str="disk2file?\n";
	    cls_snd(&out_class, str, strlen(str) , 0, 0);
	    out_recs++;
	    ip[0]=5;
	    ip[1]=out_class;
	    ip[2]=out_recs;
	    skd_run("mk5cn",'w',ip);
	    skd_par(ip);
	    
	    if(ip[2]<0) {
	      if(ip[0]!=0) {
		cls_clr(ip[0]);
		ip[0]=ip[1]=0;
	      }
	      return;
	    }
	    iclass=ip[0];
	    nrecs=ip[1];
	    if ((nchars =
		 cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,
			 save)) <= 0) {
	      ierr = -401;
	      cls_clr(iclass);
	      goto error;
	    }
	    if(0!=m5_2_disk2file(inbuf,&lclc,&lclm,ip)) {
	      cls_clr(iclass);
	      goto error;
	    }
	    cls_clr(iclass);
	    if(!lclc.destination.state.known) {
	      ierr=-305;
	      goto error;
	    }
	    strcpy(destination,lclc.destination.destination);
	  }
	  fork_result = fork();
	  if (fork_result == (pid_t)-1) { /* failure creating child */
	    logit(NULL,errno,"un");
	    ierr = -301;
	    goto error;
	  } else if (fork_result == 
		     (pid_t)0) { /* we are in the child process */
	    fork_result = fork();
	    if (fork_result == (pid_t)-1) { /* failure creating grandchild */
	      logit(NULL,errno,"un");
	      logit(NULL,-303,"5f");
	      exit(EXIT_FAILURE);
	    } else if (fork_result == 
		       (pid_t)0) { /* we are in the grandchild process */
	      execlp("xterm",
		     "xterm",
		     "-name","autoftp",
		     "-e","autoftp",
		     shm_addr->mk5host,
		     destination,command->argv[2],
		     (char *)0); /* start new program */
	      logit(NULL,errno,"un");
	      logit(NULL,-302,"5f");
	      exit(EXIT_FAILURE); /* if we get here it must have failed,*/
	    } else { /*second fork succeeded this the child process */
	      exit(0);
	    }
	  } else { /* we are in the parent process */
	    waitpid(fork_result,&result,0);
	    printf(" result %d\n",result);
	    if(WIFEXITED(result) ==0 ) {
	      ierr=-304;
	      goto error;
	    } else if(ip[3]=WEXITSTATUS(result)) {
	      logitn(NULL,-306,"5f",ip[3]);
	      ierr=-307;
	      goto error;
	    }
	  }
	}
	ip[0]=ip[1]=ip[2]=0;
	return;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->disk2file,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=disk2file_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      memcpy(&shm_addr->disk2file,&lcl,sizeof(lcl));
      
      out_recs=0;
      out_class=0;

      disk2file_2_m5_scan_set(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;

      disk2file_2_m5(outbuf,&lcl);
      cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
      out_recs++;
      ip[0]=1;

mk5cn:
      ip[1]=out_class;
      ip[2]=out_recs;
      skd_run("mk5cn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	if(ip[0]!=0) {
	  cls_clr(ip[0]);
	  ip[0]=ip[1]=0;
	}
	return;
      }
      disk2file_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"5f",2);
      return;
}
