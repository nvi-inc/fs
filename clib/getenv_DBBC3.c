/*
 * Copyright (c) 2023-2024 NVI, Inc.
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#define TYPICALB0 nominal=0;\
                  if(NULL!=ptr && 0==strcmp(ptr,"1"))\
                      actual=1;\
                  else if(NULL!=ptr)\
                      actual=0;\
                  else\
                      actual=nominal;

#define TYPICALB1 nominal=1;\
                  if(NULL!=ptr && 0==strcmp(ptr,"1"))\
                      actual=1;\
                  else if(NULL!=ptr)\
                      actual=0;\
                  else\
                      actual=nominal;

#define TYPICALN0 nominal=0;\
                  if(NULL!=ptr)\
                      actual=atoi(ptr);\
                  else\
                      actual=nominal;

char *getenv_DBBC3( char *env, int *actual_p, int *nominal_p, int *error_p, int options)
{
    char *ptr;
    int actual, nominal, error;

    error=0;
    ptr=getenv(env);

    if(0==strcmp(env,"FS_DBBC3_MULTICAST_BBC_TPI_USB_LSB_SWAP")) {
        TYPICALB1
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_BBC_ON_OFF_SWAP")) {
        TYPICALB0
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_CORE3H_POLARITY0_ON_OFF_SWAP")) {
        TYPICALB0
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_CORE3H_POLARITY2_ON_OFF_SWAP")) {
        TYPICALB1
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_CORE3H_TIME_ADD_SECONDS")) {
        TYPICALN0
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_CORE3H_TIME_INCLUDED")) {
        if(DBBC3==shm_addr->equip.rack &&
           DBBC3_DDCV == shm_addr->equip.rack_type && shm_addr->dbbc3_ddcv_v<126)
             nominal=0;
         else
             nominal=1;
         if(NULL!=ptr && 0==strcmp(ptr,"1"))
             actual=1;
         else if(NULL!=ptr)
             actual=0;
         else
             actual=nominal;
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_CORE3H_VDIF_EPOCH_INSERTED")) {
        if(DBBC3==shm_addr->equip.rack &&
           DBBC3_DDCV == shm_addr->equip.rack_type && shm_addr->dbbc3_ddcv_v==126)
             nominal=1;
         else
             nominal=0;
         if(NULL!=ptr && 0==strcmp(ptr,"1"))
             actual=1;
         else if(NULL!=ptr)
             actual=0;
         else
             actual=nominal;
    } else if(0==strcmp(env,"FS_DBBC3_MULTICAST_VERSION_ERROR_MINUTES")) {
        nominal=1;
        if(NULL!=ptr && 0==strcmp(ptr,"0"))
// maybe someday allow disabling it
//            actual=0;
            actual=nominal;
        else if(NULL!=ptr) {
            actual=atoi(ptr);
            if(actual<1 || actual>10)
              actual=nominal;
        } else
            actual=nominal;
    } else if(0==strcmp(env,"FS_DBBC3_BBCNNN_TPI_USB_LSB_SWAP")) {
        TYPICALB1
    } else if(0==strcmp(env,"FS_DBBC3_BBCNNN_GAIN_USB_LSB_SWAP")) {
        TYPICALB1
    } else if(0==strcmp(env,"FS_DBBC3_BBCNNN_ON_OFF_SWAP")) {
        TYPICALB0
    } else if(0==strcmp(env,"FS_DBBC3_IFTPX_POLARITY0_ON_OFF_SWAP")) {
        TYPICALB0
    } else if(0==strcmp(env,"FS_DBBC3_IFTPX_POLARITY2_ON_OFF_SWAP")) {
        TYPICALB1
    } else if(0==strcmp(env,"FS_DBBC3_BBC_GAIN_USB_LSB_SWAP")) {
        TYPICALB1
    } else {
        error=-1;
        if(0x1 & options) {
           char buf[128];
           snprintf(buf,128,"Unknown environment variable: '%s'",env);
           logite(buf,-997,"bo");
        }
    }

    if(NULL!=actual_p)
        *actual_p=actual;
    if(NULL!=nominal_p)
        *nominal_p=nominal;
    if(NULL!=error_p)
        *error_p=error;

    return ptr;
}
