/*
 * Copyright (c) 2022, 2023 NVI, Inc.
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
#include <ctype.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#include "packet.h"
#include "dbtcn.h"

extern struct fscom *shm_addr;

void version_check( dbbc3_ddc_multicast_t *t)
{
    char test[sizeof(t->version)+1];
    int j;
    int ierr=0;
    static int old_ierr;
    static int version_error;
    char *ptr;
    static int minutes=-1;

    memcpy(test,t->version,sizeof(test)-1);
    test[sizeof(test)-1]=0;

    for(j=0;j<strlen(test);j++)
        test[j]=tolower(test[j]);

    ptr=strtok(test," ,");
    if(ptr==NULL) {
       ierr=-31;
    } else if(DBBC3_DDCU == shm_addr->equip.rack_type) {
      if(strcmp(ptr,"ddc_u")==0) {
        ptr=strtok(NULL," ,");
        if(ptr==NULL) {
          ierr=-32;
        } else if(strncmp(ptr,shm_addr->dbbc3_ddcu_vs,shm_addr->dbbc3_ddcu_vc)!=0 ||
            strlen(ptr)!=shm_addr->dbbc3_ddcu_vc) {
          ierr = -33;
        }
      } else if(strcmp(ptr,"ddc_v")==0) {
        ierr = -34;
      } else if(strcmp(ptr,"ddc_e")==0) {
        ierr = -39;
      } else {
        ierr = -35;
      }
    } else if(DBBC3_DDCV == shm_addr->equip.rack_type) {
      if(strcmp(ptr,"ddc_v")==0) {
        ptr=strtok(NULL," ,");
        if(ptr==NULL) {
          ierr=-32;
        } else if(strncmp(ptr,shm_addr->dbbc3_ddcv_vs,shm_addr->dbbc3_ddcv_vc)!=0 ||
            strlen(ptr)!=shm_addr->dbbc3_ddcv_vc) {
          ierr = -36;
        }
      } else if(strcmp(ptr,"ddc_u")==0) {
        ierr = -37;
      } else if(strcmp(ptr,"ddc_e")==0) {
        ierr = -40;
      } else {
        ierr = -35;
      }
    } else if(DBBC3_DDCE == shm_addr->equip.rack_type) {
      if(strcmp(ptr,"ddc_e")==0) {
        ptr=strtok(NULL," ,");
        if(ptr==NULL) {
          ierr=-32;
        } else if(strncmp(ptr,shm_addr->dbbc3_ddce_vs,shm_addr->dbbc3_ddce_vc)!=0 ||
            strlen(ptr)!=shm_addr->dbbc3_ddce_vc) {
          ierr = -41;
        }
      } else if(strcmp(ptr,"ddc_u")==0) {
        ierr = -42;
      } else if(strcmp(ptr,"ddc_v")==0) {
        ierr = -43;
      } else {
        ierr = -35;
      }
    } else {
      ierr=-38;
    }

    if(0>minutes) {
        ptr=getenv("FS_DBBC3_MULTICAST_VERSION_ERROR_MINUTES");
        if(NULL!=ptr && !strcmp(ptr,"0"))
// maybe someday allow disabling it
//            minutes=0;
            minutes=1;
        else if(NULL!=ptr) {
            minutes=atoi(ptr);
            if(minutes<1 || minutes >10)
              minutes=1;
        } else
            minutes=1;
    }
    if(0==ierr) {
       old_ierr=0;
    } else {
      if(ierr!=old_ierr)
        version_error=0;
      if(0 < minutes)
        version_error=version_error%(minutes*60)+1;
      if(0 < minutes && version_error==1) {
        if(-38!=ierr) {
          int i;
          char prefix[ ]={"DBBC3 multicast version: "};
          char buff[sizeof(t->version)+sizeof(prefix)];
          int iout=sizeof(prefix)-1;
          strcpy(buff,prefix);
          for(j=0;j<sizeof(t->version);j++) {
            if(' '==t->version[j])
              continue;
            for (i=j;i<sizeof(t->version);i++) {
               if(0==t->version[i])
                  break;
               buff[iout++]=t->version[i];
            }
            buff[iout]=0;
            break;
          }
          logite(buff,-30,"dn");
        }
        logit(NULL,ierr,"dn");
        old_ierr=ierr;
      }
    }
}
