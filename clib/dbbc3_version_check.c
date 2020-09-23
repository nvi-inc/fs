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
#include <ctype.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int dbbc3_version_check(char *inbuf, char *output)
{
    int j, ierr;
    char test_buf[sizeof(shm_addr->dbbc3_ddcu_vs)];
    char *comma;

    ierr=0;

    /*                      12345678 */
    /* in buff starts with "version/", but may have any extra space after '/' */

    if(inbuf[8] == ' ') {
        int i,len=strlen(inbuf);
        for (i=9;i<=len;i++) { /* <= to move trailing \0 */
            inbuf[i-1]=inbuf[i];
        }
    }
    strncpy(test_buf,inbuf+14,sizeof(test_buf));
    test_buf[sizeof(test_buf)-1]=0;

    comma=strchr(test_buf,',');
    if(NULL!=comma)
        *comma=0;

    for(j=0;j<strlen(test_buf);j++)
        test_buf[j]=tolower(test_buf[j]);

    if(DBBC3_DDCU == shm_addr->equip.rack_type) {
        /*                   123456789012 */
		if(strncmp(inbuf+8 ,"DDC_U,",6)==0) {
			if(strncmp(test_buf,shm_addr->dbbc3_ddcu_vs,shm_addr->dbbc3_ddcu_vc)!=0 ||
					strlen(test_buf)!=shm_addr->dbbc3_ddcu_vc)
				ierr = -2;
		} else if(strncmp(inbuf+8 ,"DDC_V,",6)==0)
			ierr = -3;
		else
			ierr = -5;
    } else if(DBBC3_DDCV == shm_addr->equip.rack_type) {

        /*                   123456789012 */
		if(strncmp(inbuf+8 ,"DDC_V,",6)==0) {
			if(strncmp(test_buf,shm_addr->dbbc3_ddcv_vs,shm_addr->dbbc3_ddcv_vc)!=0 ||
					strlen(test_buf)!=shm_addr->dbbc3_ddcv_vc) 
				ierr = -2;
		} else if(strncmp(inbuf+8 ,"DDC_U,",6)==0)
			ierr = -4;
		 else 
			ierr = -5;
    } else {
        ierr=-6;
    }
    if(NULL !=output && ierr!=-6 && ierr != 0) {
        if(output[strlen(output)-1]!='/')
            strcat(output,",");
        strcat(output,inbuf);
    }
    return ierr;
}
