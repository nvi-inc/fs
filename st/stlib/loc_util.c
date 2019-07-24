#include <stdio.h>
#include <memory.h>
#include <errno.h>      /* error code definition header file */
#include <sys/types.h>  /* data type definition header file */
#include <sys/ipc.h>    /* interprocess communications header file */
#include <sys/shm.h>    /* shared memory header file */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/stcom.h"

#define BAD_ADDR    (char *)(-1)

static char *begin[MAX_PTS];
static char *start[MAX_PTS];
static int   chars[MAX_PTS];
static int shmid = 0;
struct stcom *loc_addr = NULL;

int loc_get( key, size)
key_t   key;
int     size;
{
struct	shmid_ds	str_shmid,  /* shared memory id struct */
			* buf;      /* shared memory id struct pointer */

buf = & str_shmid;  /* make buf point to str_shmid */

                                            /* create, new key, permit all */
shmid = shmget ( key, size, (IPC_CREAT|0666));
if ( shmid == -1 ) {
        perror("loc_get: allocating segment");
	return ( -1);
}

/* do a status on the shared memory segment */
if (-1 == shmctl ( shmid, IPC_STAT, buf )) {
        perror("loc_get: checking size");
        return( -1);
}
fprintf ( stdout, "loc_get: id=%d, size is %d bytes\n", shmid, buf->shm_segsz);

return( 0);
}

void loc_att( key)
key_t key;
{
   char  *shmat();

   shmid = shmget (key, 0, 0 );
   if ( shmid == -1 ) {
        perror("loc_att: translating key failed");
        exit( -1);
   }

   loc_addr = NULL;
   loc_addr = (struct stcom *) shmat ( shmid, loc_addr, 0 );
   if ( BAD_ADDR  == (char *) loc_addr ) {
	perror("loc_att: attaching memory segment failed");
	exit( -1);
   }
}

int loc_det( )
{
   if(-1==shmdt( (char *) loc_addr)) {
      perror("loc_det: detaching shared memory");
      return( -1);
   }
   return( 0);
}

int loc_rel( key)
key_t key;
{
   struct shmid_ds str_shmid, *buf;

   buf = &str_shmid;

   shmid = shmget (key, 0, 0 );
   if ( shmid == -1 ) {
        perror("loc_rel: translating key");
        return ( -1);
   }

   if ( -1 == shmctl ( shmid, IPC_RMID, buf )) {
        perror("loc_rel: removing id");
        return ( -1);
   }
   return( 0);
       
}

void loc_map(b_1,e_1,b_2,e_2)
int *b_1,*e_1,*b_2,*e_2;
{
   int   i;

   begin[0]=NULL;
   begin[1]=(char *) b_1;
   begin[2]=(char *) b_2;
   chars[0]=sizeof(Stcom);
   chars[1]=(e_1-b_1+1)*sizeof(int);
   chars[2]=(e_2-b_2+1)*sizeof(int);
   start[0]=(char *) loc_addr;
   for (i=1; i<MAX_PTS;i++)  {
       start[i]=start[i-1]+chars[i-1];
   }
}

void loc_read(b_read)
int *b_read;
{
    int i,ipts;
    char *s1;

    ipts=-1;
    for (i=1;i<MAX_PTS;i++) 
       if (((char *)b_read) == begin[i]) {
          ipts=i; break;}
    if(ipts == -1) {
      perror("loc_read: address lookup failed");
      exit( -1);
    }
    s1=memcpy((char *)b_read,start[ipts],chars[ipts]);
}

void loc_write(b_write)
int *b_write;
{
    int i,ipts;
    char *s1;

    ipts=-1;
    for (i=1;i<MAX_PTS;i++) 
       if (((char *)b_write) == begin[i]) {
          ipts=i; break;}
    if(ipts == -1) {
      perror("loc_write: address lookup failed");
      exit( -1);
    }
    s1=memcpy(start[ipts],(char *)b_write,chars[ipts]);
}
