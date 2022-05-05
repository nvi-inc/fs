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
#include <memory.h>  /* data type definition header file */
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

static int semid = 0;

int nsem_find();

int nsem_get( key, nsems)
key_t   key;
int     nsems;
{
  void sem_take(),sem_put();
  int iret,i;

  sem_take( SEM_SEM);

  shm_addr->sem.allocated=0;

  iret=semid_get( key, nsems, &semid);

  if(iret != -1)
    for(i=0;i<nsems;i++)
      semid_set(i,1,semid);

  sem_put( SEM_SEM);

  return(iret);
}
void nsem_att( key)
key_t key;
{
  semid_att(key,&semid);
}

int nsem_take(name, flags)
char name[5];
int flags;
{
    int nsem_find(), isem, semid_nb();
    void semid_take();

/*    printf("nsem_take enter, name %5.5s flags %d \n",name,flags); */
    isem=nsem_find(name);
/*    printf("isem %d val %d\n",isem, semid_val(isem, semid));*/


    if( flags == 0) {
       semid_take(isem, semid);
       return( 0);
    } else {
       int iret;
       iret=semid_nb( isem, semid)==0 ? 0: 1;
       return iret;
     }
}
void nsem_put(name)
char name[5];
{
    int nsem_find(), semid_val(), isem;
    void semid_put();

    isem=nsem_find(name);

    if(semid_val( isem, semid) < 1) semid_put( isem, semid);

    return;
}    
int nsem_test(name)
char name[5];
{
    int nsem_find(), semid_val(), isem, iret;

/*    printf(" name %5.5s\n",name);*/

    isem=nsem_find(name);

/*    printf(" isem %d\n",isem); */

    iret=semid_val(isem, semid)==0? 1:0;

    return (iret);
}    
int nsem_find( name)
char name[5];
{
    void sem_take(), sem_put();
    int i, isem;

    sem_take( SEM_SEM);

/*  printf(" name %5.5s allocated %d\n",name,shm_addr->sem.allocated);*/
    isem = -1;

    for (i=0; i<shm_addr->sem.allocated && isem == -1; i++) {
/*     printf(" i %d sem.name %5.5s\n",i,shm_addr->sem.name[i]);*/
       if(0==memcmp(shm_addr->sem.name[i],name,5)) {
          isem=i;
       }
    }

/*  printf(" isem %d\n",isem); */
    if( isem == -1 )
      if (shm_addr->sem.allocated<SEM_NUM ) {
         isem=(shm_addr->sem.allocated)++;
         (void) memcpy(shm_addr->sem.name[isem],name,5);
      } else {
         fprintf( stderr," not enough semaphores for %5.5s\n",name);
         exit( -1);
      }

/*   printf(" ending isem %d allocated %d name %5.5s\n",
            isem,shm_addr->sem.allocated,shm_addr->sem.name[isem]);*/
    sem_put( SEM_SEM);

    return( isem);
}

int nsem_rel( key)
key_t key;
{
  return(semid_rel( key, &semid));
}

