#include <stdio.h>	/* standard I/O header file */
#include <stdlib.h>
#include <limits.h>     /* limits header file */
#include <errno.h>	/* error number definitions */
#include <memory.h>    /* shared memory IPC header file */
#include <sys/types.h>
#include <sys/ipc.h>	/* interprocess communications (IPC) header file */
#include <sys/msg.h>	/* message IPC header file */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define MAX_TEXT  2048

struct  cls_buf {
	long	mtype;
        struct {
          int     parm[2];
          unsigned char    mtext[ MAX_TEXT];
        } messg;
} ;

static int msqid;

static long cls_alc_s();
static int cls_chk();

int cls_get( key, size)
key_t key;
int size;
{
struct msqid_ds str_msqid;  /* message queue id struct */

msqid = msgget( key, ( IPC_CREAT | 0666 ));
if ( msqid == -1 ) {
        perror("cls_get: creating cls queue");
	return( -1);
}

/* set the queue size */
if( -1 == msgctl( msqid, IPC_STAT, &str_msqid )) {
        perror("cls_get: getting status");
	return( -1);
}
str_msqid.msg_qbytes = size;
if( -1 == msgctl( msqid, IPC_SET, &str_msqid )) {
        perror("cls_get: setting status");
	return( -1);
}

fprintf( stdout,"cls_get: id %d\n",msqid);

return( 0);
}
void cls_ini( key)
key_t key;
{
int	status, i;
long    msgtype;
void    sem_take(),sem_put();
struct  cls_buf msg;

msqid = msgget( key, 0);
if ( msqid == -1 ) {
        perror("cls_ini: translating key");
	exit( -1);
}

while ( -1 !=
 msgrcv( msqid, (struct msgbuf *) &msg, sizeof( msg.messg ), -LONG_MAX,
	IPC_NOWAIT|MSG_NOERROR));
if( errno != ENOMSG){
    perror("cls_ini: error cleaning class numbers");
    exit(-1);
}
sem_take( SEM_CLS); /* hold the semaphore if and *only* if:
                       i) manipulatig the class database directly
                       ii) when calling cal_alc_s()
                       iii) when call cls_chk()
		    */

for (i=0;i<MAX_CLS;i++)
    shm_addr->nums[i]=0;
shm_addr->class_count=0;

sem_put( SEM_CLS);
}
void cls_att( key)
key_t key;
{
   msqid = msgget( key, 0);
   if ( msqid == -1 ) {
        perror("cls_ini: translating key");
	exit( -1);
   }
}

void cls_snd( class, buffer, length , parm3, parm4)
long    *class;		/* message queue id in which to place buffer */
char	*buffer;	/* contains message for process */
int	length;	/* length of buffer in bytes */
int     parm3;
int     parm4;
{
int	status, i;
size_t  nchars;
struct  cls_buf msg;
long    msgtype;
char    *s1;
void sem_take(), sem_put();

  if(length > MAX_TEXT) {
    length=MAX_TEXT;
  } else if(length < 0)
    length=0;

   *class &= ~ 0160000;
   sem_take( SEM_CLS);
   if(*class == 0)
     if( 0 > (*class = cls_alc_s())){
       fprintf(stderr,"cls_alc_s error in cls_snd()\n");
       exit (-1);
     }
   if(cls_chk( *class, 1,0)) {
     fprintf(stderr,"cls_chk error in cls_snd()\n");
     exit(-1);
   }
   sem_put( SEM_CLS);

msg.mtype = *class;
msg.messg.parm[0]=parm3;
msg.messg.parm[1]=parm4;
s1=memcpy( msg.messg.mtext, buffer, length);
status = msgsnd( msqid, (struct msgbuf *) &msg,
		length+sizeof( msg.messg.parm), 0);
if ( status == -1 ) {
    perror("cls_snd: sending message");
    exit(-1);
}
}

long cls_alc()
{
long    class;
void    sem_take(), sem_put();

sem_take( SEM_CLS);
class=cls_alc_s();
sem_put( SEM_CLS);
return( class);
}
static long cls_alc_s()
{
int	i;
long    class;
int    imod;

  class=0;
  for (i=0;i<MAX_CLS;i++) {

    /* work cyclically through class numbers:
       class_count is most recently allocated class number
       nums[class-1] is the number of references:
                     = 0 == unallocated
                     = 1 == allocated
                     > 1 == nums[]-1 is outstanding buffers or receives
    */

    imod=(shm_addr->class_count+i)%MAX_CLS;
    if (shm_addr->nums[imod] == 0) {
       class=imod+1;
       shm_addr->nums[imod]=1;
       shm_addr->class_count=(imod+1)%MAX_CLS;
       break;
     }
  }

  if(class == 0) {
     fprintf( stderr,"cls_alc_s: out of class numbers\n");
     return -1;
  }
  return( class);
}

int cls_rcv( class, buffer, length, rtn1, rtn2, msgflg, save)
int	length, *rtn1, *rtn2, msgflg, save;
long	class;
char	*buffer;
{
int     nchars, sb, sc, nw;
struct  cls_buf msg;
char *s1;
void sem_take(), sem_put();

   sb= 0040000 & class;
   sc= 0020000 & class;
   nw= 0100000 & class;
   class &= ~ 0160000;
   if(msgflg != 0 || nw) msgflg=IPC_NOWAIT;
   if(save   != 0 || sc) save = 1;
   
   nchars = msgrcv( msqid, (struct msgbuf *) &msg, sizeof( msg.messg),
		   class+MAX_CLS,IPC_NOWAIT);
   if ( (nchars == -1) && (errno != ENOMSG)) {
      fprintf( stderr,"cls_rcv: msqid %d class %d,",msqid,class);
      perror("getting saved class");
      exit(-1);
   } else if (nchars != -1) {
     goto copy;
   }

   if(msgflg==0) {
     sem_take( SEM_CLS);
     if(cls_chk( class, 1, 0)) {
	fprintf(stderr,"cls_chk error 1 in cls_rcv()\n");
	exit(-1);
     }
      sem_put(SEM_CLS);
   }

   nchars = msgrcv( msqid, (struct msgbuf *) &msg, sizeof( msg.messg ),
		   class, msgflg);
   if ( (nchars == -1) && (errno != ENOMSG)) {
      fprintf( stderr,"cls_rcv: msqid %d class %d,",msqid,class);
      perror("getting class");
      exit(-1);
   } else if (nchars == -1) {
     return( -1);
   }
   if(msgflg==0) {
     sem_take( SEM_CLS);
     if(cls_chk( class, -1, save)) {
       fprintf(stderr,"cls_chk error 2 in cls_rcv()\n");
       exit(-1);
     }
     sem_put( SEM_CLS);
   }
copy:
   if( sb ) {
      msg.mtype = class + MAX_CLS;
      if ( -1 == msgsnd( msqid, (struct msgbuf *) &msg, nchars, 0)) {
         perror("cls_rcv: sending saved message");
         exit(-1);
      }
   } else {
     sem_take( SEM_CLS);
     if( cls_chk( class, -1, save)) {
	fprintf(stderr,"cls_chk error 3 in cls_rcv()\n");
	exit(-1);
     }
     sem_put( SEM_CLS);
   }

   *rtn1=msg.messg.parm[0];
   *rtn2=msg.messg.parm[1];

   nchars=nchars-sizeof(msg.messg.parm);
   nchars=(nchars > length) ? length:nchars;
   s1=memcpy(buffer, msg.messg.mtext, nchars);

   return(nchars);
}

void cls_clr( class)
long    class;
{
struct  cls_buf msg;
void sem_take(), sem_put();

   class &= ~ 0160000;
   if(class<=0) return;

while ( -1 !=
 msgrcv( msqid, (struct msgbuf *) &msg, sizeof( msg.messg ), class,
	IPC_NOWAIT|MSG_NOERROR));
if( errno != ENOMSG){
    perror("cls_clr: error clearing class buffers");
    exit(-1);
}

while ( -1 !=
msgrcv(msqid,(struct msgbuf *) &msg,sizeof( msg.messg), class+MAX_CLS,
       IPC_NOWAIT|MSG_NOERROR));
if( errno != ENOMSG){
    perror("cls_clr: error clearing saved class buffers");
    exit(-1);
}

 sem_take( SEM_CLS);

  shm_addr->nums[ class-1]=0;

  sem_put( SEM_CLS);
}

int cls_rel( )
{
if(-1==msgctl( msqid, IPC_RMID, NULL )) {
      perror("cls_rel: release cls queue");
      return(-1);
 }
 return (0);
}

static int cls_chk( class, action, save)
long class;
int action, save;
{

  if (class <1 || class > MAX_CLS) {
    /*
    int i;
    for(i=0;i<MAX_CLS;i++)
      fprintf( stderr, "class %d num %x\n",i, shm_addr->nums[ i]);
      */
    fprintf( stderr,"cls_chk: illegal class number %d pid %d\n",class,getpid());
     return -1;
  }

  if (shm_addr->nums[ class-1] == 0) {
    /*
    int i;
    for(i=0;i<MAX_CLS;i++)
      fprintf( stderr, "class %d num %x\n",i, shm_addr->nums[ i]);
      */
    fprintf( stderr,"cls_chk: class %d not allocated\n",class);
    return -1;
  }
   shm_addr->nums[class-1]+= action;
  if(shm_addr->nums[class-1] < 1) {
    /*
    int i;
    for(i=0;i<MAX_CLS;i++)
      fprintf( stderr, "class %d num %x\n",i, shm_addr->nums[ i]);
    */
    fprintf( stderr,"cls_chk: class %d decremented too far\n",class);
    return -1;
  } else if ( shm_addr->nums[class-1] == 1 && save == 0) {
    shm_addr->nums[class-1]=0;
  }

  return 0;
}
