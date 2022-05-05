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

/* S2 agc SNAP command */
void s2agc( struct cmd_ds *command , int itask , int *ip )
{
 int  ierr = 0;
 int  i, last = 0;
 char code, *parm;
 char output[MAX_OUT];

 if( command->equal == '=' && ( parm = arg_next(command,&last) ) )
   {
    if( !str2agc( parm , &code ) || !code )
       return s2err( AGC_BAD_MODE , ip , QDAS );

    if( ierr = agc_set( DAS , code ) )
       return s2err( ierr , ip , EDAS );

    shm_addr->s2das.agc = code; /* store in memory */

    cls_clr( ip[0] ); ip[0]=ip[1]=0;
    return;
   }
 else if( !parm ) /* display value in memory */
    code = shm_addr->s2das.agc;
 else if( ierr = agc_read( DAS , &code) ) /* Read encode scheme */
    return s2err( ierr , ip , EDAS );

 sprintf( output , "%s/%s" , command->name , agc2str( code ) );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}




