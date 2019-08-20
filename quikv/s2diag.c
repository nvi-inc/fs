#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

/* S2 diag SNAP command */

void s2diag(struct cmd_ds *command , int itask , int *ip )
{
 int   ierr, code;
 char *parm = 0;
 int   last = 0;

 if(    command->equal != '='
    || !( parm = arg_next(command,&last) )
   )
    return s2err( DIAG_BAD_PARM , ip , QDAS );

 if( !strcmp( parm , "self1" ) )
    code = 1;
 else
    return s2err( DIAG_BAD_PARM , ip , QDAS );

 if( ierr = diag( DAS , 1 ) )
    return s2err( ierr , ip , EDAS );

 cls_clr( ip[0] ); ip[0] = ip[1] = 0;
}







