/*
 * Copyright (c) 2025 NVI, Inc.
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

char *getenv_DBBC3_string( char *env, char **actual_p, char **nominal_p, int *error_p, int options)
{
    char *ptr;
    char *actual, *nominal;
    int error, i;

    error=0;
    ptr=getenv(env);

    if(0==strcmp(env,"FS_DBBC3_CORE3H_MODE_FORCE_DEFAULT")) {
        nominal="check";
        if(NULL != ptr) {
            char *values[ ] ={
                "check",
                "force",
                "keepsync",
                "noreset",
                "resetlast",
                "keepsynclast",
                NULL};
            for (i=0;NULL!=values[i];i++)
                if(!strcmp(ptr,values[i]))
                    break;
            if(NULL==values[i]) {
                error=-2;
                if(0x1 & options) {
                    char buf[128];
                    snprintf(buf,128,"Unknown value for '%s': '%s'.",env,ptr);
                    logite(buf,-997,"bo");
                    exit(-1);
                }
            }
            actual=ptr;
        } else
            actual=nominal;
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
