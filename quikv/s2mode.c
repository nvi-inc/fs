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

char *arg_next( struct cmd_ds *command, int *last );

/* S2 mode SNAP command */
void s2mode( struct cmd_ds *command, int itask, int *ip )
{
 int   ierr = 0;
 int   i;
 int   last = 0;
 int   force;
 char *ptr;
 char  mode[21];
 char  output[MAX_OUT];

 char *parm = arg_next( command , &last );

 if( command->equal == '=' && parm ) /* Set mode */
   {
    force = 0;
    if( ( ptr = arg_next(command,&last) ) && !strcmp( ptr , "yes" ) )
       force =1;
 
    if( ierr = mode_set( "da" , parm , force ) )
       return s2err( ierr , ip  , "DA" );

    strcpy( shm_addr->s2das.mode , parm ); /* store in memory */

    cls_clr(ip[0]); ip[0]=ip[1]=0;
    return; 
   }
 if( command->equal == '=' ) /* display mode in memory */
   strcpy( mode , shm_addr->s2das.mode );
 else if( ierr = mode_read( "da" , mode ) )/*read mode from DAS */
    return s2err( ierr , ip  , "DA" );

 sprintf( output , "%s/%s" , command->name , mode );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}







