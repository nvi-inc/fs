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
#include "message.h"
#include <string.h>
#include <stdio.h>

/* --------------------------------------------------------------------------*/
#define MAX_BUFFER  90

static char Title[100] = "";
static char Buffer[256];
static int  length = MAX_BUFFER;

/* --------------------------------------------------------------------------*/
void init_message( int *ip , char *title )
{
 int i;
 for( i = 0 ; i < 5 ; i++ )
     ip[i] = 0;

 length = MAX_BUFFER;

 strcpy( Buffer , "" );
 strcpy( Title , title );
}
/* --------------------------------------------------------------------------*/
void clear_message( int *ip )
{
 cls_clr( ip[0] );
}
/* --------------------------------------------------------------------------*/
void send_message( int *ip )
{
 int len = strlen( Buffer );

 if( len )
   {
    cls_snd( ip , Buffer , len , 0 , 0 );
    ip[1]++;
   }
}
/* --------------------------------------------------------------------------*/
void reset_message( int *ip , char *title )
{
 send_message( ip );
 length = MAX_BUFFER;

 strcpy( Buffer , "" );
 strcpy( Title , title );
} 
/* --------------------------------------------------------------------------*/
void add_message( int *ip , char *text )
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


