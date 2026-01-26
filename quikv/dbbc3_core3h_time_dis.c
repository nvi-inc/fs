/*
 * Copyright (c) 2026 NVI, Inc.
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
/* dbbc3 coreh_time display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 513

int logmsg_dbbc3();

void dbbc3_core3h_time_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
    struct dbbc3_core3h_time_mon lclm;
    int ind,kcom,i,ich, ierr, count;
    char output[MAX_OUT];
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    char inbuf[BUFSIZE];

    for (i=0;i<ip[1];i++) {
        if ((nchars =
                    cls_rcv(ip[0],inbuf,BUFSIZE-1,&rtn1,&rtn2,msgflg,save)) <= 0) {
            ierr =  -401;
            goto error2;
        }
        inbuf[nchars]=0;
        if(i<7) {
            ierr=dbbc3_2_core3h_time(i,&lclm,inbuf);
            if(ierr!=0) {
                ierr=-403;
                if(i==0)
                    logite(inbuf,-402,"dl");
                else
                    logite(inbuf+1,-402,"dl");
                goto error2;
            }
        } else {
            ierr=dbbc3_2_core3h_time(i,&lclm,inbuf);
            if(ierr!=0) {
                ierr=-404;
                goto error2;
            }
        }
    }

    /* format output buffer */

    strcpy(output,command->name);
    strcat(output,"/");

    count=0;
    while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dbbc3_core3h_time_mon(output,&count,&lclm);
    }

    if(strlen(output)>0) output[strlen(output)-1]='\0';

    for (i=0;i<5;i++) ip[i]=0;
    cls_snd(&ip[0],output,strlen(output),0,0);
    ip[1]=1;
    if(!strcmp(lclm.time,"2000-01-01T00:00:00")) {
      logitn(NULL,-405,"dl",lclm.iboard);
      ip[2]=-408;
    } else {
      if(shm_addr->dbbc3_core3h_time.previous_epoch >=0 &&
              shm_addr->dbbc3_core3h_time.previous_epoch != lclm.vdif_epoch) {
        logitn(NULL,-407,"dl",lclm.iboard);
        ip[2]=-408;
      }
      if(lclm.seconds_fm-lclm.seconds_fs != 0) {
        logitn(NULL,-406,"dl",lclm.iboard);
      }
    }
    shm_addr->dbbc3_core3h_time.previous_epoch = lclm.vdif_epoch;
    if(ip[2]!=0) {
        char str[3];
        memcpy(ip+3,"dl",2);
        snprintf(str,3,"%2d",lclm.iboard);
        memcpy(ip+4,str,2);
      }
    return;

error2:
    if(i<ip[1]-1)
        cls_clr(ip[0]);
error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"dl",2);
    return;
}
