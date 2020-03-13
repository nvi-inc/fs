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

/* S2 SNAP command */

#define MAX_TST 5

static char *List[] = {"agc","mode","encode","fs","status" };

static int GetTestIndex( char *Name )
{
 int i;

 for( i = 0 ; i < MAX_TST ; i++ )
   if( !strcmp( List[i] , Name ) )
     return i;
 return -1;
}
void s2chkr( struct cmd_ds *command , int itask , int *ip )
{
 int  i, n, last = 0;
 char *parm;
 char output[MAX_OUT];
 int  state;
 if( command->equal == '=' )
   {
    while( parm = arg_next(command,&last) )
         {
	  state = 1; /* set check flag on */
          if( parm[0] == '+' )
	     parm++;
          else if( parm[0] == '-' )
            { state = 0; parm++; }
          if( !strcmp( parm , "none" ) )
             shm_addr->s2das.check = 0x0000;
          else if( !strcmp( parm , "all" ) )
             shm_addr->s2das.check = state ? 0x1F : 0x0000;
          else if( ( i = GetTestIndex( parm ) ) != -1 )
	     SetBitState( &shm_addr->s2das.check , i , state );
         }    

    cls_clr( ip[0] ); ip[0]=ip[1]=0;
    return;
   }
 sprintf( output , "%s/" , command->name );
 if( shm_addr->s2das.check == 0 )
   strcat( output , "no checks" );
 else
   for( i = 0 , n = 0 ; i < MAX_TST ; i++ )
       if( GetBitState(shm_addr->s2das.check,i) )
         {
	  if( n++ > 0 ) strcat( output , "," );
	  strcat( output , List[i] ); 
         }

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}




