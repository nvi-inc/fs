/* S2 recorder st snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl.h"

static char device[]={"rc"};           /* device menemonics */

void s2st(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      struct s2st_cmd lcl;

      int user_info_dec();                 /* parsing utilities */
      char *arg_next();

      void s2st_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_speed_set();
      void add_rclcn_speed_read();
      void add_rclcn_record();
      void add_rclcn_play();
      void add_rclcn_stop();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_speed_read(&buffer,device);
	add_rclcn_state_read(&buffer,device);
	goto rclcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          s2st_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->s2st,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=s2st_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.s2rec.check;
      shm_addr->check.s2rec.check=0;

      memcpy(&shm_addr->s2st,&lcl,sizeof(lcl));
      shm_addr->s2_rec_state=lcl.record;
      
/* format buffers for rclcn */
      if(lcl.speed >= 0) {
	int rstate=get_s2state(ip,"rs");
	if(ip[2]!=0)
	  return;
	if(rstate==RCL_RSTATE_RECORD) {
	  int speed=get_s2speed(ip,"rs");
	  if(ip[2]!=0)
	    return;
	  if(speed!=lcl.speed) {
	    ierr=-301;
	    goto error;
	  }
	} else
	  add_rclcn_speed_set(&buffer,device,lcl.speed);
      }
      if(lcl.record==RCL_RSTATE_RECORD)
	add_rclcn_record(&buffer,device);
      else
	add_rclcn_play(&buffer,device);

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	if(lcl.speed >= 0)
	  shm_addr->check.s2rec.speed=TRUE;
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

      s2st_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rs",2);
      return;
}
