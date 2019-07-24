#include <stdio.h>
#include <memory.h>  /* data type definition header file */
#include <sys/types.h>

#include "../../fs/include/params.h"
#include "../../fs/include/fs_types.h"
#include "../../fs/include/fscom.h"

extern struct fscom *shm_addr;

void nsem_ini()
{
int i;
void sem_take(),sem_put();

sem_take( SEM_SEM);

shm_addr->sem.allocated=0;
/*for (i=0;i<MAX_SEM_LIST;i++) {
   shm_addr->sem.name[i][0]='\0';
   sem_set( i, 1);
}
*/

sem_put( SEM_SEM);
}
int nsem_take(name, flags)
char name[5];
int flags;
{
    int nsem_find(), isem, sem_nb();
    void sem_take();

    isem=nsem_find(name);
/*    printf("\n\n name %5.5s isem %d flags %d val %d\n\n",name,isem,flags,
     sem_val(isem));
*/

    if( flags == 0) {
       sem_take(isem);
       return( 0);
    } else
       return( sem_nb( isem)==0 ? 0: 1);
}
void nsem_put(name)
char name[5];
{
    int nsem_find(), sem_val(), isem;
    void sem_put();

    isem=nsem_find(name);

    if(sem_val( isem) < 1) sem_put( isem);

    return;
}    
int nsem_test(name)
char name[5];
{
    int nsem_find(), sem_val(), isem;
    void sem_put();

    isem=nsem_find(name);

    return (sem_val(isem)==0? 1:0);
}    
static int nsem_find( name)
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
      if (shm_addr->sem.allocated<MAX_SEM_LIST ) {
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
