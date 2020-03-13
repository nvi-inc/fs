/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include "s2das_util.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

/* --------------------------------------------------------------------------*/

static char NA[] = "na"; /* not available */
static char BLK[] = "";  /* blank */
static char DNC[] = "?"; /* do not change */

/* --------------------------------------------------------------------------*/
int valids2detector( char *name )
{ 
 /* Detector is one of IF : i1,i2,i3,i4 */
 if( name[0] == 'i' )
    return( name[1] > '0' && name[1] < '5' && name[2] == '\0' );

 /* Detector is BBC1 to BBC4 */
 /* Format bbc# , sideband (u or l) , state # (optional) */
 if( name[0] > '0' && name[0] < '5' )
   {
    if( name[1] != 'u' && name[1] != 'l' ) return 0;/* wrong sideband */
    if( name[2] == '\0' ) return 1;
    if( name[2]  < '0' || name[2]  > '9' ) return 0;/* Not a digit */ 
    if( name[3] == '\0' ) return 1;
    if( name[3]  < '0' || name[3]  > '9' ) return 0;/* Not a digit */
    return( name[4] == '\0' && ( atol( name + 2 ) < 64 ) );
   }
 return 0;
}    
/* --------------------------------------------------------------------------*/
/* Functions to be called by Fortran routines                                */
/* --------------------------------------------------------------------------*/
void check_s2dev__( char *dev , int *ierr )
{
 *ierr = valids2detector( dev ) ? 1 : -1; 
}
/* --------------------------------------------------------------------------*/
void get_s2_tpi__( char *dev , double *tpi , int *ierr )
{
 char period, src[4], attn;
 unsigned TPI[4];

 *tpi = 0.0;
 if( *dev < 0 || *dev > 3 ) *ierr = -222;

 /* Read ifx values */
/* if( !*ierr ) *ierr = getifx(&period,attn,src,TPI);

 if( !*ierr ) *tpi = TPI[*dev];
*/
 *tpi=65535;
 return;
}
/* --------------	  if(    !str2lofreq( arg_next(command,&last) , &LOfreq )
              || !str2ifsrc( arg_next( command,&last) , &IFswt , &swt )
	       ){printf("STATE PROBLEM\n"); break; }
------------------------------------------------------------*/
int str2int( char *string , int *value )
{
 char *ptr = string;

 /* remove leading blank or 0 */
 while( *ptr == ' ' || *ptr == '0' )
       ptr++;

 /* check for non-valid integer */
 for( ; *ptr ; ptr++ )
     if( ( *ptr != '-' && *ptr != '+' ) && ( *ptr > '9' || *ptr < '0' ) )
        return 0;

 *value = atol( string );
 return 1;
}
/* --------------------------------------------------------------------------*/
char *agc2str( int code )
{ 
 static char *name[] = {DNC,"on","off"};

 if( code < 0 || code > 2 )
    return NA;

 return name[code];
}
/* --------------------------------------------------------------------------*/
int str2agc( char *string , char *code )
{
 int i;
 
 if( !string || *string == '\0' || *string == '*' )
   { *code = 0; return 1; }

 for( i = 1 ; i < 3 ; i++ )
     if( !strcmp( string , agc2str( i ) ) )
       { *code = i; return 1; }

 return 0;
}
/* --------------------------------------------------------------------------*/
char *attn2str( char attn )
{
 static char string[10];

 if( attn == -128 )
    strcpy( string , NA );
 else if( attn == -127 )
    strcpy( string , "auto" );
 else
    sprintf( string , "%d" , (int)attn );

 return string;
}    
/* --------------------------------------------------------------------------*/
int str2attn( char *string , char *attn , char *old )
{
 int tmp;
 if( !string || *string == '\0' || *string == '*' ) /* do not change */
   { *attn = -128; return 1; }
 if( !strcmp( string , "max" ) )         /* set to max */
   { *attn =   30; return 1; }
 if( !strcmp( string , "old" ) )         /* set to old */
   { *attn = *old; return 1; }
 if( !strcmp( string , "auto" ) )        /* set to auto */
   { *attn = -127; return 1; }
 if( !str2int( string , &tmp ) )
   { return 0; };

 if( tmp > -1 && tmp < 31 && (tmp % 2) == 0 )
   { *old = *attn = tmp; return 1; }
 return 0;
}
/* --------------------------------------------------------------------------*/
char *bw2str( char code , char *buffer )
{
 if( code == -128 )
   strcpy( buffer , DNC );
 else
   sprintf( buffer , "%.*lf" , code > 0 ? 0 : -code , pow(2.0,(double)code) );

 return buffer;
}
/* --------------------------------------------------------------------------*/
int str2bw( char *string , char *code )
{
 double bw;

 if( !string || *string == '\0' || *string == '*' ) /* do not change */
   { *code = -128; return 1; }

 bw = atof( string );
 if( fabs( bw ) < 1.0e-5 ) return 0;
 bw = log( bw ) / log( 2.0 );

 if( bw < 0.0 )
   { *code = (char)( bw - 0.5 ); return *code > -5; }

 *code = (char)( bw + 0.5 );
 return( *code < 5 ); 
}  
/* --------------------------------------------------------------------------*/
char *ifsrc2str( int code )
{
 static char *ifsrc[]  = {"none","i1","i2","i3","i4"};

 if( code == -128 )
   return DNC;
 return ifsrc[code];
}
/* --------------------------------------------------------------------------*/
int str2ifsrc( char *string , char *code , char *src )
{
 if( !string || *string == '\0' || *string == '*' )
   { *code = -128; return 1; }

 /* remove leading blank */
 while( *string == ' ' )
       string++;
 if( !strcmp( "none" , string ) )
   { *code = 0; return 1; }

 if(   ( string[0] != 'i' )
    || ( string[1]  < '1' || string[1]  > '4' )
   ) return 0;
 *code = string[1] - '0';
 if( !src )return 1;
 if( string[2] == '\0' || string[2] == 'd' ){ *src = 1; return 1; } 
 if( string[2] == 'a' ){ *src = 2; return 1; }
 return 0;
}    
/* --------------------------------------------------------------------------*/
int str2state( char *string , char *state )
{
 int tmp = 0;
 *state = 0;

 if(  !string || *string == '\0' )
   return 1; /* state = 0 (current) */
   
 if( !str2int( string , &tmp ) || tmp < 0 || tmp > 64 )
    return 0;

 *state = (char)tmp;

 return 1;
}
/* --------------------------------------------------------------------------*/
int str2bbc( char *string , char *bbc )
{
 int tmp = 0;

 if( !string || *string == '\0' )
   { *bbc = 0; return 1; }

 if( !str2int( string , &tmp ) || tmp < 1 || tmp > 4 )
    return 0;

 *bbc = (char)tmp;

 return 1;
}
/* --------------------------------------------------------------------------*/
int str2tonedet( char *string , char *tone )
{
 int tmp = 0;

 if( !string || *string == '\0' )
   { *tone = 0; return 0; }

 if( !str2int( string , &tmp ) || tmp < 1 || tmp > 2 )
    return 0;

 *tone = (char)tmp;

 return 1;
}
/* --------------------------------------------------------------------------*/
int str2lofreq( char *string , unsigned int *lofreq )
{
 double freq;

 *lofreq = 0; /* do not change */
 if( !string ) return 1;

 while( *string == ' ' || *string == '0' )
       *string++;

 if( *string == '\0' || *string == '*' ) return 1;

 freq = atof( string );
 if( freq < 100.0 || freq > 1000.0 ) return 0;

 *lofreq = (unsigned int)( freq * 1.0E6 + 0.5 );

 return 1;
}
/* --------------------------------------------------------------------------*/
char *tpiavg2str( unsigned short avg )
{
 static char string[100];

 if( avg == 0 )
    return DNC;

 sprintf( string , "%.2lf" , (double)avg * 1.0E-3 + 0.5E-4 );
 return string;
}
/* --------------------------------------------------------------------------*/
int str2tpiavg( char *string , unsigned short *avg )
{
 *avg = 0;

 if( !string ) return 1;

 /* remove leading blank */
 while( *string == ' ' )
       string++;

 if( *string == '*' || *string == '\0' )
    return 1;

 *avg = (unsigned short)( atof( string ) * 1000.0 + 0.5 );

 return( *avg < 10 || *avg > 10000 ) ? 0 : 1;
}    
/* --------------------------------------------------------------------------*/
int str2src( char *string , char *code )
{
 int i;
 
 if( !string || *string == '\0' || *string == '*' )
   { *code = -128; return 1; }

 for( i = 0 ; i < 3 ; i++ )
     if( !strcmp( string , src2str( i ) ) )
       { *code = i; return 1; }

 return 0;
}
/* --------------------------------------------------------------------------*/
int str2encode( char *string , char *code )
{
 int i;
 
 if( string )
    for( i = 1 ; i < 3 ; i++ )
        if( !strcmp( string , encode2str( i ) ) )
          { *code = i; return 1; }

 return 0;
}
/* --------------------------------------------------------------------------*/
int str2period( char *string , unsigned short *period )
{
 if( !string || !*string )
    return 0;

 *period = (unsigned short)(atof( string ) * 100 );

 return( *period > 1 );
}
/* --------------------------------------------------------------------------*/
char *lofreq2str( unsigned int lofreq )
{
 static char string[12];
 int sig = lofreq % 100 ? 6 : 2;

 if( lofreq == 0 )
    return DNC;

 sprintf( string , "%*.*lf" , sig + 4 , sig
         , (double)lofreq * 1.0E-6 + 0.5E-6 );
 return string;
}
/* --------------------------------------------------------------------------*/
char *lock2str( int code )
{
 static char *lock[2]   = {"unlock","lock"};

 return lock[code];
}
/* --------------------------------------------------------------------------*/
char *src2str( int code )
{ 
 static char *opt[]={"none","dir","alt"};

 if( code == -128 || code < 0 || code > 3 )
    return NA;
 return opt[code];
}
/* --------------------------------------------------------------------------*/
char *encode2str( int code )
{ 
 static char *name[] = {"non-standard","vlba","sbin"};

 if( code == -128 || code < 0 || code > 2 )
    return NA;

 return name[code];
}
/* --------------------------------------------------------------------------*/
void s2err( int err , int *ip , char *code )
{
 char message[400];
 int i, das;

 for( i = 0 ; i < 5 ; i++ )
     ip[0] = 0;

 if(  ( das = !strcasecmp(code,EDAS) )
    || !strcasecmp(code,"r1")
    || !strcasecmp(code,"r2")
   )
   { 
    if( err < -130 )
      { logita(0,err,"RL",code);  return; } 
    else if( error_decode(das ? "da" : code,err,message) == ERR_NONE )
      { logite(message,err,code); return; }
   }

 ip[2] = err;
 memcpy(ip+3,code,2);
}
/* --------------------------------------------------------------------------*/
static char old[4];
/* --------------------------------------------------------------------------*/
void s2_get_attn__( int *ierr )
{
 unsigned short tpiavg;
 unsigned       TPI[4];
 char           src[4], state = 0;

 *ierr = ifx_read("da",&state,old,src,&tpiavg,TPI);

 return;
}
/* --------------------------------------------------------------------------*/
void s2_max_attn__( int *ierr )
{
 unsigned short tpiavg = 0;
 char           src[4] = { -128, -128, -128, -128 };
 char           max[4] = {   30,   30,   30,   30 };

 *ierr = ifx_set("da",max,src,tpiavg);

 return;
}
/* --------------------------------------------------------------------------*/
void s2_old_attn__( int *ierr )
{
 unsigned short tpiavg = 0;
 char           src[4] = { -128, -128, -128, -128 };

 *ierr = ifx_set("da",old,src,tpiavg);

 return;
}
/* --------------------------------------------------------------------------*/
void s2_get_tpi__( char *dev , double *tpi , int *ierr )
{
 unsigned int  lofreq, TPI[4];
 unsigned short tpiavg  = 0;
 short          gain[2];
 char           ifsrc, bw[2], agcmode, lolock, agclock, index;
 char           attn[4], src[4];
 char           state = 0;

 *tpi = 0.0;
 if( dev[0] == 'i' ) /* READ IFX TPI */
   {
    if( ( *ierr = ifx_read("da",&state,attn,src,&tpiavg,TPI) ) == 0 )
       *tpi = (double)( TPI[dev[1] - '1'] );
    return;
   }
 /* Read BBC */
 index = dev[0] - '0';
 if( ( *ierr = bbc_read("da",index,&state,&lofreq,&ifsrc,bw,&tpiavg
                       ,&agcmode,gain,&lolock,&agclock,TPI)
     ) == 0
   ) *tpi = TPI[dev[1] == 'l'];
}
/* --------------------------------------------------------------------------*/
void s2_get_bbc_source__( int *source , int *bbc_id )
{
 unsigned int  lofreq, tpi[2];
 unsigned short tpiavg  = 0;
 short          gain[2];
 char           ifsrc, bw[2], agcmode, lolock, agclock, index, state;

 index = (char)(*bbc_id);
 state = 0;
 *source = 0;
    
 if( bbc_read("da",index,&state,&lofreq,&ifsrc,bw,&tpiavg,&agcmode,gain
             ,&lolock,&agclock,tpi) == 0
   )    
    *source = ifsrc;
}
/* --------------------------------------------------------------------------*/
/*const unsigned long bitValList[] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512
				   ,1024, 2048, 4096, 8192, 16384, 32768
                                   , 65536, 131072, */
/* --------------------------------------------------------------------------*/
void SetBitState( unsigned int *flag , int index , int state )
{
 unsigned int mask = ( 0x0001 << index );

 if( !state )
   *flag &= ~mask;
 else
   *flag |=  mask;
}
/* --------------------------------------------------------------------------*/
int GetBitState( unsigned int flag , int index )
{
 unsigned int mask = ( 0x0001 << index );
 return( ( flag & mask ) != 0 );
}
/* --------------------------------------------------------------------------*/





