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

/* S2 agc SNAP command */
void s2agc( struct cmd_ds *command , int itask , long *ip )
{
 int  ierr = 0;
 int  i, last = 0;
 char code, *parm;
 char output[MAX_OUT];

 if( command->equal == '=' && ( parm = arg_next(command,&last) ) )
   {
    if( !str2agc( parm , &code ) || !code )
       return s2err( AGC_BAD_MODE , ip , QDAS );

    if( ierr = agc_set( DAS , code ) )
       return s2err( ierr , ip , EDAS );

    shm_addr->s2das.agc = code; /* store in memory */

    cls_clr( ip[0] ); ip[0]=ip[1]=0;
    return;
   }
 else if( !parm ) /* display value in memory */
    code = shm_addr->s2das.agc;
 else if( ierr = agc_read( DAS , &code) ) /* Read encode scheme */
    return s2err( ierr , ip , EDAS );

 sprintf( output , "%s/%s" , command->name , agc2str( code ) );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}




