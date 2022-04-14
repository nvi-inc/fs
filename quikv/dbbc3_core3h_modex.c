/*
 * Copyright (c) 2020-2022 NVI, Inc.
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

#define BUFSIZE 2048

static void add_check_queries( out_recs, out_class, board, all)
    int *out_recs;
    int *out_class;
    char *board;
    int all;
{
    char str[BUFSIZE];

    if(0==strcmp(board," ")) {
        strcpy(str,"version");
        cls_snd(out_class, str, strlen(str) , 0, 0);
        ++*out_recs;
        return;
    }

    strcpy(str,"core3h=");
    strcat(str,board);
    strcat(str,",status_fs");
    cls_snd(out_class, str, strlen(str) , 0, 0);
    ++*out_recs;

    if(all) {
        strcpy(str,"core3h=");
        strcat(str,board);
        strcat(str,",mode_fs");
        cls_snd(out_class, str, strlen(str) , 0, 0);
        ++*out_recs;

        strcpy(str,"core3h=");
        strcat(str,board);
        strcat(str,",splitmode");
        cls_snd(out_class, str, strlen(str) , 0, 0);
        ++*out_recs;

        strcpy(str,"core3h=");
        strcat(str,board);
        strcat(str,",destination 0");
        cls_snd(out_class, str, strlen(str) , 0, 0);
        ++*out_recs;

        strcpy(str,"core3h=");
        strcat(str,board);
        strcat(str,",destination 1");
        cls_snd(out_class, str, strlen(str) , 0, 0);
        ++*out_recs;
    }
}
static void check_board(iboard,board,ip,ierr_out,name)
    int iboard;
    char *board;
    int ip[5];                           /* ipc parameters */
    int *ierr_out;
    char *name;
{
    int out_recs=0;
    int out_class=0;
    int i;
    int nchars;
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int iclass, nrecs;
    char inbuf[BUFSIZE];
    char inbuf2[BUFSIZE];
    char outbuf[BUFSIZE];
    struct dbbc3_core3h_modex_cmd lclc;
    struct dbbc3_core3h_modex_mon lclm;
    int output = 0;
    int ierr=0;

    *ierr_out=0;
    add_check_queries(&out_recs, &out_class, board,0);

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

    iclass=ip[0];
    nrecs=ip[1];
    for (i=0;i<nrecs;i++) {
        if ((nchars =
                    cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
            ierr = -401;
            goto error;
        }

        if(0==strcmp(board," ")) {
            if(strncmp(inbuf,"version/",8)==0) {
                strcpy(outbuf,name);
                strcat(outbuf,"/");
                ierr=dbbc3_version_check(inbuf,outbuf);
                if(ierr!=0) {
                    logit(outbuf,0,NULL);
                    logit(NULL,-450+ierr,"dr");
                    *ierr_out=-599;
                }
            }
        } else {
            strcpy(inbuf2,inbuf);
            switch (i) {
                case 0: case 1:
                    break;
                case 2:
                    if(0!=dbbc3_core3h_status_fs(inbuf,&lclc,&lclm)) {
                        ierr=-502;
                        dbbc3_core3h_modex_log_buf(inbuf,inbuf2,sizeof(inbuf),"dr");
                        goto error;
                    }
                    break;
                 default:
                    break;
            }
        }
    }
    if(0==strcmp(board," ")) {
        if(0!=ierr)
            *ierr_out=-599;
        return;
    }

    if(!shm_addr->dbbc3_core3h_modex[iboard].start.state.known) {
        logitn(NULL,-596,"dr",iboard+1);
    } else if(shm_addr->dbbc3_core3h_modex[iboard].start.start != lclc.start.start) {
        if(lclc.start.start == 0)
            logitn(NULL,-623,"dr",iboard+1);
        else
            logitn(NULL,-624,"dr",iboard+1);
        *ierr_out=-598;
    }
    return;

error:
    if(i!=nrecs-1)
        cls_clr(iclass);
error2:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    ip[4]=0;
    memcpy(ip+3,"dr",2);
    return;
}
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
    int force_set = 0;
    int iboard;
    int kmon;
    int mismatch;

    static char *board[]={" ","1","2","3","4","5","6","7","8"};

    void skd_run(), skd_par();      /* program scheduling utilities */

    if (command->equal != '=') {
        int options;

        for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
           out_class=0;
           out_recs=0;
           add_check_queries(&out_recs, &out_class, board[i+1],1);
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
           options=1;
           if(i==shm_addr->dbbc3_ddc_ifs-1)
             options=0;

           dbbc3_core3h_modex_dis(command,i+1,ip,0,options,1);
           if(ip[2]!=0)
             return;
        }
        return;
    } else if(command->argv[0] != NULL &&
        *command->argv[0] == '?' && command->argv[1] == NULL) {
        int options;

        for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
           out_class=0;
           out_recs=0;

           options=1;
           if(i==shm_addr->dbbc3_ddc_ifs-1)
             options=0;

           dbbc3_core3h_modex_dis(command,i+1,ip,0,options,1);
         }
         return;

    } else if(command->argv[0]!=NULL &&
              (0==strcmp("begin",command->argv[0]) ||
              0==strcmp("end"  ,command->argv[0]))) {
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

        if(0==strcmp(command->argv[0],"begin")) {
            for (i=0;i<MAX_DBBC3_IF;i++) {
                m5state_init(&shm_addr->dbbc3_core3h_modex[i].start.state);
                shm_addr->dbbc3_core3h_modex[i].start.start=0;
                shm_addr->dbbc3_core3h_modex[i].start.state.known=0;
                shm_addr->dbbc3_core3h_modex[i].set=0;
            }
            ip[0]=ip[1]=ip[2]=0;
            return;
        } else if(0==strcmp(command->argv[0],"end")) {
            char str[BUFSIZE];

            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                if(0==shm_addr->dbbc3_core3h_modex[i].set) {
                    m5state_init(&shm_addr->dbbc3_core3h_modex[i].start.state);
                    shm_addr->dbbc3_core3h_modex[i].start.start=0;
                    shm_addr->dbbc3_core3h_modex[i].start.state.known=1;
                    /* invalidate old masks so no Tsys logging or threads */
                    shm_addr->dbbc3_core3h_modex[i].mask2.state.known=0;
                    shm_addr->dbbc3_core3h_modex[i].mask1.state.known=0;
                    /* other stuff to invalidate so not displayed with '?' */
                    shm_addr->dbbc3_core3h_modex[i].decimate.state.known=0;
                    shm_addr->dbbc3_core3h_modex[i].samplerate.state.known=0;
                } else {
                    m5state_init(&shm_addr->dbbc3_core3h_modex[i].start.state);
                    shm_addr->dbbc3_core3h_modex[i].start.start=1;
                    shm_addr->dbbc3_core3h_modex[i].start.state.known=1;
                }
            }
            if(!force) {
                int ierr_version = 0;
                int ierr_output = 0;
                for (i=-1;i<shm_addr->dbbc3_ddc_ifs;i++) {
                    check_board(i,board[i+1],ip,&ierr,command->name);
                    if(ip[2]<0)
                        return;
                    if(ierr!=0) {
                        if(-1==i)
                            ierr_version=ierr;
                        else
                            ierr_output=ierr;
                    }
                }
                if(ierr_version==-599 && ierr_output==-598) {
                    ierr=-597;
                    ip[4]=0;
                    goto error;
                } else if(ierr_version==-599) {
                    ierr=ierr_version;
                    ip[4]=0;
                    goto error;
                } else if(ierr_output==-598) {
                    ierr=ierr_output;
                    ip[4]=0;
                    goto error;
                }
                ip[0]=ip[1]=0;
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
            strcpy(outbuf,"version");
            cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
            out_recs++;

            for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
                strcpy(str,"core3h=");
                strcat(str,board[1+i]);
                if(0==shm_addr->dbbc3_core3h_modex[i].start.start) {
                    strcat(str,",stop");
                } else {
                    strcat(str,",start vdif");
                }
                cls_snd(&out_class, str, strlen(str) , 0, 0);
                out_recs++;
            }
            force_set = 1;
            kmon=0;
            goto dbbcn;
        } else {
            ierr=-305;
            goto error;
        }
    }

    ierr=arg_int(command->argv[0],&iboard,1,FALSE);
    if(ierr==-200 || ierr==-100){
      ierr=-201;
      goto error;
    } else if(iboard<1 || iboard > shm_addr->dbbc3_ddc_ifs) {
        ierr=-201;
        goto error;
    } else if (command->argv[1]!=NULL && *command->argv[1]=='?'
            && command->argv[2] == NULL) {
            dbbc3_core3h_modex_dis(command,iboard,ip,0,0,1);
            return;
    } else if (command->argv[1]==NULL) {
        out_recs=0;
        out_class=0;
        add_check_queries(&out_recs, &out_class, board[iboard],1);
        kmon=1;
        goto dbbcn;
    }

    /* if we get this far it is a set-up command so parse it */

parse:
    ilast=1;                                      /* last argv examined */
    memcpy(&lcl,&shm_addr->dbbc3_core3h_modex[iboard-1],sizeof(lcl));

    count=2;
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

    /* must be called no matter the rack type */
    mismatch=dbbc3_vdif_frame_params(&lcl);
    if(mismatch) {
        ierr=mismatch;
        goto error;
    }

    if(DBBC3_DDCU==shm_addr->equip.rack_type) {
        if(!(lcl.mask1.state.known && lcl.mask1.mask1) &&
                !(lcl.mask2.state.known && lcl.mask2.mask2)) {
            ierr=-311;
            goto error;
        }
    } else if(DBBC3_DDCV==shm_addr->equip.rack_type) {
        if(!(lcl.mask1.state.known && lcl.mask1.mask1)) {
            ierr=-312;
            goto error;
        }
    }

    lcl.set=1; /* needs to be set between the two memcpy()s,
                  discarded for errors in any event
                  also for start
                */
    m5state_init(&lcl.start.state);
    lcl.start.start=1;
    lcl.start.state.known=1;
    memcpy(&shm_addr->dbbc3_core3h_modex[iboard-1],&lcl,sizeof(lcl));
    out_recs=0;
    out_class=0;

    if(!lcl.force.force) {
        add_check_queries(&out_recs, &out_class, board[iboard],1);
        kmon=0;
        goto dbbcn;
    }

    force_set = 1;
    strcpy(outbuf,"version");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    vsi_samplerate_2_dbbc3_core3h(outbuf,&lcl,board[iboard]);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    int ddcu=  DBBC3_DDCU == shm_addr->equip.rack_type;

    strcpy(outbuf,"core3h=");
    strcat(outbuf,board[iboard]);

    if(ddcu)
        strcat(outbuf,",splitmode on");
    else
        strcat(outbuf,",splitmode off");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    int masks=1;
    if(DBBC3_DDCU==shm_addr->equip.rack_type)
        masks=4;
    vsi_bitmask_2_dbbc3_core3h(outbuf,&lcl,board[iboard],masks);
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    strcpy(outbuf,"core3h=");
    strcat(outbuf,board[iboard]);
    strcat(outbuf,",reset");
    cls_snd(&out_class, outbuf, strlen(outbuf) , 0, 0);
    out_recs++;

    vdif_frame_2_dbbc3_core3h(outbuf,&lcl,board[iboard]);
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
    dbbc3_core3h_modex_dis(command,iboard,ip,force_set,0,kmon);
    return;

error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"dr",2);
    return;
}
