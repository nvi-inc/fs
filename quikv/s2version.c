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
#define ATTN_MAX   30

/* S2 mode SNAP command */
void s2version( struct cmd_ds *command , int task , int *ip )
{
 int   ierr = 0;
 char  id[61], ver[61];
 char  output[MAX_OUT];
 int   i, rec;
 int   last = 0;
 char *device = arg_next( command , &last );

 for( i = 0 ; i < 5 ; i++ ) ip[i] = 0;

 if( command->equal != '=' || !device || strlen( device) < 2 )
    return s2err( INFO_BAD_PARM , ip  , QDAS );

 if( ierr = ident( device , id ) )
    return s2err( ierr , ip , device );
 if( ierr = version( device , ver ) )
    return s2err( ierr , ip  , device );

 sprintf( output , "%s/%s,%s" , command->name , id , ver );
 cls_snd(ip,output,strlen(output),0,0);
 ip[1] = 1;
}







