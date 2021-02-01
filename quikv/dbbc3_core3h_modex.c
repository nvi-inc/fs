/*
 * Copyright (c) 2020-2021 NVI, Inc.
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
/* dbbc3 core3h_modex SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define BUFSIZE 512

void dbbc3_core3h_modex(command,itask,ip)
    struct cmd_ds *command;                /* parsed command structure */
    int itask;                            /* sub-task, ifd number +1  */
    int ip[5];                           /* ipc parameters */
{
    int ilast, ierr, ind, i, count;
    char *ptr;
    char *arg_next();
    int out_recs, out_class;
    char outbuf[BUFSIZE];
    struct dbbc3_core3h_modex_cmd lcl;
    int increment;

    static char *board[]={"1","2","3","4","5","6","7","8"};

    void skd_run(), skd_par();      /* program scheduling utilities */

    if (29==itask) {
        int force = 0;
        int okay = 0;

        if(NULL==command->argv[0] ||
            NULL!=command->argv[0] &&
            0!=strcmp("begin",command->argv[0]) &&
            0!=strcmp("end"  ,command->argv[0])) {
            ierr=-308;
            goto error;
        }
        if(NULL != command->argv[1]) {
            force=0==strcmp("force",command->argv[1]);
            if(!force && 0!=strcmp("$",command->argv[1]) &&
                    0!=strlen(command->argv[1])) {
                ierr=-304;
                goto error;
            }
            if(NULL != command->argv[2]) {
                okay=0==strcmp("disk_record_ok",command->argv[2]);
                if(!okay && 0!=strlen(command->argv[2])) {
                    ierr=-307;
                    goto error;
                }
            }
        }

        if(0==strcmp(command->argv[0],"begin")) {
            if(force)
                for (i=0;i<MAX_DBBC3_IF;i++)
                    shm_addr->dbbc3_core3h_modex[i].set=0;
            ip[0]=ip[1]=ip[2]=0;
            return;
        } else if(0==strcmp(command->argv[0],"end")) {
            char str[BUFSIZE];

            if(!force) {
                ip[0]=ip[1]=ip[2]=0;
                return;
            }

            if(shm_addr->disk_record.record.record==1 &&
                    shm_addr->disk_record.record.state.known==1)
                if(!okay) {
                    ierr=-301;
                    goto error;
                }

            out_recs=0;
            out_class=0;
            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                strcpy(str,"core3h=");
                strcat(str,board[i]);
                if(0==shm_addr->dbbc3_core3h_modex[i].set)
                    strcat(str,",stop");
                else
                    strcat(str,",start vdif");
                cls_snd(&out_class, str, strlen(str) , 0, 0);
                out_recs++;
            }
            goto dbbcn;
        } else {
            ierr=-305;
            goto error;
        }
    }
    if(itask-29>shm_addr->dbbc3_ddc_ifs) {
        ierr=-306;
        goto error;
    }
    if (command->equal != '=') {
        char str[BUFSIZE];
        out_recs=0;
        out_class=0;

        strcpy(str,"core3h=");
        strcat(str,board[itask-30]);
        strcat(str,",vsi_bitmask");
        cls_snd(&out_class, str, strlen(str) , 0, 0);
        out_recs++;

        strcpy(str,"core3h=");
        strcat(str,board[itask-30]);
        strcat(str,",vsi_samplerate");
        cls_snd(&out_class, str, strlen(str) , 0, 0);
        out_recs++;

        strcpy(str,"core3h=");
        strcat(str,board[itask-30]);
        strcat(str,",sysstat");
        cls_snd(&out_class, str, strlen(str) , 0, 0);
        out_recs++;

        goto dbbcn;
    } else if (command->argv[0]==NULL)
        goto parse;  /* simple equals */
    else if (*command->argv[0]=='?') {
            dbbc3_core3h_modex_dis(command,itask,ip);
            return;
    } else if (0==strcmp(command->argv[0],"stop") ||
            0==strcmp(command->argv[0],"start")) {
        char str[BUFSIZE];
        int force = 0;
        int okay = 0;

        if(NULL != command->argv[1]) {
            force=0==strcmp("force",command->argv[1]);
            if(!force && 0!=strcmp("$",command->argv[1]) &&
                    0!=strlen(command->argv[1])) {
                ierr=-304;
                goto error;
            }
            if(NULL != command->argv[2]) {
                okay=0==strcmp("disk_record_ok",command->argv[2]);
                if(!okay && 0!=strlen(command->argv[2])) {
                    ierr=-307;
                    goto error;
                }
            }
        }

        if(!force) {
            ip[0]=ip[1]=ip[2]=0;
            return;
        }

        if(shm_addr->disk_record.record.record==1 &&
                shm_addr->disk_record.record.state.known==1)
            if(!okay) {
                ierr=-301;
                goto error;
            }

        out_recs=0;
        out_class=0;

        strcpy(str,"core3h=");
        strcat(str,board[itask-30]);

        if(0==strcmp(command->argv[0],"stop")) {
            shm_addr->dbbc3_core3h_modex[itask-30].set=0;
            strcat(str,",stop");
        } else {
            shm_addr->dbbc3_core3h_modex[itask-30].set=1;
            strcat(str,",start vdif");
        }

        cls_snd(&out_class, str, strlen(str) , 0, 0);
        out_recs++;

        goto dbbcn;
    }

    /* if we get this far it is a set-up command so parse it */

parse:
    ilast=0;                                      /* last argv examined */
    memcpy(&lcl,&shm_addr->dbbc3_core3h_modex[itask-30],sizeof(lcl));
    lcl.set=1;

    count=1;
    while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=dbbc3_core3h_modex_dec(&lcl,&count, ptr);
        if(ierr !=0 )
            goto error;
    }

    if(shm_addr->disk_record.record.record==1 &&
            shm_addr->disk_record.record.state.known==1)
        if(lcl.disk.disk!=0 && lcl.disk.state.known==1) {
            ierr=-301;
            goto error;
        }

    if(lcl.mask2.state.known && lcl.mask2.mask2) {
        if(DBBC3_DDCU!=shm_addr->equip.rack_type) {
            ierr=-302;
            goto error;
        }
        if(8 == shm_addr->dbbc3_ddc_bbcs_per_if ||
                (12 == shm_addr->dbbc3_ddc_bbcs_per_if &&
                 lcl.mask2.mask2 & 0xFFFF0000)) {
            ierr=-303;
            goto error;
        }
    }

    memcpy(&shm_addr->dbbc3_core3h_modex[itask-30],&lcl,sizeof(lcl));

    out_recs=0;
    out_class=0;

    strcpy(outbuf,"version");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    vsi_samplerate_2_dbbc3_core3h(outbuf,&lcl,board[itask-30]);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    int masks=1;
    if(DBBC3_DDCU==shm_addr->equip.rack_type)
        masks=4;
    vsi_bitmask_2_dbbc3_core3h(outbuf,&lcl,board[itask-30],masks);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    strcpy(outbuf,"core3h=");
    strcat(outbuf,board[itask-30]);
    strcat(outbuf,",reset");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    vdif_frame_2_dbbc3_core3h(outbuf,&lcl,board[itask-30]);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

dbbcn:
    ip[0]=9;
    ip[1]=out_class;
    ip[2]=out_recs;
    skd_run("dbbcn",'w',ip);
    skd_par(ip);

    if(ip[2]<0) {
        if(ip[0]!=0) {
            cls_clr(ip[0]);
            ip[0]=ip[1]=0;
        }
        return;
    }
    dbbc3_core3h_modex_dis(command,itask,ip);
    return;

error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"dr",2);
    return;
} 
