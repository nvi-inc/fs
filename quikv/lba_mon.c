/* lba das mon snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void lba_mon(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifp number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ind, ichold, count;
      char *ptr;
      struct ifp lcl;              /* local instance of ifp command struct */

      int lba_mon_dec();               /* parsing utilities */
      char *arg_next();

      int lba_ifp_setup(), lba_ifp_write(), lba_ifp_read();  /* ifp utilities */
      void lba_mon_dis();

      ichold= -99;                    /* check value holder */

      ind=itask-1;                    /* index for this module */
      if (ind/2 >= shm_addr->n_das) {
          ierr = -903;
          goto error;
      }
      ierr = 0;

      if (command->equal != '=') {            /* read module */
         goto monitor;
      } else if (command->argv[0]==NULL) goto parse;  /* simple equals */
        else if (command->argv[1]==NULL  /* special cases */
                 && *command->argv[0]=='?') {
            lba_mon_dis(command,itask,ip);
            return;
      } else if ( command->argv[1] != NULL && command->argv[2] != NULL &&
                  command->argv[3] != NULL ) {
         ierr=-301;
         goto error;
      }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->das[ind/2].ifp[ind%2],sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=lba_mon_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }
      lba_ifp_setup(&lcl,ind);

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.ifp[ind];
      shm_addr->check.ifp[ind]=0;
      memcpy(&shm_addr->das[ind/2].ifp[ind%2],&lcl,sizeof(lcl));
      
      if (lcl.initialised && (ierr=lba_ifp_write(ind)) != 0) {
         ierr = -901;
      }

      if (ichold != -99) {
         rte_rawt(shm_addr->check.ifp_time+ind);
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
         shm_addr->check.ifp[ind]=ichold;
      }
      if (ierr !=0 ) goto error;

monitor:
      lba_mon_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"lm",2);
      return;
}
