/* S2 rcl SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void rcl(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ierr, icmd;
      struct rclcn_req_buf buffer;           /* rclcn request buffer */
      char *arg_next();
                                            /*rclcn request utilities */
      void ini_rclcn_req(), add_rclcn_req(), end_rclcn_req();
      void skd_run(), skd_par();      /* program scheduling utilities */

      ini_rclcn_req(&buffer);

      if (command->equal != '=' ||
          command->argv[0]==NULL||
	  command->argv[1]==NULL) {
         ierr=-201;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ierr=rcl_dec(command,&buffer,&icmd);
      if (ierr!=0)
	goto error;

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }
      rcl_dis(command,icmd,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rm",2);
      return;
}
