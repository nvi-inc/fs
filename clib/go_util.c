#include <stdio.h>
#include <memory.h>  /* data type definition header file */
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

static int semid = 0;

static int go_find();

int go_get( key, nsems)
key_t   key;
int     nsems;
{
  void sem_take(),sem_put();
  int iret, i;

  sem_take( SEM_GO);

  shm_addr->sem.allocated=0;

  iret=semid_get( key, nsems, &semid);

  if(iret != -1)
    for (i=0;i<nsems;i++)
      semid_set( i, 0, semid);

  sem_put( SEM_GO);

  return(iret);
}
void go_att( key)
key_t key;
{
  semid_att(key,&semid);
}

int go_take(name, flags)
char name[5];
int flags;
{
    int isem, semid_nb();
    void semid_take();

/*    printf("go_take enter, name %5.5s flags %d \n",name,flags); */
    isem=go_find(name);
/*    printf("isem %d val %d\n",isem, semid_val(isem, semid));*/


    if(semid_val( isem, semid) > 0) semid_set( isem, 0, semid);
    if( flags == 0) {
       semid_take(isem, semid);
       return( 0);
    } else {
       int iret;
       iret=semid_nb( isem, semid)==0 ? 0: 1;
       return iret;
     }
}
void go_put(name)
char name[5];
{
    int  isem;
    void semid_put();

     isem=go_find(name);

    semid_put( isem, semid);
    return;
}    
int go_test(name)
char name[5];
{
    int semid_val(), isem, iret;

/*    printf(" name %5.5s\n",name);*/

    isem=go_find(name);

/*    printf(" isem %d\n",isem); */

    iret=semid_val(isem, semid)==0? 1:0;

    return (iret);
}    
static int go_find( name)
char name[5];
{
    void sem_take(), sem_put();
    int i, isem;

    sem_take( SEM_GO);

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
    sem_put( SEM_GO);

    return( isem);
}

int go_rel( key)
key_t key;
{
  return(semid_rel( key, &semid));
}

