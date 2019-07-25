#include <stdio.h>
#include <errno.h>      /* error code definition header file */
#include <sys/types.h>
#include <sys/ipc.h>    /* interprocess communications header file */
#include <sys/sem.h>    /* shared memory header file */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define BAD_ADDR    (char *)(-1)

static int semid = 0;

/*
union semun {
      int val;
      struct semid_ds *buf;
      ushort *array;
};
*/

int sem_get( key, nsems)
key_t   key;
int     nsems;
{
int     i;
union semun arg;

                                          /* create, new key, permit all */
semid = semget ( key, nsems, 0666|IPC_CREAT);
if ( semid == -1 ) {
        perror("sem_get: create failed");
	return ( -1);
}
arg.val=1;
for (i=0;i<nsems;i++) {
    if( -1 == semctl( semid, i,SETVAL,arg.val)) {
        fprintf( stderr,"sem_get, setting sem %d ",i);
        perror("failed");
        return( -1);
    }
}
fprintf ( stdout, "sem_get: id=%d\n", semid );

return( 0);
}

void sem_att( key)
key_t key;
{
   semid = semget (key, 0, 0 );
   if ( semid == -1 ) {
        perror("sem_att: translation failed");
        exit( -1);
   }
}

void sem_take( isem)
int isem;
{
   struct sembuf sb;

   sb.sem_num = isem;
   sb.sem_op  = -1;
   sb.sem_flg = SEM_UNDO;
   if( -1 == semop(semid,&sb,1)) {
      fprintf( stderr,"sem_take: isem %d ",isem);
      perror("take failed");
      exit( -1);
   }
}

int sem_nb( isem)
int isem;
{
   struct sembuf sb;
   int status;

   sb.sem_num = isem;
   sb.sem_op  = -1;
   sb.sem_flg = SEM_UNDO|IPC_NOWAIT;
   status = semop(semid,&sb,1);
   if( -1 == status && errno != EAGAIN) {
      fprintf( stderr,"sem_nb: isem %d ",isem);
      perror("nb take failed");
      exit( -1);
   } else if (status == -1)
      return (-1);

   return ( 0);
}

void sem_put( isem)
int isem;
{
   struct sembuf sb;

   sb.sem_num = isem;
   sb.sem_op  = 1;
   sb.sem_flg = SEM_UNDO;
   if( -1 == semop(semid,&sb,1)) {
      fprintf( stderr,"sem_put: isem %d ",isem);
      perror("release failed");
      exit( -1);
   }
}

int sem_val( isem)
int isem;
{
   int status;

   if( -1 == ( status = semctl(semid,isem,GETVAL,0)) ) {
      fprintf( stderr,"sem_val: isem %d ",isem);
      perror("value get failed");
      exit( -1);
   }
   return (status);
}
void sem_set( isem, val)
int isem, val;
{
   union semun arg;

   arg.val=val;
   if( -1 == semctl( semid, isem,SETVAL,arg.val)) {
      fprintf( stderr,"sem_set: isem %d ",isem);
      perror("value set failed");
      exit( -1);
   }
   return;
}

int sem_rel( key)
key_t key;
{
   semid = semget (key, 0, 0 );
   if ( semid == -1 ) {
        perror("sem_rel: translation failed");
        return ( -1);
   }

   if( -1 == semctl(semid,0,IPC_RMID,0) ) {
      perror("sem_rel: release failed");
      return( -1);
   }
   return ( 0);
}
