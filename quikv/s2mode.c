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

char *arg_next( struct cmd_ds *command, int *last );

/* S2 mode SNAP command */
void s2mode( struct cmd_ds *command, int itask, long *ip )
{
 int   ierr = 0;
 int   i;
 int   last = 0;
 int   force;
 char *ptr;
 char  mode[21];
 char  output[MAX_OUT];

 char *parm = arg_next( command , &last );

 if( command->equal == '=' && parm ) /* Set mode */
   {
    force = 0;
    if( ( ptr = arg_next(command,&last) ) && !strcmp( ptr , "yes" ) )
       force =1;
 
    if( ierr = mode_set( "da" , parm , force ) )
       return s2err( ierr , ip  , "DA" );

    strcpy( shm_addr->s2das.mode , parm ); /* store in memory */

    cls_clr(ip[0]); ip[0]=ip[1]=0;
    return; 
   }
 if( command->equal == '=' ) /* display mode in memory */
   strcpy( mode , shm_addr->s2das.mode );
 else if( ierr = mode_read( "da" , mode ) )/*read mode from DAS */
    return s2err( ierr , ip  , "DA" );

 sprintf( output , "%s/%s" , command->name , mode );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}







