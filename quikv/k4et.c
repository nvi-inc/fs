/* K4 recorder et snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

static char device[]={"r1"};           /* device menemonics */

void k4et(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      char output[MAX_OUT];

      void k4et_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */


      if (command->equal == '=') {          /* stop */
	ierr = -301;
	goto error;
      }
      
      ichold=shm_addr->check.k4rec.check;
      shm_addr->check.k4rec.check=0;

/* format buffers for k4con */

      ip[0]=ip[1]=0;

      switch(itask) {
      case 1:
	ib_req2(ip,device,"STP");
	shm_addr->k4_rec_state=0;
	break;
      case 2:
	ib_req2(ip,device,"DRW");
	shm_addr->k4_rec_state=-2;
	break;
      case 3:
	ib_req2(ip,device,"DFF");
	shm_addr->k4_rec_state=+2;
	break;
      default:
	ierr=-302;
	goto error;
      }

      skd_run("ibcon",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.k4rec.state=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.k4rec.check=ichold;
      }
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ke",2);
      return;
}
