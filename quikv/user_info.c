/* S2 recorder user_info snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"r1"};           /* device menemonics */

void user_info(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      struct user_info_parse lcl;

      int user_info_dec();                 /* parsing utilities */
      char *arg_next();

      void user_info_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_user_info_set();
      void add_rclcn_user_info_read();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_user_info_read(&buffer,device,1,TRUE);
	add_rclcn_user_info_read(&buffer,device,2,TRUE);
	add_rclcn_user_info_read(&buffer,device,3,TRUE);
	add_rclcn_user_info_read(&buffer,device,4,TRUE);
	add_rclcn_user_info_read(&buffer,device,1,FALSE);
	add_rclcn_user_info_read(&buffer,device,2,FALSE);
	add_rclcn_user_info_read(&buffer,device,3,FALSE);
	add_rclcn_user_info_read(&buffer,device,4,FALSE);
	goto rclcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          user_info_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=user_info_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.s2rec.check;
      shm_addr->check.s2rec.check=0;
      
/* format buffers for rclcn */

      add_rclcn_user_info_set(&buffer,device,lcl.field,lcl.label,
			      lcl.string);
      if(lcl.label)
	strcpy(shm_addr->user_info.labels[lcl.field-1],lcl.string);
      else {
	switch (lcl.field) {
	case 1:
	  strcpy(shm_addr->user_info.field1,lcl.string);
	  break;
	case 2:
	  strcpy(shm_addr->user_info.field2,lcl.string);
	  break;
	case 3:
	  strcpy(shm_addr->user_info.field3,lcl.string);
	  break;
	case 4:
	  strcpy(shm_addr->user_info.field4,lcl.string);
	  break;
	default:
	  ierr=-301;
	  goto error;
	}
      }

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	if(lcl.label)
	  shm_addr->check.s2rec.user_info.label[lcl.field-1]=TRUE;
	else
	  shm_addr->check.s2rec.user_info.field[lcl.field-1]=TRUE;
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.s2rec.check=ichold;
      }
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      user_info_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ru",2);
      return;
}
