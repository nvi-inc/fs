#include "message.h"
#include <string.h>
#include <stdio.h>

/* --------------------------------------------------------------------------*/
#define MAX_BUFFER  90

static char Title[100] = "";
static char Buffer[256];
static int  length = MAX_BUFFER;

/* --------------------------------------------------------------------------*/
void init_message( long *ip , char *title )
{
 int i;
 for( i = 0 ; i < 5 ; i++ )
     ip[i] = 0;

 length = MAX_BUFFER;

 strcpy( Buffer , "" );
 strcpy( Title , title );
}
/* --------------------------------------------------------------------------*/
void clear_message( long *ip )
{
 cls_clr( ip[0] );
}
/* --------------------------------------------------------------------------*/
void send_message( long *ip )
{
 int len = strlen( Buffer );

 if( len )
   {
    cls_snd( ip , Buffer , len , 0 , 0 );
    ip[1]++;
   }
}
/* --------------------------------------------------------------------------*/
void reset_message( long *ip , char *title )
{
 send_message( ip );
 length = MAX_BUFFER;

 strcpy( Buffer , "" );
 strcpy( Title , title );
} 
/* --------------------------------------------------------------------------*/
void add_message( long *ip , char *text )
{
 if( length + strlen( text ) > MAX_BUFFER )
   {
    send_message( ip );
    sprintf( Buffer , "%s" , Title );
    if( text[0] == ',' )text++; /* remove first comma */
   }
 strcat( Buffer , text );
 length = strlen( Buffer );
}
/* --------------------------------------------------------------------------*/


