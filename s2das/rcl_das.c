#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <stdlib.h>

#include "rcl_das.h"
#include "s2das.h"

#include "params.h"
#include "fs_types.h"
#include "fscom.h"         /* shared memory definition */
#include "shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl_def.h"

#define MAX_OUT 2048

/* --------------------------------------------------------------------------*/
/* rclcn utilities */

void ini_rclcn_req();
void add_rclcn_req();
void end_rclcn_req();
char *arg_next();

/* --------------------------------------------------------------------------*/
/* program scheduling utilities */

void skd_run();
void skd_par();

/* --------------------------------------------------------------------------*/
unsigned int Byte2ULong( unsigned char *data )
{
 unsigned int val = (data[0]<<24) | (data[1]<<16) | (data[2]<<8) | data[3];
 return val;
}
/* --------------------------------------------------------------------------*/
int Byte2Long( unsigned char *data )
{
 return (data[0]<<24) | (data[1]<<16) | (data[2]<<8) | data[3];
}
/* --------------------------------------------------------------------------*/
unsigned short Byte2UShort( unsigned char *data )
{
 return (data[0]<<8) | data[1];
}
/* --------------------------------------------------------------------------*/
short Byte2Short( unsigned char *data )
{
 return (data[0]<<8) | data[1];
}
/* --------------------------------------------------------------------------*/
void ULong2Char( unsigned int data , char *byte )
{
 byte[0] = data >> 24 & 0xff;
 byte[1] = data >> 16 & 0xff;
 byte[2] = data >>  8 & 0xff;
 byte[3] = data       & 0xff;
}
/* --------------------------------------------------------------------------*/
void Long2Char( int data , char *byte )
{
 byte[0] = data >> 24 & 0xff;
 byte[1] = data >> 16 & 0xff;
 byte[2] = data >>  8 & 0xff;
 byte[3] = data       & 0xff;
}
/* --------------------------------------------------------------------------*/
void UShort2Char( unsigned short data , char *byte )
{
 byte[0] = ( data >> 8 ) & 0xff;
 byte[1] = data & 0xff;
}
/* --------------------------------------------------------------------------*/
void ULong2Byte( unsigned int data , unsigned char *byte )
{
 byte[0] = data >> 24 & 0xff;
 byte[1] = data >> 16 & 0xff;
 byte[2] = data >>  8 & 0xff;
 byte[3] = data       & 0xff;
}
/* --------------------------------------------------------------------------*/
void UShort2Byte( unsigned short data , unsigned char *byte )
{
 byte[0] = ( data >> 8 ) & 0xff;
 byte[1] = data & 0xff;
}
/* --------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------*/
int send_to_rclcn( char *device , char *byte , char size , char answer
                 , char *data , int datasize , char *string , int timeout )
{
 struct rclcn_req_buf buffer;           /* rclcn request buffer */
 int   ip[5];
 char   rsp_code;
 int    ierr;

 /* Build rclcn request buffer */
 ini_rclcn_req(&buffer);
 add_rclcn_request(&buffer,device,byte,size);
 end_rclcn_req(ip,&buffer);

 ip[0] = 3; /* case for das commands */
 ip[4] = timeout;
 /* Send request to rclcn */
 skd_run("rclcn",'w',ip);
 skd_par(ip);
 
 /* Decode answer */
 if( ip[2] < 0 ) 
   {
    cls_clr( ip[0] );
    ip[0]=ip[1]=0;
    ierr = ip[2];
    /*    if( ierr < 0 && ierr > -100 )
	  ierr -= 500;*/
    return ierr;
   }
 
 opn_rclcn_res(&buffer,ip);
  
 ierr = get_rclcn_res(&buffer);

 if( !ierr )ierr = get_rclcn_res_data(&buffer,&rsp_code,1);
 if( !ierr && rsp_code != answer ) ierr = RESP_INV_CODE; 
 if( !ierr && datasize )ierr = get_rclcn_res_data(&buffer,data,datasize);
 if( !ierr && string   )ierr = get_rclcn_res_string(&buffer,string);

 clr_rclcn_res(&buffer);
 return ierr;
}
/* --------------------------------------------------------------------------*/
int bbc_set( char *s2dev, char index, unsigned int lofreq, char ifsrc
           , char *bw, unsigned short tpiavg, char agcctl )
{
 char byte[12];

 byte[ 0] = BBC_SET;
 byte[ 1] = index;

 ULong2Char( lofreq , byte + 2 );
 
 byte[ 6] = ifsrc;
 byte[ 7] = bw[USB];
 byte[ 8] = bw[LSB];

 UShort2Char( tpiavg , byte + 9 );

 byte[11] = agcctl;

 return send_to_rclcn( s2dev, byte, 12, RESP_ERR, 0, 0, 0, RCL_TIMEOUT );    
}
/* --------------------------------------------------------------------------*/
int bbc_read( char *s2dev, char index, char *state, unsigned int *lofreq
            , char *ifsrc, char *bw, unsigned short *tpiavg, char *agcmode
            , short *gain, char *lolock, char *agclock, unsigned int *tpi)
{
 int ierr = 0;
 char byte[3];
 char data[26];

 /* read bbc values */
 byte[0] = BBC_READ;
 byte[1] = index;
 byte[2] = *state;

 /* Send request and decode answer */
 if( ierr = send_to_rclcn( s2dev, byte, 3, RESP_BBC, data, 26,0,RCL_TIMEOUT) )
    return ierr;

 if( index != data[0] ) return RESP_INV_BBC;
 if( ( data[1] != *state ) && ( *state != 0 ) ) return RESP_INV_STATE;

 *state     = data[1];
 *lofreq    = Byte2ULong( (unsigned char *)(data + 2) );
 *ifsrc     = data[6];
  bw[USB]   = data[7];
  bw[LSB]   = data[8];
 *tpiavg    = Byte2UShort( (unsigned char *)(data + 9) );
 *agcmode   = data[11];
  gain[USB] = Byte2Short( data + 12 );
  gain[LSB] = Byte2Short( data + 14 );
 *lolock    = data[16];
 *agclock   = data[17];
  tpi[USB]  = Byte2ULong( data + 18 );
  tpi[LSB]  = Byte2ULong( data + 22 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int ifx_set( char *s2dev, char *attn , char *src , unsigned short tpiavg )
{
 char byte[11];
 int  i;
 int TimeOut = RCL_TIMEOUT;

 for( i = 0 ; i < 4 ; i++ )
     if( attn[i] == -127 )
       { TimeOut = RCL_TIMEOUT_IF; break; }

 byte[0] = IFX_SET;
 memcpy( byte + 1 , attn , 4 );
 memcpy( byte + 5 , src  , 4 );
 UShort2Char( tpiavg , byte + 9 );

 return send_to_rclcn( s2dev, byte, 11, RESP_ERR, 0, 0, 0, TimeOut );   
}
/* --------------------------------------------------------------------------*/
int ifx_read( char *s2dev, char *state, char *attn, char *src
            , unsigned short *tpiavg , unsigned int *tpi )
{
 int ierr = 0;
 int  i, j;
 char byte[2];
 char data[27];

 /* read ifx value and display result */
 byte[0] = IFX_READ;
 byte[1] = *state;

 /* Send request and decode answer */
 if( ierr = send_to_rclcn( s2dev, byte, 2, RESP_IFX, data, 27,0,RCL_TIMEOUT ) )
    return ierr;

 if( ( data[0] != *state ) && ( *state != 0 ) ) return RESP_INV_STATE;
 *state = data[0];
 memcpy( attn , data + 1 , 4 );
 memcpy( src  , data + 5 , 4 );
 *tpiavg = Byte2UShort( (unsigned char *)( data + 9 ) );
 for( j = 0, i = 11 ; j < 4 ; j++ , i += 4 )
     tpi[j] = Byte2ULong( (unsigned char *)( data + i ) );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int encode_set( char *s2dev, char scheme )
{
 char byte[2];

 byte[0] = ENCODE_SET;
 byte[1] = scheme;

 return send_to_rclcn(s2dev, byte, 2, RESP_ERR, 0, 0, 0, RCL_TIMEOUT );
}   
/* --------------------------------------------------------------------------*/
int encode_read( char *s2dev, char *scheme )
{
 int ierr = 0;
 char byte[1];
 char data[1];

 byte[0] = ENCODE_READ;

 if( !(ierr = send_to_rclcn( s2dev, byte, 1, RESP_ENCODE, data, 1, 0, RCL_TIMEOUT ) ) )
    *scheme = data[0];

 return ierr;
}
/* --------------------------------------------------------------------------*/
int agc_set( char *s2dev, char mode )
{
 char byte[2];

 byte[0] = AGC_SET;
 byte[1] = mode;

 return send_to_rclcn(s2dev, byte, 2, RESP_ERR, 0, 0, 0, RCL_TIMEOUT );
}   
/* --------------------------------------------------------------------------*/
int agc_read( char *s2dev, char *mode )
{
 int ierr = 0;
 char byte[1];
 unsigned char data[1];

 byte[0] = AGC_READ;

 if( !( ierr = send_to_rclcn( s2dev, byte, 1, RESP_AGC, data, 1, 0, RCL_TIMEOUT ) ) )
    *mode = data[0];

 return ierr;
}
/* --------------------------------------------------------------------------*/
int powermon_read( char *s2dev, char module , unsigned short *Voltage )
{
 int ierr = 0;
 int i, j;
 char byte[2];
 unsigned char data[24];

 byte[0] = POWERMON_READ;
 byte[1] = module;

 if( !(ierr=send_to_rclcn(s2dev,byte,2,RESP_POWERMON,data,24,0,RCL_TIMEOUT)) )
    for( i = j = 0 ; i < 12 ; i++ , j += 2 )
        Voltage[i] = Byte2UShort( data + j );
    
 return ierr;
}
/* --------------------------------------------------------------------------*/
int time_set( char *s2dev, int year, int day, int hour, int min , int sec )
{
 unsigned char byte[8];

 byte[0] = TIME_SET;
 byte[1] = ( year >> 8 ) & 0xff;
 byte[2] = year & 0xff;
 byte[3] = ( day  >> 8 ) & 0xff;
 byte[4] = day & 0xff;
 byte[5] = hour;
 byte[6] = min;
 byte[7] = sec;

 return send_to_rclcn( s2dev , (char *)byte, 8, RESP_ERR, 0, 0, 0, RCL_TIMEOUT );
}
/* --------------------------------------------------------------------------*/
int time_read( char *s2dev, int *year, int *day, int *hour, int *min
             , int *sec , char *validated )
{
 int ierr = 0;
 char byte[1];
 unsigned char data[8];

 byte[0] = TIME_READ;

 if( !( ierr = send_to_rclcn(s2dev,byte,1,RESP_TIME,data,8,0,RCL_TIMEOUT_S1)) )
   {
    *year      = ( (int)data[0] << 8 ) | (int)data[1];
    *day       = ( (int)data[2] << 8 ) | (int)data[3];
    *hour      = data[4];
    *min       = data[5];
    *sec       = data[6];
    *validated = data[7];
   }
    
 return ierr;
}
/* --------------------------------------------------------------------------*/
int mode_set( char *s2dev, char *mode , char setbw )
{
 char byte[22];

 byte[0] = setbw ? MODE_BW_SET : MODE_SET;
 strcpy( byte + 1 , mode );

 return send_to_rclcn(s2dev,byte,strlen(mode)+2,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int mode_read( char *s2dev, char *mode )
{
 char byte[1];

 byte[0] = MODE_READ;

 return send_to_rclcn( s2dev, byte, 1, RESP_MODE, 0, 0, mode, RCL_TIMEOUT );
}
/* --------------------------------------------------------------------------*/
int fs_read( char *s2dev, char *status, char *curstate, char *numstates
           , unsigned short *period , char *name )
{
 char byte[1];
 unsigned char data[5];
 int  ierr;

 byte[0] = FS_READ;

 if( ierr = send_to_rclcn(s2dev,byte,1,RESP_FS,data,5,name,RCL_TIMEOUT) )
    return ierr;

 *status    = data[0];
 *curstate  = data[1];
 *numstates = data[2];
 *period    = Byte2UShort( data + 3 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int fs_start( char *s2dev, char *name )
{
 char byte[12];

 byte[0] = FS_START;
 strcpy( byte + 1 , name );

 return send_to_rclcn(s2dev,byte,strlen(name)+2,RESP_ERR,0,0,0,RCL_TIMEOUT_FS);
}   
/* --------------------------------------------------------------------------*/
int fs_stop( char *s2dev )
{
 char byte[1];

 byte[0] = FS_STOP;

 return send_to_rclcn(s2dev,byte,1,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int fs_halt( char *s2dev )
{
 char byte[1];

 byte[0] = FS_HALT;

 return send_to_rclcn(s2dev,byte,1,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int fs_state( char *s2dev , char state , char copyflag )
{
 char byte[3];

 byte[0] = FS_STATE;
 byte[1] = state;
 byte[2] = copyflag;

 return send_to_rclcn(s2dev,byte,3,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int fs_load( char *s2dev, char *name )
{
 char byte[12];

 byte[0] = FS_LOAD;
 strcpy( byte + 1 , name );

 return send_to_rclcn(s2dev,byte,strlen(name)+2,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int fs_save( char *s2dev, char *name )
{
 char byte[12];

 byte[0] = FS_SAVE;
 strcpy( byte + 1 , name );

 return send_to_rclcn(s2dev,byte,strlen(name)+2,RESP_ERR,0,0,0,RCL_TIMEOUT);
}   
/* --------------------------------------------------------------------------*/
int fs_init( char *s2dev, char numstates , unsigned short period )
{
 char byte[4];

 byte[0] = FS_INIT;
 byte[1] = numstates;
 UShort2Byte( period , byte + 2 );

 return send_to_rclcn(s2dev,byte,4,RESP_ERR,0,0,0,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int source_set( char *s2dev, char *name , char *ra , char *dec , char *epoch )
{
 char byte[47];
 int i;

 byte[0] = SOURCE_SET;
 for( i = 1 ; i < 47 ; i++ )
     byte[i] = 0;

 strcpy( byte +  1 , name  );
 strcpy( byte + 12 , ra    );
 strcpy( byte + 25 , dec   );
 strcpy( byte + 39 , epoch );

 return send_to_rclcn(s2dev,byte,47,RESP_ERR,0,0,0,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int source_read( char *s2dev, char *name , char *ra , char *dec , char *epoch )
{
 char byte[1];
 char data[46];
 int  ierr = 0;
 byte[0] = SOURCE_READ;

 if( ierr = send_to_rclcn(s2dev,byte,1,RESP_SOURCE,data,46,0,RCL_TIMEOUT) )
    return ierr;

 strcpy( name  , data +  0 );
 strcpy( ra    , data + 11 );
 strcpy( dec   , data + 24 );
 strcpy( epoch , data + 38 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int delay_set( char *s2dev, char setting , int delay )
{
 char byte[6];

 byte[0] = DELAY_SET;
 byte[1] = setting;
 Long2Char( delay , byte + 2 );

 return send_to_rclcn(s2dev,byte,6,RESP_ERR,0,0,0,RCL_TIMEOUT );
}   
/* --------------------------------------------------------------------------*/
int delay_read( char *s2dev, char type , int *delay )
{
 int ierr = 0;
 char byte[1];
 char data[4];

 byte[0] = type;

 if( !( ierr = send_to_rclcn(s2dev,byte,1,RESP_DELAY,data,4,0,RCL_TIMEOUT ) ) )
    *delay = Byte2Long( data );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int tonedet_set( char *s2dev, unsigned int *freq, char *sb, unsigned short avep )
{
 unsigned char byte[13];

 byte[ 0] = TONEDET_SET;
 ULong2Byte( freq[0] , byte + 1 );
 byte[ 5] = sb[0];
 ULong2Byte( freq[1] , byte + 6 );
 byte[10] = sb[1];
 UShort2Byte( avep , byte + 11 );

 return send_to_rclcn(s2dev,(char*)byte,13,RESP_ERR,0,0,0,RCL_TIMEOUT );    
}
/* --------------------------------------------------------------------------*/
int tonedet_read( char *s2dev, unsigned int *freq, char *sb, unsigned short *avep )
{
 int ierr = 0;
 char byte[1];
 unsigned char data[12];

 /* read tonedet settings */
 byte[0] = TONEDET_READ;

 /* Send request and decode answer */
 if( ierr = send_to_rclcn( s2dev, byte, 1, RESP_TONEDET, data, 12,0,RCL_TIMEOUT) )
    return ierr;

 freq[0] = Byte2ULong( data + 0 );
 sb[0]   = data[4];
 freq[1] = Byte2ULong( data + 5 );
 sb[1]   = data[9];
 *avep   = Byte2UShort( data + 10 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int tonedet_meas( char *s2dev, char bbc, char state, unsigned int *amplitude
                , int *phase, char *timestamp )
{
 int ierr = 0;
 int i, j;
 char byte[3];
 char data[20];

 /* read tonedet settings */
 byte[0] = TONEDETM_READ;
 byte[1] = bbc;
 byte[2] = state;

 /* Send request and decode answer */
 if( ierr = send_to_rclcn(s2dev,byte,3,RESP_TONEDETM,data,20,0,RCL_TIMEOUT) )
    return ierr;

 for( i = j = 0 ; i < 2 ; i++ )
    {
     amplitude[i] = Byte2ULong( (unsigned char *)( data + j ) ); j += 4;
     phase[i]     = Byte2Long( data + j );                       j += 4;
    }
 memcpy( timestamp , data + 16 , 4 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int tpi_read( char *s2dev, char state, unsigned short tpiavg, char type
            , char *input , char *swt, unsigned int *tpi )
{
 int ierr = 0;
 char byte[5];
 char data[56];
 unsigned char *ptr;
 int timeout = tpiavg + RCL_TIMEOUT;
 int  i;

 /* read tpi values */
 byte[0] = TPI_READ;
 byte[1] = state;
 UShort2Char( tpiavg , byte + 2 );
 byte[4] = type;

 /* Send request and decode answer */
 if( ierr = send_to_rclcn( s2dev, byte, 5, RESP_TPI, data, 56, 0, timeout) )
    return ierr;

 for( i = 0 , ptr = (unsigned char *)data ; i < 4 ; i++ )
    {
     *tpi++ = Byte2ULong( ptr ); ptr += 4;
     *tpi++ = Byte2ULong( ptr ); ptr += 4;
     *tpi++ = Byte2ULong( ptr ); ptr += 4;
     *input++ = (char)*ptr++;
     *swt++   = (char)*ptr++;
    }

 return ierr;
}
/* --------------------------------------------------------------------------*/
int station_info_read( char *s2dev, char *nbr , unsigned short *serial
                     , char *nickname , char *wlon , char *lat , char *height )
{
 int ierr = 0;
 char byte[1];
 char data[40];

 byte[0] = STATION_INFO_READ;

 if( ierr = send_to_rclcn(s2dev,byte,1,RESP_STATION_INFO,data,40,0,RCL_TIMEOUT ) )
    return ierr;

 *nbr    = data[0];
 *serial = Byte2UShort( (unsigned char *)( data + 1 ) );

 memcpy( nickname , data +  3 ,  9 );
 memcpy( wlon     , data + 12 , 10 );
 memcpy( lat      , data + 22 ,  9 );
 memcpy( height   , data + 31 ,  9 );

 return ierr;
}
/* --------------------------------------------------------------------------*/
int status_read( char *s2dev, char id, char type, char reread, char *summary
               , char *nbr, S2_STATUS *list )
{
 struct rclcn_req_buf buffer;           /* rclcn request buffer */
 int   ip[5];
 char   rsp_code, answer;
 int    ierr, i;
 char   byte[4];
 char  *CR;
 int    size;

 if( type == 0 ) /* brief status report (no messages) */
   {
    size    = 1;
    answer  = RESP_STATUS;
    byte[0] = STATUS;
   }
 else
   {
    size    = 4;
    answer  = RESP_STATUS_DETAIL;
    byte[0] = STATUS_DETAIL;
    byte[1] = id;
    byte[2] = reread; 
    byte[3] = ( type == 1 ) ? 0x00 : 0x01;
   }

 /* Build rclcn request buffer */
 ini_rclcn_req(&buffer);
 add_rclcn_request(&buffer,s2dev,byte,size);
 end_rclcn_req(ip,&buffer);

 ip[0] = 3; /* case for das commands */
 ip[4] = RCL_TIMEOUT;

 /* Send request to rclcn */
 skd_run("rclcn",'w',ip);
 skd_par(ip);
 
 /* Decode answer */
 if( ip[2] < 0 ) 
   { cls_clr( ip[0] ); ip[0]=ip[1]=0; return ip[2]; }

 opn_rclcn_res(&buffer,ip);
 ierr = get_rclcn_res(&buffer);

 if( !ierr )ierr = get_rclcn_res_data(&buffer,&rsp_code,1);  
 if( !ierr && rsp_code != answer ) ierr = RESP_INV_CODE; 
 if( !ierr )ierr = get_rclcn_res_data(&buffer,summary,1);
 if( !ierr )ierr = get_rclcn_res_data(&buffer,nbr,1);
 for( i = 0 ; !ierr && i < *nbr ; i++ )
   {
    if( !ierr )ierr = get_rclcn_res_data(&buffer,&list[i].code,1);
    if( !ierr )ierr = get_rclcn_res_data(&buffer,&list[i].type,1);
    if( !ierr && type )ierr = get_rclcn_res_string(&buffer,list[i].report);
    if( !ierr && (CR = strchr( list[i].report , '\n' )) )*CR = '\0';
   }
 clr_rclcn_res(&buffer);

 return ierr;
}
/* --------------------------------------------------------------------------*/
int status_decode( char *s2dev, char code , char type , char *message )
{
 char byte[3];

 byte[0] = STATUS_DECODE;
 byte[1] = code;
 byte[2] = type;

 return send_to_rclcn(s2dev,byte,3,RESP_STATUS_DECODE,0,0,message,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int error_decode( char *s2dev, char code , char *message )
{
 char byte[2];

 byte[0] = ERROR_DECODE;
 byte[1] = code;

 return send_to_rclcn(s2dev,byte,2,RESP_ERROR_DECODE,0,0,message,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int diag( char *s2dev, char selftest )
{
 char byte[2];

 byte[0] = DIAG;
 byte[1] = selftest;

 return send_to_rclcn(s2dev,byte,2,RESP_ERR,0,0,0,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int ident( char *s2dev, char *type )
{
 char byte[1];

 byte[0] = IDENT;

 return send_to_rclcn(s2dev,byte,1,RESP_IDENT,0,0,type,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int ping( char *s2dev )
{
 char byte[1];

 byte[0] = PING;

 return send_to_rclcn(s2dev,byte,1,RESP_ERR,0,0,0,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/
int version( char *s2dev, char *sw )
{
 char byte[1];

 byte[0] = VERSION;

 return send_to_rclcn(s2dev,byte,1,RESP_VERSION,0,0,sw,RCL_TIMEOUT);
}
/* --------------------------------------------------------------------------*/









