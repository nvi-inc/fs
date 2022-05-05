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
/* chekr s2 rec routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl_def.h"
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define CHKERR  -800

static void logerr( int err )
{
 if( err < -130 )
  logita( 0 , err , "RL" , EDAS );
 else
   logit( 0 , err , EDAS );
}
void s2daschk_( char *lwho )
{
 char agc, encode, mode[21];
 char FSstatus, CurState, NumStates, SeqName[25];
 char summary, nbr;
 int  err, i;
 int  chk[5];
 unsigned short FSperiod; 
 S2_STATUS list[32];

 if( !shm_addr->s2das.check )
   return; /* check is deseable */

 for( i = 0 ; i < 5 ; i++ )
   chk[i] = GetBitState(shm_addr->s2das.check,i);

 nsem_take( "fsctl" , 0 );

 /* Read and check s2-das settings */
 if( chk[0] )
    if(  err = agc_read( DAS, &agc ) )
      { logerr( err ); chk[0] = 0; }
 if( chk[1] )
    if(  err = mode_read(DAS, mode ) )
      { logerr( err ); chk[1] = 0; }
 if( chk[2] )
    if(  err = encode_read( DAS, &encode ) )
      { logerr( err ); chk[2] = 0; }
 if( chk[3] )
    if( err = fs_read(DAS, &FSstatus, &CurState, &NumStates
                     , &FSperiod , SeqName )
       )
      { logerr( err ); chk[3] = 0; }

 nsem_put( "fsctl" );

 /* check with data in memory */
 if( chk[0] && agc != shm_addr->s2das.agc )
    logita( 0 , CHKERR - 1 , lwho , DAS );
 if( chk[1] && strcasecmp( mode , shm_addr->s2das.mode ) )
    logita( 0 , CHKERR - 2 , lwho , DAS );
 if( chk[2] && encode != shm_addr->s2das.encode )
    logita( 0 , CHKERR - 3 , lwho , DAS );
 if( chk[3] )
   {
    if( FSstatus != shm_addr->s2das.FSstatus )
       logita( 0 , CHKERR - 4 , lwho , DAS );
    if( FSstatus == 2 &&  strcasecmp( SeqName, shm_addr->s2das.SeqName ) )
       logita( 0 , CHKERR - 5 , lwho , DAS );
   }

 /* Check s2das status */
 if( !chk[4] ) return;

 nsem_take( "fsctl" , 0 );

 if( err = status_read( DAS, 0, 2, 1, &summary , &nbr , list ) )
    logerr( err );
 nsem_put( "fsctl" );
 
 if( !err )
    for( i = 0 ; i < nbr ; i++ )
        logite(list[i].report,-list[i].code,"dz");
}
