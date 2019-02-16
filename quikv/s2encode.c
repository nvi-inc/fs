#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  2048

/* S2 encode SNAP command */
void s2encode( struct cmd_ds *command , int itask , int *ip )
{
 char output[MAX_OUT];
 char *parm;
 char scheme;
 int  ierr = 0;
 int  i;
 int last = 0;

 if( command->equal == '=' && ( parm = arg_next(command,&last) ) )
   { /* Set encode */
    if( !str2encode( parm , &scheme ) )
       return s2err( ENCODE_BAD_SCHEME , ip , QDAS );

    if( ierr = encode_set( DAS , scheme ) )
       return s2err( ierr , ip , EDAS );
    shm_addr->s2das.encode = scheme; /* store in memory */

    cls_clr(ip[0]); ip[0]=ip[1]=0;
    return;
   }
 else if( !parm ) /* display value in memory */
   scheme = shm_addr->s2das.encode;
 else if( ierr = encode_read( DAS , &scheme) ) /* Read encode scheme */
    return s2err( ierr , ip , EDAS );

 sprintf( output , "%s/%s" , command->name , encode2str( scheme ) );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}








