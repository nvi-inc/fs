/* lba das trackform snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

unsigned short track_mask;

void lba_trkfrm(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      unsigned short track_old;
      int ilast, ierr, ichold, i, count;
      char *ptr;
      struct das lcl[MAX_DAS];    /* local instance of das command structs */

      int lba_trkfrm_dec();                 /* parsing utilities */
      char *arg_next();

      void lba_trkfrm_dis();

      int lba_ifp_setup(), lba_ifp_write();

      ierr = 0;
      track_old = track_mask;
      memcpy(lcl,shm_addr->das,sizeof(lcl));
      

      if (command->equal != '=') {            /* display table */
	 lba_trkfrm_dis(command,lcl,ip);
	 return;
      } else if (command->argv[0]==NULL) { /* simple equals */
         track_mask = 0;
         for (i=0;i<2*shm_addr->n_das;i++)
             lcl[i/2].ifp[i%2].track[0] = lcl[i/2].ifp[i%2].track[1] = -1;
         goto copy;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=lba_trkfrm_dec(lcl,&count, ptr);
        if(ierr !=0 ) {
          track_mask = track_old;
          goto error;
	}
      }
      for (i=0;i<2*shm_addr->n_das;i++) lba_ifp_setup(&lcl[i/2].ifp[i%2],i);

/* all parameters parsed okay, update common */
copy:
      memcpy(shm_addr->das,lcl,sizeof(lcl));
      
      for (i=0;i<2*shm_addr->n_das;i++) {
        if (lcl[i/2].ifp[i%2].initialised) {
          ichold=shm_addr->check.ifp[i];
          shm_addr->check.ifp[i]=0;

          if ((ierr=lba_ifp_write(i)) != 0) {
             ierr = -901;
          }

          if (ichold != -99) {
             rte_rawt(shm_addr->check.ifp_time+i);
             if (ichold >= 0)
                ichold=ichold % 1000 + 1;
             shm_addr->check.ifp[i]=ichold;
          }
          if (ierr !=0 ) goto error;
        }
      }

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"lt",2);
      return;
}
