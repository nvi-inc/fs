#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT   2048
#define NBR_DEV      7
#define ERR_DEVNP  -14

char *arg_next( struct cmd_ds *command, int *last );

static char *board[] = {"all","clk","ifx","bbc1","bbc2","bbc3","bbc4"};

/* --------------------------------------------------------------------------*/
char *volts2str( unsigned short value )
{
 static char string[100];

 if( value != 0xffff )
    sprintf( string , "%.2lf" , (double)( value / 100.0 ) );
 else
    strcpy( string , "na" );

 return string; 
}
/* --------------------------------------------------------------------------*/
int validate_board( char *string , int *start , int *end )
{
 int  i;

 if( !string || *string == '\0' || !strcmp( string , board[0] ) )
   { *start = 0; *end = 7; return 7; }

 for( i = 1 ; i < NBR_DEV ; i++ )
     if( !strcmp( string , board[i] ) )
       { *start = i; *end   = i + 1; return 1; }

 return 0; /* error */
}
/* --------------------------------------------------------------------------*/
/* S2 powermon SNAP command */
void s2pwrmon( struct cmd_ds *command , int itask , long *ip )
{
 unsigned short voltage[12];
 char output[MAX_OUT];
 int  ierr  = 0;
 int  start = 0;
 int  end   = 4;
 int  nrec  = 0;
 int  ndev  = 0;
 int  i, j;
 int last = 0;

 for( i = 0 ; i < 5 ; i++ )
     ip[i] = 0;

 if( !( ndev = validate_board( arg_next(command,&last) , &start , &end ) ) )
    return s2err( PWR_BAD_VALUE , ip  , "DQ" );
    
 /* Read voltages values for specific module */
 for( i = start ; i < end ; i++ , ierr = 0 )
    {
     if(   ((ierr=powermon_read("da",(char)i,voltage)) && ierr != ERR_DEVNP)
        || (  ierr == ERR_DEVNP && ndev == 1 )
       )
        break;

     if( ierr == ERR_DEVNP ) continue;

     sprintf( output , "%s/%s" , command->name , board[i] );
     for( j = 0 ; j < 12 ; j++ )
        {
         strcat( output , "," );
         strcat( output , volts2str( voltage[j] ) );
        }
     cls_snd(ip,output,strlen(output),0,0);
     nrec++;
    }

 if( ierr != 0 )
   {
    if( ip[0] ) cls_clr( ip[0] );
    return s2err( ierr , ip  , "DA" );
   }

 ip[1] = nrec;
 ip[2] = ierr;
 return;
}







