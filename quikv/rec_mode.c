/* S2 recorder rec_mode snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl_def.h"

static char device[]={"r1"};           /* device menemonics */

void rec_mode(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      ibool barrelroll;
      struct rclcn_req_buf buffer;        /* rclcn request buffer */
      struct rec_mode_cmd lcl;

      int rec_mode_dec();                 /* parsing utilities */
      char *arg_next();

      void rec_mode_dis();
      void ini_rclcn_req(), end_rclcn_req();
      void add_rclcn_mode_set();
      void add_rclcn_mode_read();
      void add_rclcn_group_set();
      void add_rclcn_group_read();
      void add_rclcn_consolecmd();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ini_rclcn_req(&buffer);

      if (command->equal != '=') {            /* read module */
	add_rclcn_mode_read(&buffer,device);
	add_rclcn_group_read(&buffer,device);
	add_rclcn_barrelroll_read(&buffer,device);
	goto rclcn;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          rec_mode_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=rec_mode_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.s2rec.check;
      shm_addr->check.s2rec.check=0;

      memcpy(&shm_addr->rec_mode,&lcl,sizeof(lcl));
      shm_addr->rec_mode.num_groups=0;
      
/* format buffers for rclcn */

      add_rclcn_mode_set(&buffer,device,lcl.mode);
      add_rclcn_group_set(&buffer,device,lcl.group);
      
      if(lcl.roll == 1)
	barrelroll=TRUE;
      else if (lcl.roll == 0)
	barrelroll=FALSE;
      else {
	ierr=-301;
	goto error;
      }
      add_rclcn_barrelroll_set(&buffer,device,barrelroll);

rclcn:
      end_rclcn_req(ip,&buffer);
      skd_run("rclcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.s2rec.mode=TRUE;
	shm_addr->check.s2rec.group=TRUE;
	shm_addr->check.s2rec.roll=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.s2rec.check=ichold;
      }
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      rec_mode_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"rr",2);
      return;
}
