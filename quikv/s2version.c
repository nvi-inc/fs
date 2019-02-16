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
#define ATTN_MAX   30

/* S2 mode SNAP command */
void s2version( struct cmd_ds *command , int task , int *ip )
{
 int   ierr = 0;
 char  id[61], ver[61];
 char  output[MAX_OUT];
 int   i, rec;
 int   last = 0;
 char *device = arg_next( command , &last );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;

 if( command->equal != '=' || !device || strlen( device) < 2 )
    return s2err( INFO_BAD_PARM , ip  , QDAS );

 if( ierr = ident( device , id ) )
    return s2err( ierr , ip , device );
 if( ierr = version( device , ver ) )
    return s2err( ierr , ip  , device );

 sprintf( output , "%s/%s,%s" , command->name , id , ver );
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;
}







