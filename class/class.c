#include <stdio.h>	/* standard I/O header file */
#include <limits.h>     /* limits header file */
#include <errno.h>	/* error number definitions */
#include <sys/types.h>
#include <sys/ipc.h>	/* interprocess communications (IPC) header file */
#include <sys/msg.h>	/* message IPC header file */
#include <memory.h>    /* shared memory IPC header file */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define MAX_TEXT  120

struct  cls_buf {
	long	mtype;
        struct {
          int     parm[2];
          char    mtext[ MAX_TEXT];
        } messg;
} ;

static int msqid;

main()
{
key_t key;
long    class;
struct  cls_buf msg;
void sem_take(), sem_put();
int nchars,i;
   setup_ids();

printf(" allocated sem %d\n",shm_addr->sem.allocated);
sem_take( SEM_CLS);
printf(" locked class semaphore\n");

class=-LONG_MAX;
while ( -1 != (nchars=
 msgrcv( msqid, &msg, sizeof( msg.messg ), class, IPC_NOWAIT|MSG_NOERROR))) {
 printf(" mtype %d nchars %d rtn1 %d=%2.2s rtn2 %d=%2.2s\n",
        msg.mtype,nchars,
        msg.messg.parm[0],msg.messg.parm+0,
        msg.messg.parm[1],msg.messg.parm+1);
 for (i=0;i<nchars;i++)
    printf(" char %4.4d text %c hex %02.2x \n",
         i,msg.messg.mtext[i],msg.messg.mtext[i]);
}
        
if( errno != ENOMSG){
    perror("error clearing class buffers");
    exit(-1);
}

}
