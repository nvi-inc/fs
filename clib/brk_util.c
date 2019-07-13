#include <stdio.h>	/* standard I/O header file */
#include <errno.h>	/* error number definitions */
#include <limits.h>
#include <signal.h>
#include <sys/types.h>	/* standard data types definitions */
#include <sys/ipc.h>	/* interprocess communications (IPC) header file */
#include <sys/msg.h>	/* message IPC header file */
#include <sys/shm.h>    /* shared memory IPC header file */
#include <memory.h>    /* shared memory IPC header file */
#include <ctype.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

static int mtype();

struct brk_buf {
	long	mtype;
} ;

static int msqid;

int brk_get( key, size)
key_t key;
int size;
{
struct msqid_ds	str_msqid;  /* message queue id struct */

/* create a message queue */
msqid = msgget( key, ( IPC_CREAT | 0664 ));
if ( msqid == -1 ) {
    perror("brk_get: getting queue");
    return( -1);
}

/* set the queue size */
if (-1== msgctl( msqid, IPC_STAT, &str_msqid )) {
    perror("brk_get: getting status");
    return( -1);
}

str_msqid.msg_qbytes = size;
if(-1 == msgctl( msqid, IPC_SET, &str_msqid )) {
    perror("brk_get: setting size");
    return( -1);
}
fprintf( stdout,"brk_get: id %d\n",msqid);

return( 0);
}

void brk_ini( key)
key_t key;
{
struct brk_buf brbuf;

msqid = msgget( key, 0);

if ( msqid == -1 ) {
    perror("brk_ini: translating key");
    exit( -1);
}

while ( -1 !=
msgrcv( msqid, (struct msgbuf *) &brbuf, 0, -LONG_MAX,IPC_NOWAIT|MSG_NOERROR));
if( errno != ENOMSG){
    perror("brk_ini: error cleaning brk queue\n");
    exit(-1);
}

}

void brk_att( key)
key_t key;
{
    msqid = msgget( key, 0);
    if ( msqid == -1 ) {
        perror("brk_att: translating key");
        exit( -1);
    }
}
void brk_snd( name)
char	name[5];	
{
int	i;
struct brk_buf brbuf;

brbuf.mtype=mtype(name);

if ( -1 == msgsnd( msqid, (struct msgbuf *) &brbuf, 0, 0 ) ) {
       fprintf( stderr,"brk_run: msqid %d,",msqid);
        perror(" sending break message");
        exit( -1);
}
}
int brk_chk( name)
char    name[ 5];
{
int	status, ret;
struct brk_buf	brbuf;
int    type;

type=mtype(name);

ret = FALSE;

while (TRUE) {
   status = msgrcv( msqid, (struct msgbuf *) &brbuf, 0, type, IPC_NOWAIT);
   
   if (status != -1 ) ret=TRUE;
   else if (status == -1 && errno == EINTR) ;
   else if ( status == -1 && errno !=ENOMSG) {
        perror("brk_chk: receiving message");
	exit( -1);
   } else return(ret); 

   }
}
int brk_rel( )
{
int status;
/* release specified shared memory segment */
if(-1==msgctl( msqid, IPC_RMID, NULL )) {
   perror("brk_rel: releasing brk id");
   return( -1);
}
return( 0);
}

static int mtype(name)
char name[5];
{
    int i;
    int val;

    val=0;
    for (i=0;i<5;i++) if(name[i] != ' ') val+=(tolower(name[i])-'a')<<(5*i);
    return(val);
}
