#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <sys/time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

/* S2 ping SNAP command */

void s2ping(struct cmd_ds *command , int itask , long *ip )
{
 struct timeval t1, t2;
 char output[128];
 long dt;
 int  ierr;
 int  i;
 int  last = 0;
 char *device = arg_next( command , &last );

 if(  command->equal != '=' || !device )
    return s2err( PING_BAD_PARM , ip  , QDAS );

 gettimeofday( &t1 , 0 );
 if( ierr = ping( device ) )
    return s2err( ierr , ip  , device );
 gettimeofday( &t2 , 0 );

 dt = ( t2.tv_sec  - t1.tv_sec  ) * 1000
   + ( t2.tv_usec - t1.tv_usec  ) / 1000;

 for( i = 0 ; i < 5 ; i++ )
     ip[i] = 0;

 sprintf( output , "%s/%s,%d" , command->name , device , dt );
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;
}



