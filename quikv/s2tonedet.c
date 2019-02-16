#include <stdio.h> 
#include <stdlib.h>
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  256

/* S2 tonedet SNAP command */

static char  SB[] = { 0 , 0 };
static char *SBname[3]   = { "na" , "usb" , "lsb" };

/* **************************************************************** */
static unsigned int get_freq( char *string )
{
 double Freq = -1.0; /* do not change */

 if( !string ) return -1;

 while( *string == ' ' || *string == '0' )
       *string++;

 if( *string == '\0' || *string == '*' )
    return -1;

 return ( atof( string ) * 1.0E6 + 0.5 );
}
/* **************************************************************** */
static unsigned short get_avep( char *string )
{
 if( !string ) return 0;

 while( *string == ' ' || *string == '0' )
       *string++;

 if( *string == '\0' || *string == '*' )
    return 0;

 return ( atol( string ) * 1.0E3 + 0.5 );
}
/* **************************************************************** */
static char get_sb( char *string )
{
  int i;

 if( !string ) return 0;

 for( i = 0 ; i < 3 ; i++ )
     if( !strcmp( string , SBname[i] ) )
        return (char)i;

 return 0;
}
/* **************************************************************** */
void s2tonedet(struct cmd_ds *command , int itask , int *ip )
{
 int  ierr = 0;
 int  i, last = 0;
 char sb[2];
 unsigned short int avep;
 unsigned int freq[2];
 char output[MAX_OUT];

 if( command->equal == '=' ) /* Set encode */
   {
    freq[0] = get_freq( arg_next( command , &last ) );
    sb[0]   = get_sb(   arg_next( command , &last ) );
    freq[1] = get_freq( arg_next( command , &last ) );
    sb[1]   = get_sb(   arg_next( command , &last ) );
    avep    = get_avep( arg_next( command , &last ) );

    if( ierr = tonedet_set( DAS , freq , sb , avep ) )
       s2err( ierr , ip , EDAS );
    else
      { cls_clr( ip[0] ); ip[0] = ip[1] = 0; }

    for( i = 0 ; i < 2 ; i++ )
        SB[i] = sb[i];

    return;
   }

 /* Read tonedet settings */
 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;

 if( ierr = tonedet_read( DAS , freq, sb, &avep ) )
    return s2err( ierr , ip , EDAS );

 sprintf( output , "%s/%.6lf,%s,%.6lf,%s,%.3lf" , command->name
        ,freq[0]*1.0E-6,SBname[sb[0]]
        ,freq[1]*1.0E-6,SBname[sb[1]],avep*1.0E-3);

 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}
/* **************************************************************** */
void s2tonedetmeas( struct cmd_ds *command , int itask , int *ip )
{
 char      SBtxt[] = { '?','u','l' };
 int       ierr = 0;
 int       i;
 char      bbc, TimeStamp[4];
 double    Amplitude[2], Phase[2];
 unsigned int Amp[2];
 int          Pha[2];
 char      output[MAX_OUT], StateTxt[10];
 int       last = 0;
 char state = 0;

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 
 if( command->equal != '=' )
    return s2err( TONE_MEAS_PARM , ip , QDAS );

 if( !str2bbc( arg_next( command , &last ) , &bbc ) )
   return s2err( TONE_MEAS_BAD_BBC , ip , QDAS );
 if( !str2state( arg_next( command , &last ) , &state ) )
   return s2err( TONE_MEAS_BAD_STATE , ip , QDAS );

 /* Read tonedet measurements */
 if( ierr = tonedet_meas( DAS , bbc, state, Amp, Pha, TimeStamp ) )
    return s2err( ierr , ip , EDAS );

 for( i = 0 ; i < 2 ; i++ )
    {
     Amplitude[i] = (double)Amp[i] / 100.0;
     Phase[i] = (double)Pha[i] / 100.0;
    }

 if( !state )
   strcpy( StateTxt , "" );
 else
   sprintf( StateTxt , ":%02d" , state );

 sprintf( output , "%s/%d%c%s,%.1lf,%.1lf,%d%c%s,%.1lf,%.1lf"
        , command->name
        , bbc, SBtxt[SB[0]] , StateTxt , Amplitude[0] , Phase[0]
        , bbc, SBtxt[SB[1]] , StateTxt , Amplitude[1] , Phase[1] );

 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}
