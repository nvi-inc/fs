#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/rcl_das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  2048

static char code[3] = { DELAYM_READ, WVFDELAYM_READ, GPSDELAYM_READ };

/* S2 delay SNAP command */
void s2delay( struct cmd_ds *command , int itask , long *ip )
{
 int  err = 0;
 int  i;
 char output[MAX_OUT];
 long delay;
 char Txt[3][100];

 if( command->equal == '=' )
    return s2err( DELAY_BAD_PARM , ip , QDAS );

 for( i = 0 ; i < 3 ; i++ )
     if( ( err = delay_read( DAS , code[i] , &delay ) ) == ERR_NONE )
        sprintf( Txt[i] , "%ld" , delay );
     else
        sprintf( Txt[i] , "err(%d)" , err );

 sprintf( output , "%s/%s,%s,%s" , command->name
        , Txt[0] , Txt[1] , Txt[2] );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}




