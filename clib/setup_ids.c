#include <sys/types.h>
#include <signal.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void setup_ids()
{
    void sem_att(), skd_att(), shm_att(), cls_att(), brk_att();

    if (sizeof(Fscom) > C_RES ) {
       printf(" setup_ids: Fscom C structure too large: %d bytes \n",
              sizeof(Fscom));
       exit(-1);
    }

    shm_att( SHM_KEY);

    cls_att( CLS_KEY);

    skd_att( SKD_KEY);

    sem_att( SEM_KEY);

    brk_att( BRK_KEY);

    rte_fpmask();      /* disable fp exceptions for robustness */

                       /* ignore signals that might accidently abort */
/*  if (-1==sigignore(SIGINT)) {
      perror("setup_ids: ignoring SIGINT");
      exit(-1);
    }

    if (-1==sigignore(SIGQUIT)) {
      perror("setup_ids: ignoring SIGQUIT");
      exit(-1);
    }*/

}
