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

/* --------------------------------------------------------------------------*/
/* S2 status SNAP command */
void s2status( struct cmd_ds *command , int itask , int *ip )
{
 int  ierr = 0;
 int  rec  = 0;
 int  last = 0;
 int  i;
 char *CR;
 char summary, nbr;
 char output[MAX_OUT], ErrCode[10], fs_state;
 char code = 0; /* read brief status report */
 char reread = 0;
 char id = 0;
 char *parm = arg_next( command , &last );
 S2_STATUS list[32];

 if( command->equal == '=' ) /* detail status */
   {
    if( !parm )
       return s2err( STATUS_BAD_PARAM , ip , "DQ" );
    else if( !strcmp( parm , "brief" ) )
       code = 0;
    else if( !strcmp( parm , "long" ) )
       code = 1;
    else if( !strcmp( parm , "short" ) )
       code = 2;
    else
       return s2err( STATUS_BAD_PARAM , ip , "DQ" );

    if( code > 0 && ( parm = arg_next( command , &last ) ) )
      {
       if( ( id = (char)atoi( parm ) ) < 0 )
          return s2err( STATUS_BAD_PARAM , ip , "DQ" );
      
       if( parm = arg_next( command , &last ) )
          reread = ( strcmp( parm , "read" ) == 0 );
      }
   }

 /* Read encode scheme */
 if( ierr = status_read( "da", id, code, reread, &summary , &nbr , list ) )
    return s2err( ierr , ip , "DA" );

 rec = 0;
 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 if( nbr == 0 ) /*( ( summary & 0x01 ) != 0x01 ) )*/
   {
    sprintf( output , "%s/no S2-DAS error conditions" , command->name );
    cls_snd(ip,output,strlen(output),0,0);
    rec = 1;
   }
 else if( code == 0 )
   {
    sprintf( output , "%s/S2-DAS status codes: " , command->name );
    for( i = 0 ; i < nbr ; i++ )
       {
        sprintf( ErrCode , "%s%d" , i == 0 ? "" : "," , list[i].code );
        strcat( output , ErrCode );
       }        
    cls_snd(ip,output,strlen(output),0,0);
    rec = 1;
   }
 else
   {
    rec = 0;
    for( i = 0 ; i < nbr ; i++ , rec++ )
       {
        unsigned char type = (unsigned char)list[i].type;
        sprintf( output , "%s/%02d,%s%s%s,%s", command->name
               , list[i].code
               , ( type & 0x01 ) == 0x01 ? "E" : "-"
               , ( type & 0x02 ) == 0x02 ? "F" : "-"
               , ( type & 0x04 ) == 0x04 ? "C" : "-"
               , list[i].report );
        cls_snd(ip,output,strlen(output),0,0);
       }
   }
 ip[1] = rec;

 return;
}
/* --------------------------------------------------------------------------*/
void s2decode(struct cmd_ds *command , int itask , int *ip )
{
 int  ierr = 0;
 int  i;
 int  last = 0;
 char message[400];
 char output[MAX_OUT];
 char code;
 char type = 0x01; /* short message */
 char *CR;
 char *parm;

 if( command->equal != '=' || !( parm = arg_next(command,&last) ) )
    return s2err( MSG_BAD_PARAM , ip , "DQ" );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;

 code = (char)atoi( parm );
 if( parm = arg_next( command , &last ) )
    if( !strcmp( parm , "short" ) )
       type = 0x01;
    else if( !strcmp( parm , "long" ) )
       type = 0x00;
    else
       return s2err( MSG_BAD_PARAM , ip , "DQ" );

 /* Read  */
 if( itask == 1 ) /* decode status code */
   {
    if( ierr = status_decode("da",code,type,message) )
       return s2err( ierr , ip , "DA" );
   }
 else /* decode error code */
   {
    if( ierr = error_decode( "da",code,message) )
       return s2err( ierr , ip , "DA" );
   }
 if( CR = strchr( message , '\n' ) ) *CR = '\0';
 sprintf( output , "%s/%s" , command->name , message );
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}
/* --------------------------------------------------------------------------*/







