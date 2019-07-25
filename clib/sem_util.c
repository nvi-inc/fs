#include <sys/types.h>
#include <sys/ipc.h>    /* interprocess communications header file */
#include <sys/sem.h>    /* shared memory header file */

static int semid = 0;

int sem_get( key, nsems)
key_t   key;
int     nsems;
{
  int iret, i;

  iret=semid_get( key, nsems, &semid);

  if(iret != -1)
    for (i=0;i <nsems; i++)
      semid_set(i,1,semid);

  return iret;
}
void sem_att( key)
key_t key;
{
  semid_att(key,&semid);
}

void sem_take( isem)
int isem;
{
  semid_take( isem, semid);
}
int sem_nb( isem)
int isem;
{
  return (semid_nb( isem, semid));
}

void sem_put( isem)
int isem;
{
  semid_put( isem, semid);
}

int sem_val( isem)
int isem;
{
  return(semid_val( isem, semid));
}

void sem_set( isem, val)
int isem, val;
{
  semid_set( isem, val, semid);
}

int sem_rel( key)
key_t key;
{
  return(semid_rel( key, &semid));
}
