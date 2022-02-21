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
/* dbbc3 core3h_modex SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define BUFSIZE 2048

void dbbc3_core3h_modex_dis(command,iboard,ip,force_set,options,kmon)
    struct cmd_ds *command;
    int iboard;
    int ip[5];
    int force_set;
    int options;
    int kmon;
{
    int ierr, count, i;
    char output[MAX_OUT];
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    static int out_class=0;
    static int out_recs=0;
    static int overall_error=0;
    char inbuf[BUFSIZE];
    int kcom;
    int iclass, nrecs;
    struct dbbc3_core3h_modex_cmd lclc;
    struct dbbc3_core3h_modex_mon lclm;

    if(0==options||1==options) {
        out_class=0;
        out_recs=0;
        overall_error=0;
    }
    kcom= command->argv[1] != NULL &&
        *command->argv[1] == '?' && command->argv[2] == NULL;

    kcom= kcom || command->argv[0] != NULL &&
        *command->argv[0] == '?' && command->argv[1] == NULL;

    if((!kcom) && command->equal == '=' && force_set) {
        ierr=logmsg_dbbc3(output,command,ip);
        if(ierr!=0) {
            ierr+=-450;
            goto error2;
        }
        return;
    } else if(kcom) {
        memcpy(&lclc,&shm_addr->dbbc3_core3h_modex[iboard-1],sizeof(lclc));
        m5state_init(&lclm.mask3.state);
        m5state_init(&lclm.mask4.state);
    } else {
        int split = 0;

        iclass=ip[0];
        nrecs=ip[1];
        for (i=0;i<nrecs;i++) {
            char *ptr;
            if ((nchars =
                        cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
                ierr = -401;
                goto error;
            }
	    switch (i) {
                case 0: case 1: case4: case 5:
                    break;
                case 2:
                    if(0!=dbbc3_core3h_status_fs(inbuf,&lclc,&lclm)) {
                        ierr=-501;
                        goto error;
                    }
                    break;
                case 6:
                    if(0!=dbbc3_core3h_mode_fs(inbuf,&lclc,&lclm)) {
                        ierr=-502;
                        goto error;
                    }
                    break;
                default:
                    if(!split && NULL != strstr(inbuf,"Split mode")) {
                        if(0!=dbbc3_core3h_2_splitmode(inbuf,&lclc,&lclm)) {
                            ierr=-503;
                            goto error;
                        }
                        split = TRUE;
                    }
                    break;
            }
        }
        if (!split) {
            ierr = -523;
            goto error;
        }
    }
    /* format output buffer */

    strcpy(output,command->name);
    strcat(output,"/");

    count=0;
    while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dbbc3_core3h_modex_enc(output,&count,&lclc,&lclm,iboard);
    }

    if(!kcom) {
        count=0;
        while( count>= 0) {
            if (count > 0) strcat(output,",");
            count++;
            dbbc3_core3h_modex_mon(output,&count,&lclc,&lclm);
        }
    }

    if(strlen(output)>0) output[strlen(output)-1]='\0';

send:
    for (i=0;i<5;i++)
        ip[i]=0;
    if(0==options||4==options) {
      cls_snd(&out_class,output,strlen(output),0,0);
      out_recs++;
    } else
      logit(output,0,NULL);

    if(!kcom && !kmon) {
        ierr=0;
        if(shm_addr->dbbc3_core3h_modex[iboard-1].mask1.mask1 != lclc.mask1.mask1) {
            logitn(NULL,-611,"dr",iboard);
            ierr=-600-iboard;
        }

        if(DBBC3_DDCU==shm_addr->equip.rack_type) {
            if(shm_addr->dbbc3_core3h_modex[iboard-1].mask2.mask2 != lclc.mask2.mask2) {
                logitn(NULL,-612,"dr",iboard);
                ierr=-600-iboard;
            }
            if(shm_addr->dbbc3_core3h_modex[iboard-1].mask1.mask1 != lclm.mask3.mask3) {
                logitn(NULL,-613,"dr",iboard);
                ierr=-600-iboard;
            }
            if(shm_addr->dbbc3_core3h_modex[iboard-1].mask2.mask2 != lclm.mask4.mask4) {
                logitn(NULL,-614,"dr",iboard);
                ierr=-600-iboard;
            }
        }

        if(shm_addr->dbbc3_core3h_modex[iboard-1].decimate.state.known &&
           shm_addr->dbbc3_core3h_modex[iboard-1].decimate.decimate != lclc.decimate.decimate ||
           shm_addr->dbbc3_core3h_modex[iboard-1].samplerate.state.known &&
           shm_addr->dbbc3_core3h_modex[iboard-1].samplerate.decimate != lclc.decimate.decimate) {
            logitn(NULL,-615,"dr",iboard);
            ierr=-600-iboard;
        }

        if(shm_addr->dbbc3_core3h_modex[iboard-1].width.width != lclc.width.width) {
            logitn(NULL,-616,"dr",iboard);
            ierr=-600-iboard;
        }

        if(shm_addr->dbbc3_core3h_modex[iboard-1].channels.channels != lclc.channels.channels) {
            logitn(NULL,-617,"dr",iboard);
            ierr=-600-iboard;
        }

        if( shm_addr->dbbc3_core3h_modex[iboard-1].payload.payload != lclc.payload.payload) {
            logitn(NULL,-618,"dr",iboard);
            ierr=-600-iboard;
        }

        if(DBBC3_DDCU==shm_addr->equip.rack_type && 1!=lclm.splitmode.splitmode) {
            logitn(NULL,-619,"dr",iboard);
            ierr=-600-iboard;
        } else if(DBBC3_DDCV==shm_addr->equip.rack_type && 0!=lclm.splitmode.splitmode) {
            logitn(NULL,-620,"dr",iboard);
            ierr=-600-iboard;
        }

        if(DBBC3_DDCU==shm_addr->equip.rack_type && 4!=lclm.vsi_input.vsi_input) {
            logitn(NULL,-621,"dr",iboard);
            ierr=-600-iboard;
        } else if(DBBC3_DDCV==shm_addr->equip.rack_type && 1!=lclm.vsi_input.vsi_input) {
            logitn(NULL,-622,"dr",iboard);
            ierr=-600-iboard;
        }

        if(shm_addr->dbbc3_core3h_modex[iboard-1].start.start != lclc.start.start) {
            if(lclc.start.start == 0)
                logitn(NULL,-623,"dr",iboard);
            else
                logitn(NULL,-624,"dr",iboard);
            ierr=-600-iboard;
        }

        if((int) (shm_addr->dbbc3_clockr*1.e6+0.5) != lclm.clockrate.clockrate) {
            logitn(NULL,-625,"dr",iboard);
            ierr=-600-iboard;
        }
        if(1 == lclc.start.start && 1 != lclm.format.format) {
            logitn(NULL,-626,"dr",iboard);
            ierr=-600-iboard;
        }
        if(1 != lclm.sync.sync) {
            logitn(NULL,-627,"dr",iboard);
            ierr=-600-iboard;
        }

        if(4==options && (ierr!=0||overall_error)) {
            ierr=-600;
        }
        if(ierr!=0) {
            if (1==options||2==options) {
              ierr=0;
              overall_error=1;
            }
            goto error2;
        }
    }

    ip[0]=out_class;
    ip[1]=out_recs;
    return;

error:
    if(i!=nrecs-1)
        cls_clr(iclass);
error2:
    ip[0]=out_class;
    ip[1]=out_recs;
    ip[2]=ierr;
    ip[4]=0;
    memcpy(ip+3,"dr",2);
    return;
}
