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

#include <stdio.h>
#include <string.h>

char *getenv_DBBC3( char *env, int *actual, int *nominal, int *error, int options);

void log_env_dbbc3__()
{
    char *ptr;
    int i,actual, nominal, error;
    char buf[128];
    char *env[ ]= {
                   "FS_DBBC3_MULTICAST_BBC_TPI_USB_LSB_SWAP",
                   "FS_DBBC3_MULTICAST_BBC_ON_OFF_SWAP",
                   "FS_DBBC3_MULTICAST_CORE3H_POLARITY0_ON_OFF_SWAP",
                   "FS_DBBC3_MULTICAST_CORE3H_POLARITY2_ON_OFF_SWAP",
                   "FS_DBBC3_MULTICAST_CORE3H_TIME_ADD_SECONDS",
                   "FS_DBBC3_MULTICAST_CORE3H_TIME_INCLUDED",
                   "FS_DBBC3_MULTICAST_CORE3H_VDIF_EPOCH_INSERTED",
                   "FS_DBBC3_MULTICAST_VERSION_ERROR_MINUTES",
                   "FS_DBBC3_BBCNNN_TPI_USB_LSB_SWAP",
                   "FS_DBBC3_BBCNNN_GAIN_USB_LSB_SWAP",
                   "FS_DBBC3_BBCNNN_ON_OFF_SWAP",
                   "FS_DBBC3_IFTPX_POLARITY0_ON_OFF_SWAP",
                   "FS_DBBC3_IFTPX_POLARITY2_ON_OFF_SWAP",
                   "FS_DBBC3_BBC_GAIN_USB_LSB_SWAP",
                   NULL };

    for (i=0;i<sizeof(env)/sizeof(char *)-1;i++) {
        ptr=getenv_DBBC3(env[i],&actual,&nominal,&error,1);
        if(0==error && actual!=nominal) {
           snprintf(buf,128,"%s,%d,(%d)",env[i],actual,nominal);
           logits(buf,0,NULL,':');
        }
    }
}
