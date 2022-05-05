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
#include "../s2das/rcl_das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  2048

static char code[3] = { DELAYM_READ, WVFDELAYM_READ, GPSDELAYM_READ };

/* S2 delay SNAP command */
void s2delay( struct cmd_ds *command , int itask , int *ip )
{
 int  err = 0;
 int  i;
 char output[MAX_OUT];
 int delay;
 char Txt[3][100];

 if( command->equal == '=' )
    return s2err( DELAY_BAD_PARM , ip , QDAS );

 for( i = 0 ; i < 3 ; i++ )
     if( ( err = delay_read( DAS , code[i] , &delay ) ) == ERR_NONE )
        sprintf( Txt[i] , "%d" , delay );
     else
        sprintf( Txt[i] , "err(%d)" , err );

 sprintf( output , "%s/%s,%s,%s" , command->name
        , Txt[0] , Txt[1] , Txt[2] );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;

 return;
}




