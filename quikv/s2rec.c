/* S2 recorder user_info snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"rc"};           /* device menemonics */

void s2rec(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, i, count;
      int verr;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      long int position[8];

      int s2tape_dec();                 /* parsing utilities */
      char *arg_next();

      void s2tape_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_position_read();
      void add_rclcn_position_set();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_position_read(&buffer,device,0);
	add_rclcn_version(&buffer,device);
	add_rclcn_time_read(&buffer,device);
	goto rclcn;
      } else if (command->argv[0]==NULL)   /* simple equals */
	goto parse;
      else if (command->argv[1]==NULL)     /* special cases */
        if (strcmp(command->argv[0],"eject")==0
	    || strcmp(command->argv[0],"unload")==0) {
	  add_rclcn_consolecmd(&buffer,device,"transport all eject");
	  goto rclcn;
	} else if (strcmp(command->argv[0],"re-establish")==0) {
	  add_rclcn_position_reestablish(&buffer,device);
	  goto rclcn;
	} 

      
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=s2rec_dec(position,&count, ptr);
        if(ierr !=0 )
	  goto error;
      }

/* format buffers for mcbcn */
      
      if (ilast==1)
	add_rclcn_position_set(&buffer,device,0,position[0]);
      else if(ilast==8)
	add_rclcn_position_set_ind(&buffer,device,0,position);
      else {
	ierr=-301;
	goto error;
      }

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      s2rec_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rv",2);
      return;
}
