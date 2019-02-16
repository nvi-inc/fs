#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <stdlib.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  2048
#define ATTN_MAX   30

/* --------------------------------------------------------------------------*/
/* S2 bbc SNAP command */
void s2bbc( struct cmd_ds *command, int id, int *ip )
{
 unsigned int  lofreq, tpi[2];
 unsigned short tpiavg  = 0;
 short gain[2];
 char  ifsrc, bw[2], agcmode, lolock, agclock, index, state;
 char  output[MAX_OUT], usb[10], lsb[10], cmdname[25];
 char *parm  = 0;
 char *parm1 = 0;
 int   ierr  = 0;
 int   last  = 0;
 int   i;
 struct s2bbc_data *bbc;

 /* Decode bbc index */
 index = (char)id;
 state = 0;

 parm1 = arg_next(command,&last);
 parm  = arg_next(command,&last);

 if(    command->equal != '='
     || ( parm1 && str2state( parm1 , &state ) && !parm )
   )
   { /* read bbc values */
    if( ierr = bbc_read(DAS,index,&state,&lofreq,&ifsrc,bw
                       ,&tpiavg,&agcmode,gain,&lolock,&agclock,tpi)
      )    
       return s2err( ierr , ip , EDAS );

    sprintf( cmdname , state ? "%s:%d" : "%s" , command->name , state );

    sprintf(output,"%s/%s,%s,%s,%s,%s,%s,%.2lf,%.2lf,%s,%u,%u"
	   , cmdname , lofreq2str( lofreq )
	   , ifsrc2str( ifsrc )
           , bw2str( bw[0] , usb ) , bw2str( bw[1] , lsb )
	   , tpiavg2str( tpiavg )  , agc2str( agcmode )
           , gain[0] * 1.0E-2 , gain[1] * 1.0E-2
           , lock2str(lolock) , tpi[0], tpi[1]
           );

    for( i = 0 ; i < 5 ; i++ )
        ip[i] = 0;
    cls_snd(ip,output,strlen(output),0,0);
    ip[1] = 1; /* one record only */
    return;
   }

 if( !parm1 ) /* display bbc values in memory */
   {
    bbc = &shm_addr->s2bbc[id-1];
    
    sprintf(output,"%s/%s,%s,%s,%s,%s,%s"
           , command->name , lofreq2str( bbc->freq )
	   , ifsrc2str( bbc->ifsrc )
	   , bw2str( bbc->bw[0] , usb ) , bw2str( bbc->bw[1] , lsb )
           , tpiavg2str( bbc->tpiavg )  , agc2str( bbc->agcmode )
           );

    for( i = 0 ; i < 5 ; i++ )
        ip[i] = 0;
    cls_snd(ip,output,strlen(output),0,0);
    ip[1] = 1; /* one record only */
    return;
   }

 /* Set bbc values */
 if( !str2lofreq( parm1 , &lofreq ) )
    return s2err( BBC_BAD_LOFREQ , ip , QDAS );
 if( !str2ifsrc( parm , &ifsrc , 0 ) )
    return s2err( BBC_BAD_IFSRC , ip , QDAS );
 for( i = 0 ; i < 2 ; i++ )
     if( !str2bw( arg_next(command,&last) , bw + i ) )
        return s2err( BBC_BAD_BW , ip , QDAS );
 if( !str2tpiavg( arg_next(command,&last) , &tpiavg ) )
    return s2err( BBC_BAD_TPIAVG , ip , QDAS );
 if( !str2agc( arg_next(command,&last) , &agcmode ) )
    return s2err( BBC_BAD_AGCMODE , ip , QDAS );

 if( ierr = bbc_set( DAS,index,lofreq,ifsrc,bw,tpiavg,agcmode ) )
    return s2err( ierr , ip , EDAS );

 /* keep old setting in memory */
 bbc = &shm_addr->s2bbc[id-1];
 bbc->init    = 1;
 if( lofreq !=   0 ) bbc->freq    = lofreq;
 if( ifsrc != -128 ) bbc->ifsrc   = ifsrc;
 if( bw[0] != -128 ) bbc->bw[0]   = bw[0];
 if( bw[1] != -128 ) bbc->bw[1]   = bw[1];
 if( tpiavg !=   0 ) bbc->tpiavg  = tpiavg;
 if( agcmode !=  0 ) bbc->agcmode = agcmode;

 cls_clr( ip[0] ); ip[0] = ip[1] = 0;

 return;
}
/* --------------------------------------------------------------------------*/
