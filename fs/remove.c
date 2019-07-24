#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

main()
{
   struct shmid_ds *buf, str;

   int err;
   buf=&str;

   err=shmctl ( 300, IPC_RMID, buf );
   fprintf ( stderr," error return %d\n", err);
   if(err==-1) perror("");
}
