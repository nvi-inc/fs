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
#include <stdlib.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../s2das/s2das.h"
#include "../s2das/s2das_util.h"

#define MAX_OUT  2048
#define ATTN_MAX   30

static char *fs_status( char code )
{
 static char *list[] = {"stop","wait","run","halt"};
 if( code < 0 || code > 3 )
   return "unknown";
 return list[code];
}
/* S2 fs SNAP command */
void s2fs(struct cmd_ds *command , int itask , int *ip )
{
 int    err = 0;
 int    i, j, rec;
 char   mode[21], Txt[100];
 char   output[MAX_OUT], StateId, BBCid, IFswt, Id, src[4], attn[4], swt;
 char   FSstatus, CurrentState, NumStates;
 char   SeqName[25], CurName[25];
 unsigned int LOfreq, LOnew, TPI[2];
 unsigned short FSperiod, TPIavg;
 char   DoNotChange[4] = { -128, -128, -128, -128 };
 char          IFnew, BWcode[2], AGCmode, LOlock, AGClock;
 short int     Gain[2];
 int   full_list = 0;
 int   last = 0;
 char *action = arg_next( command , &last );
 char *parm   = arg_next( command , &last );

 strcpy( SeqName , parm ? parm : "" );

 /* Read mode */
 if( command->equal != '='
     || ( action && ( full_list = !strcmp( action , "list" ) ) )
   )
   {
    for( i = 0 ; i < 5 ; i++ )
        ip[i] = 0;
    rec = 0;
    /* read fs status */
    if( err = fs_read(DAS, &FSstatus, &CurrentState, &NumStates
                   , &FSperiod , CurName )
      )
       return s2err( err , ip , EDAS );

    if( CurName[0] == '\0' )
      {
       sprintf( output , "%s/frequency switching not running"
              , command->name );
       cls_snd(ip,output,strlen(output),0,0);
       rec = 1;
      }
    else
      {
       sprintf( output , "%s/%s,%s,%d,%d,%.2lf"
              , command->name , CurName , fs_status( FSstatus )
              , (int)CurrentState , (int)NumStates
              , (double)( FSperiod / 100.0 )
              );
       cls_snd(ip,output,strlen(output),0,0);
       rec = 1;
       if( full_list )
          for( Id = 1 ; Id <= NumStates ; Id++ , rec++ )
	     {
              StateId = Id;
              sprintf( output , "%s/state,%02d" , command->name , Id );
              for( BBCid = 1 ; BBCid < 5 ; BBCid++ )
	         {
                  err = bbc_read(DAS,BBCid,&StateId,&LOnew,&IFnew,BWcode
                           ,&TPIavg,&AGCmode,Gain,&LOlock,&AGClock,TPI);
                  if( err == -14 ) continue;
                  sprintf( Txt , ",%d,%.2lf,i%d",BBCid,LOnew/1.0E6,IFnew );
                  if( !err )
                     err = ifx_read(DAS,&StateId,attn,src,&TPIavg,TPI);
                  strcat( Txt , (src[IFnew-1] == 2 ) ? "a" : "" );
                  if( err )  
                    { cls_clr(ip[0]); return s2err( err , ip , EDAS ); }
                  strcat( output , Txt );
                 }
              cls_snd(ip,output,strlen(output),0,0);
             }
      }
    ip[1] = rec;
    return;
   }

 if( !action )
   return s2err( FS_BAD_OPTION , ip , QDAS );

 if( !strcmp( action , "start" ) ) /* fs start */
   {
    /* read das to see if fs is running */
    if( err = fs_read(DAS, &FSstatus, &CurrentState, &NumStates
                   , &FSperiod , CurName )
      ) return s2err( err , ip , EDAS );
    if( FSstatus == 2 && SeqName[0] != '\0' && strcmp( SeqName , CurName ) )
      {
       FSstatus = 0;
       if( err = fs_stop( DAS ) )
          return s2err( err , ip , EDAS );
      }
    if( SeqName[0] == '\0' || FSstatus != 2 )
       if( err = fs_start( DAS , SeqName ) )
          return s2err( err , ip , EDAS );

    shm_addr->s2das.FSstatus = 2; /* store in memory */
    strcpy( shm_addr->s2das.SeqName , SeqName[0] ? SeqName : CurName );
   }
 else if( !strcmp( action , "stop" ) )
   {
    if( err = fs_stop( DAS ) ) return s2err( err , ip , EDAS );
    shm_addr->s2das.FSstatus = 0; /* store in memory */
   }
 else if( !strcmp( action , "halt" ) )
   {
    if( err = fs_halt( DAS ) ) return s2err( err , ip , EDAS );
    shm_addr->s2das.FSstatus = 3; /* store in memory */
   }
 else if( !strcmp( action , "load" ) )
   {
    if( err = fs_load( DAS , SeqName ) ) return s2err( err , ip , EDAS );
    shm_addr->s2das.FSstatus = 3; /* store in memory */
    strcpy( shm_addr->s2das.SeqName , "" );
   }
 else if( !strcmp( action , "init" ) )
   {
    if( !str2state( SeqName , &NumStates ) ) 
       return s2err( FS_BAD_NUM_STATES , ip , QDAS );
    if( !str2period( arg_next(command,&last),&FSperiod ) )
       return s2err( FS_BAD_PERIOD , ip , QDAS );
    if( err = fs_init( DAS , NumStates , FSperiod ) )
       return s2err( err , ip , EDAS );
    shm_addr->s2das.FSstatus = 3; /* store in memory */
    strcpy( shm_addr->s2das.SeqName , "unnamed" );
   }
 else if( !strcmp( action , "save" ) )
   {
    if( err = fs_save( DAS , SeqName ) ) return s2err( err , ip , EDAS );
    strcpy( shm_addr->s2das.SeqName , SeqName );
   }    
 else if( !strcmp( action , "state" ) )
   {
    if( !str2state( SeqName , &StateId ) )
       return s2err( FS_BAD_STATE , ip , QDAS  );
    if( err = fs_state( DAS , StateId , 0 ) )
       return s2err( err , ip , EDAS  );

    for( j = 0 ; j < 4 ; j++ )
       { src[j] = 1; attn[j] = -128; }
    while( parm = arg_next(command,&last ) )
         {
	  BBCid = atoi( parm );
	  if( BBCid < 1 || BBCid > 4  )
	    return s2err( FS_BAD_BBC , ip , QDAS ); 
	  if( !str2lofreq( arg_next(command,&last) , &LOfreq ) )
	    return s2err( FS_BAD_LOFREQ , ip , QDAS ); 
	  if( !str2ifsrc( arg_next( command,&last) , &IFswt , &swt ) )
	    return s2err( FS_BAD_IFSRC  , ip , QDAS ); 
          if( err = bbc_set(DAS,BBCid,LOfreq,IFswt,DoNotChange,0,0) )
             return s2err( err , ip , EDAS  );
          src[IFswt-1] = swt;
         }
    if( err = ifx_set(DAS,attn,src,0) )
       return s2err( err , ip , EDAS  );
   }
 else
   return s2err( FS_BAD_OPTION , ip , QDAS );

 cls_clr( ip[0] ); ip[0] = ip[1] = 0;
}











