#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

/* --------------------------------------------------------------------------*/
#define MAX_OUT 2048

static char old[4]  = {-128,-128,-128,-128};
static char ATTN[4] = {-128, -128, -128, -128 };
static char SRC[4]  = {-128, -128, -128, -128 };
static unsigned short TPIavg = 0;

char *tpi2str( unsigned long tpi )
{
 static char txt[20];
 sprintf( txt , "%u" , tpi );
 return txt;
}
/* --------------------------------------------------------------------------*/
/* S2 ifx SNAP command */
void s2ifx( struct cmd_ds *command, int id, long *ip )
{
 unsigned long  tpi[4];
 unsigned short tpiavg;
 char state, period, attn[4], src[4];
 char output[MAX_OUT];
 int  ierr = 0;
 int  nrec = 0;
 int  i;
 int  last = 0;
 char *parm = arg_next( command , &last );

 if( command->equal != '='
    || ( parm && !strcmp(parm,"state") )
   )
   { /* read ifx values */
    if( !str2state( arg_next(command,&last) , &state ) )
       return s2err( IFX_BAD_STATE , ip , QDAS  );

    if( ierr = ifx_read(DAS,&state,attn,src,&tpiavg,tpi) )
       return s2err( ierr , ip , EDAS );

    sprintf( output , state ? "%s:%d/" : "%s/" , command->name , state );
    for( i = 0 ; i < 4 ; i++ )
       {
        strcat( output , attn2str( attn[i] ) );
        strcat( output , "," );
       }
    for( i = 0 ; i < 4 ; i++ )
       {
        strcat( output , src2str( src[i] ) );
        strcat( output , "," );
       }
    strcat( output , tpiavg2str( tpiavg ) );
    for( i = 0 ; i < 4 ; i++ )
       {
        strcat( output , "," );
        strcat( output , src[i] == -128 ? "na" : tpi2str( tpi[i] ) );
       }

    for( i = 0 ; i < 5 ; i++ )
        ip[i] = 0;
    cls_snd(ip,output,strlen(output),0,0);
    ip[1] = 1; /* one record only */
    return;
   }
 else if( !parm )
   {
    sprintf( output , "%s/" , command->name );
    for( i = 0 ; i < 4 ; i++ )
       {
        strcat( output , attn2str( ATTN[i] ) );
        strcat( output , "," );
       }
    for( i = 0 ; i < 4 ; i++ )
       {
        strcat( output , src2str( SRC[i] ) );
        strcat( output , "," );
       }
    strcat( output , tpiavg2str( TPIavg ) );

    for( i = 0 ; i < 5 ; i++ )
        ip[i] = 0;
    cls_snd(ip,output,strlen(output),0,0);
    ip[1] = 1; /* one record only */
    return;
   }
 /* check attenuation values */
 for( i = 0 ; i < 4 ; i++ , parm = arg_next( command , &last ) )
     if( !str2attn( parm , attn + i , old + i ) )
        return s2err( IFX_BAD_ATTN , ip , QDAS );
 /* check input source codes */
 for( i = 0 ; i < 4 ; i++ , parm = arg_next( command , &last ) )
     if( !str2src( parm , src + i ) )
        return s2err( IFX_BAD_SRC , ip , QDAS );
 /* check averaging period */
 if( !str2tpiavg( parm , &tpiavg ) )
    return s2err( IFX_BAD_TPIAVG , ip , QDAS );
    
 if( ierr = ifx_set( DAS , attn , src , tpiavg ) )
    return s2err( ierr , ip , EDAS );

 for( i = 0 ; i < 4 ; i++ )
    {
     if( attn[i] != -128 ) ATTN[i] = attn[i];
     if( src[i]  != -128 ) SRC[i]  =  src[i];
    }
 if( tpiavg != 0 )TPIavg = tpiavg;

 /* read old values if ifadjust was used */
 for( i = 0 ; i < 4 ; i++ )
     if( attn[i] == -127 )
       {
        ifx_read(DAS,&state,old,src,&tpiavg,tpi);
        break;
       }
 cls_clr(ip[0]); ip[0]=ip[1]=0;
 return;
}
/* --------------------------------------------------------------------------*/
