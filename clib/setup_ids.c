#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <signal.h>
#include <unistd.h>

#include "../include/ipckeys.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void setup_ids()
{
    void sem_att(), skd_att(), shm_att(), cls_att(), brk_att();

    setvbuf(stdout, NULL, _IONBF, BUFSIZ);
    setvbuf(stderr, NULL, _IONBF, BUFSIZ);

    if (sizeof(Fscom) > C_RES ) {
       printf(" setup_ids: Fscom C structure too large: %d bytes \n",
              sizeof(Fscom));
       exit(-1);
    }

    shm_att( SHM_KEY);

    cls_att( CLS_KEY);

    skd_att( SKD_KEY);

    sem_att( SEM_KEY);

    nsem_att( NSEM_KEY);

    brk_att( BRK_KEY);

    go_att( GO_KEY);

                       /* ignore signals that might accidently abort */
    if (SIG_ERR==signal(SIGINT,SIG_IGN)) {
      perror("setup_ids: ignoring SIGINT");
      exit(-1);
    }

    if (SIG_ERR==signal(SIGQUIT,SIG_IGN)) {
      perror("setup_ids: ignoring SIGQUIT");
      exit(-1);
    }

    if (SIG_ERR==signal(SIGFPE,SIG_IGN)) {
      perror("setup_ids: ignoring SIGFPE");
      exit(-1);
    }

}



