/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <errno.h>      /* error code definition header file */
#include <sys/types.h>
#include <sys/ipc.h>    /* interprocess communications header file */
#include <sys/sem.h>    /* shared memory header file */
#include <stdlib.h>

#if defined(__GNU_LIBRARY__) && !defined(_SEM_SEMUN_UNDEFINED)
/* union semun is defined by including <sys/sem.h> */
#else
/* according to X/OPEN we have to define it ourselves */
   union semun
   {
     int val;                           /* value for SETVAL */
     struct semid_ds *buf;              /* buffer for IPC_STAT & IPC_SET */
     unsigned short int *array;         /* array for GETALL & SETALL */
     struct seminfo *__buf;             /* buffer for IPC_INFO */
   };
#endif

int semid_get( key, nsems, semid)
key_t   key;
int     nsems;
int     *semid;
{
int     i;
union semun arg;

                                          /* create, new key, permit all */
*semid = semget ( key, nsems, 0666|IPC_CREAT);
if ( *semid == -1 ) {
        perror("semid_get: create failed");
	return ( -1);
}
fprintf ( stdout, "semid_get: key=%d id=%d\n", key, *semid );

return( 0);
}

void semid_att( key, semid)
key_t key;
int   *semid;
{
   *semid = semget (key, 0, 0 );
   if ( *semid == -1 ) {
        perror("semid_att: translation failed");
        exit( -1);
   }
}

void semid_take( isem, semid)
int isem, semid;
{
   struct sembuf sb;

   sb.sem_num = isem;
   sb.sem_op  = -1;
   sb.sem_flg = SEM_UNDO;

   if( -1 == semop(semid,&sb,1)) {
      fprintf( stderr,"semid_take: isem %d ",isem);
      perror("take failed");
      exit( -1);
   }

}

int semid_nb( isem, semid)
int isem, semid;
{
   struct sembuf sb;
   int status;

   sb.sem_num = isem;
   sb.sem_op  = -1;
   sb.sem_flg = SEM_UNDO|IPC_NOWAIT;

   status = semop(semid,&sb,1);

   if( -1 == status && errno != EAGAIN) {
      fprintf( stderr,"semid_nb: isem %d ",isem);
      exit( -1);
   } else if (status == -1)
      return (-1);

   return ( 0);
}

void semid_put( isem, semid)
int isem, semid;
{
   struct sembuf sb;

   sb.sem_num = isem;
   sb.sem_op  = 1;
   sb.sem_flg = SEM_UNDO;
   if( -1 == semop(semid,&sb,1)) {
      fprintf( stderr,"semid_put: semid %d isem %d\n",semid,isem);
      perror("release failed");
      exit( -1);
   }
}

int semid_val( isem, semid)
int isem, semid;
{
   int status;

   if( -1 == ( status = semctl(semid,isem,GETVAL,0)) ) {
      fprintf( stderr,"semid_val: isem %d ",isem);
      perror("value get failed");
      exit( -1);
   }
   return (status);
}
void semid_set( isem, val, semid)
int isem, val,semid;
{
   union semun arg;

   arg.val=val;
   if( -1 == semctl( semid, isem,SETVAL,arg.val)) {
      fprintf( stderr,"semid_set: isem %d ",isem);
      perror("value set failed");
      exit( -1);
   }
   return;
}

int semid_rel( key, semid)
key_t key;
int *semid;
{
   *semid = semget (key, 0, 0 );
   if ( *semid == -1 ) {
        perror("semid_rel: translation failed");
        return ( -1);
   }

   if( -1 == semctl(*semid,0,IPC_RMID,0) ) {
      perror("semid_rel: release failed");
      return( -1);
   }
   return ( 0);
}
