/* S2 recorder label snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl.h"

static char device[]={"r1"};           /* device menemonics */

void s2label(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr, iset;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      struct s2label_cmd lcl;
      int rstate;

      int iret,ierror;

      int user_info_dec();                 /* parsing utilities */
      char *arg_next();

      void s2label_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_tapeid_set();
      void add_rclcn_tapeid_read();
      void add_rclcn_tapetype_set();
      void add_rclcn_tapetype_read();
      void get_s2tapetype();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */
      iset=FALSE;

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_tapeid_read(&buffer,device);
	add_rclcn_tapetype_read(&buffer,device);
	goto rclcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          s2label_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=s2label_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

      if(strcmp(lcl.format,"csa")==0) { /* verify CSA format */
	int i, check, sum, icount, iok;

	iok=TRUE;
	iok= iok && lcl.tapeid[2]=='-';
	iok= iok && lcl.tapeid[4]=='-';
	for (i=5;i<10;i++)
	  iok= iok && isdigit(lcl.tapeid[i]);

	iok= iok && isxdigit(lcl.tapeid[10]);
	iok= iok && isxdigit(lcl.tapeid[11]);

	if(lcl.tapeid[12]!=0) {
	  iok= iok && lcl.tapeid[12]=='-';
	  iok= iok && lcl.tapeid[13]!=0;
	  for (i=13;iok && lcl.tapeid[i]!=0;i++) {
	    int j;

	    iok= iok && (NULL!=strchr("01234567",lcl.tapeid[i]));
	    for (j=i+1;iok && lcl.tapeid[j]!=0;j++)
	      iok = iok && lcl.tapeid[i]!=lcl.tapeid[j];
	  }
	}

	check=0;
	for (i=0;i<10;i++)
	  check+=lcl.tapeid[i];
	check&=0xFF;
	icount=sscanf(lcl.tapeid+10,"%2x",&sum);

	if(!iok) {
	  ierr=-301;
	  goto error;
	} else if(icount != 1 || check != sum) {
	  ierr= -303;
	  goto error;
	} else if(strlen(lcl.tapetype)==1 && lcl.tapeid[3]!=lcl.tapetype[0]) {
	  ierr=-305;
	  goto error;
	} else if(strlen(lcl.tapetype)==0) {
	  lcl.tapetype[0]=lcl.tapeid[3];
	  lcl.tapetype[1]=0;
	}
      } else {
	if(strlen(lcl.tapetype)!=1&&strlen(lcl.tapetype)!=6) {
	  ierr=-302;
	  goto error;
	}
      }
	
/* all parameters parsed okay, update common */

      ichold=shm_addr->check.s2rec.check;
      shm_addr->check.s2rec.check=0;

      memcpy(&shm_addr->s2label,&lcl,sizeof(lcl));
      
/* format buffers for rclcn */

      add_rclcn_tapeid_set(&buffer,device,lcl.tapeid);
      rstate=get_s2state(ip,"rb");
      if(ip[2]!=0) {
	iret=1;
	goto check;
      }
      if (rstate==RCL_RSTATE_RECORD) {
	char tapetype[RCL_MAXSTRLEN_TAPETYPE];
	get_s2tapetype(tapetype,ip,"rb");
	if(ip[2]!=0) {
	  iret=1;
	  goto check;
	}
	if(strcmp(tapetype,lcl.tapetype)!=0) {
	  ierror=1;
	  ierr=-306;
	  goto rclcn0;
	}
      } else
	add_rclcn_tapetype_set(&buffer,device,lcl.tapetype);

      iset=TRUE;
rclcn:
      ierror=0;
rclcn0:
      iret=0;
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

check:
      if (ichold != -99) {
	shm_addr->check.s2rec.tapeid=TRUE;
	shm_addr->check.s2rec.tapetype=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.s2rec.check=ichold;
      }

      if(iret)
	return;

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }
      if(iset && !ierror)
	shm_addr->KHALT=0;

      s2label_dis(command,ip);

      if(!ierror)
	return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rb",2);
      return;
}
