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

/* S2 diag SNAP command */

void s2diag(struct cmd_ds *command , int itask , int *ip )
{
 int   ierr, code;
 char *parm = 0;
 int   last = 0;

 if(    command->equal != '='
    || !( parm = arg_next(command,&last) )
   )
    return s2err( DIAG_BAD_PARM , ip , QDAS );

 if( !strcmp( parm , "self1" ) )
    code = 1;
 else
    return s2err( DIAG_BAD_PARM , ip , QDAS );

 if( ierr = diag( DAS , 1 ) )
    return s2err( ierr , ip , EDAS );

 cls_clr( ip[0] ); ip[0] = ip[1] = 0;
}







