/* S2 recorder et snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl.h"

#define MAX_OUT 256

static char device[]={"r1"};           /* device menemonics */

void s2et(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      char output[MAX_OUT];

      struct rclcn_req_buf buffer;        /* rclcn request buffer */

      void s2et_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_stop();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_rclcn_req(&buffer);

      if (command->equal == '=') {          /* stop */
	ierr = -301;
	goto error;
      }
      
      ichold=shm_addr->check.s2rec.check;
      shm_addr->check.s2rec.check=0;

/* format buffers for rclcn */

      switch(itask) {
      case 1:
	add_rclcn_stop(&buffer,device);
	shm_addr->s2_rec_state=RCL_RSTATE_STOP;
	break;
      case 2:
	add_rclcn_rewind(&buffer,device);
	shm_addr->s2_rec_state=RCL_RSTATE_REWIND;
	break;
      case 3:
	add_rclcn_ff(&buffer,device);
	shm_addr->s2_rec_state=RCL_RSTATE_FF;
	break;
      default:
	ierr=-302;
	goto error;
      }

      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.s2rec.state=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.s2rec.check=ichold;
      }
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      logrclmsg(output,command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"re",2);
      return;
}
