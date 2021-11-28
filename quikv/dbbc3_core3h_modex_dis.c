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

void dbbc3_core3h_modex_dis(command,itask,ip,force_set)
    struct cmd_ds *command;
    int itask;
    int ip[5];
    int force_set;
{
    int ierr, count, i;
    char output[MAX_OUT];
    int rtn1;    /* argument for cls_rcv - unused */
    int rtn2;    /* argument for cls_rcv - unused */
    int msgflg=0;  /* argument for cls_rcv - unused */
    int save=0;    /* argument for cls_rcv - unused */
    int nchars;
    int out_class=0;
    int out_recs=0;
    char inbuf[BUFSIZE];
    int kcom;
    int iclass, nrecs;
    struct dbbc3_core3h_modex_cmd lclc;
    struct dbbc3_core3h_modex_mon lclm;

    kcom= command->argv[0] != NULL &&
        *command->argv[0] == '?' && command->argv[1] == NULL;

    if((!kcom) && command->equal == '=' && force_set) {
        ierr=logmsg_dbbc3(output,command,ip);
        if(ierr!=0) {
            ierr+=-450;
            goto error2;
        }
        return;
    } else if(kcom) {
        memcpy(&lclc,&shm_addr->dbbc3_core3h_modex[itask-30],sizeof(lclc));
    } else {
        int mask = 0;
        int rate = 0;
        int output = 0;
        int split = 0;
        int input = 0;
        int width = 0;
        int channels = 0;
        int payload = 0;

        iclass=ip[0];
        nrecs=ip[1];
        for (i=0;i<nrecs;i++) {
            char *ptr;
            if ((nchars =
                        cls_rcv(iclass,inbuf,BUFSIZE,&rtn1,&rtn2,msgflg,save)) <= 0) {
                ierr = -401;
                goto error;
            }
            if(!mask && NULL != strstr(inbuf,"VSI input bitmask")) {
                if(0!=dbbc3_core3h_2_vsi_bitmask(inbuf,&lclc,&lclm)) {
                    ierr=-501;
                    goto error;
                }
                mask=TRUE;
            } else if(!rate && NULL != strstr(inbuf,"Input sample rate")) {
                if(0!=dbbc3_core3h_2_vsi_samplerate(inbuf,&lclc,&lclm)) {
                    ierr=-502;
                    goto error;
                }
                rate = TRUE;
            } else if(!output && NULL != strstr(inbuf," Output      ")) {
                if(0!=dbbc3_core3h_2_output(inbuf,&lclc,&lclm)) {
                    ierr=-503;
                    goto error;
                }
                output = TRUE;
            } else if(!split && NULL != strstr(inbuf,"Split mode")) {
                if(0!=dbbc3_core3h_2_splitmode(inbuf,&lclc,&lclm)) {
                    ierr=-504;
                    goto error;
                }
                split = TRUE;
            } else if(!input && NULL != strstr(inbuf,"Selected input")) {
                if(0!=dbbc3_core3h_2_vsi_input(inbuf,&lclc,&lclm)) {
                    ierr=-505;
                    goto error;
                }
                input = TRUE;
            } else if(!width && NULL != strstr(inbuf,"channel width (in bits)")) {
                if(0!=dbbc3_core3h_2_width(inbuf,&lclc,&lclm)) {
                    ierr=-506;
                    goto error;
                }
                width = TRUE;
            } else if(!channels && NULL != strstr(inbuf,"number of channels per frame")) {
                if(0!=dbbc3_core3h_2_channels(inbuf,&lclc,&lclm)) {
                    ierr=-507;
                    goto error;
                }
                channels = TRUE;
            } else if(!payload && NULL != strstr(inbuf,"payload size (in bytes)")) {
                if(0!=dbbc3_core3h_2_payload(inbuf,&lclc,&lclm)) {
                    ierr=-508;
                    goto error;
                }
                payload = TRUE;
            }
        }
        if (!mask) {
            ierr = -521;
            goto error;
        } else if (!rate) {
            ierr = -522;
            goto error;
        } else if (!output) {
            ierr = -523;
            goto error;
        } else if (!split) {
            ierr = -524;
            goto error;
        } else if (!input) {
            ierr = -525;
            goto error;
        } else if (!width) {
            ierr = -526;
            goto error;
        } else if (!channels) {
            ierr = -527;
            goto error;
        } else if (!payload) {
            ierr = -528;
            goto error;
        }
    }
    /* format output buffer */

    strcpy(output,command->name);
    strcat(output,"/");

    if(0 == lclc.start.start) {
        strcat(output,"stopped");
        goto send;
    }
    count=0;
    while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dbbc3_core3h_modex_enc(output,&count,&lclc,itask-30);
    }

    /* this a rare command that has a monitor '?' value from shared memory */

    if(kcom) {
        m5state_init(&lclm.clockrate.state);
        lclm.clockrate.clockrate=shm_addr->dbbc3_clockr*1.0e6+0.5;
        lclm.clockrate.state.known=1;

        m5state_init(&lclm.splitmode.state);
        if(DBBC3_DDCU==shm_addr->equip.rack_type)
            lclm.splitmode.splitmode=1;
        else
            lclm.splitmode.splitmode=0;
        lclm.splitmode.state.known=1;

        m5state_init(&lclm.vsi_input.state);
        if(DBBC3_DDCU==shm_addr->equip.rack_type)
            lclm.vsi_input.vsi_input=4;
        else
            lclm.vsi_input.vsi_input=1;
        lclm.vsi_input.state.known=1;
    }
    count=0;
    while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dbbc3_core3h_modex_mon(output,&count,&lclm);
    }

    if(strlen(output)>0) output[strlen(output)-1]='\0';

send:
    for (i=0;i<5;i++)
        ip[i]=0;
    cls_snd(&ip[0],output,strlen(output),0,0);
    ip[1]=1;
    if(!kcom) {
        ierr=0;
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                shm_addr->dbbc3_core3h_modex[itask-30].mask1.mask1 != lclc.mask1.mask1) {
            logitn(NULL,-611,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(DBBC3_DDCU==shm_addr->equip.rack_type) {
            if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                    shm_addr->dbbc3_core3h_modex[itask-30].mask2.mask2 != lclc.mask2.mask2) {
                logitn(NULL,-612,"dr",itask-29);
                ierr=-600-(itask-29);
            }
            if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                    shm_addr->dbbc3_core3h_modex[itask-30].mask1.mask1 != lclm.mask3.mask3) {
                logitn(NULL,-613,"dr",itask-29);
                ierr=-600-(itask-29);
            }
            if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                    shm_addr->dbbc3_core3h_modex[itask-30].mask2.mask2 != lclm.mask4.mask4) {
                logitn(NULL,-614,"dr",itask-29);
                ierr=-600-(itask-29);
            }
        }
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                shm_addr->dbbc3_core3h_modex[itask-30].decimate.decimate != lclc.decimate.decimate) {
            logitn(NULL,-615,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                shm_addr->dbbc3_core3h_modex[itask-30].width.width != lclc.width.width) {
            logitn(NULL,-616,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                shm_addr->dbbc3_core3h_modex[itask-30].channels.channels != lclc.channels.channels) {
            logitn(NULL,-617,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                shm_addr->dbbc3_core3h_modex[itask-30].payload.payload != lclc.payload.payload) {
            logitn(NULL,-618,"dr",itask-29);
            ierr=-600-(itask-29);
        }

        if(shm_addr->dbbc3_core3h_modex[itask-30].set)
            if(DBBC3_DDCU==shm_addr->equip.rack_type && 1!=lclm.splitmode.splitmode) {
                logitn(NULL,-619,"dr",itask-29);
                ierr=-600-(itask-29);
            } else if(DBBC3_DDCV==shm_addr->equip.rack_type && 0!=lclm.splitmode.splitmode) {
                logitn(NULL,-620,"dr",itask-29);
                ierr=-600-(itask-29);
            }

        if(shm_addr->dbbc3_core3h_modex[itask-30].set)
            if(DBBC3_DDCU==shm_addr->equip.rack_type && 4!=lclm.vsi_input.vsi_input) {
                logitn(NULL,-621,"dr",itask-29);
                ierr=-600-(itask-29);
            } else if(DBBC3_DDCV==shm_addr->equip.rack_type && 1!=lclm.vsi_input.vsi_input) {
                logitn(NULL,-622,"dr",itask-29);
                ierr=-600-(itask-29);
            }

        if(shm_addr->dbbc3_core3h_modex[itask-30].start.state.known &&
                shm_addr->dbbc3_core3h_modex[itask-30].start.start != lclc.start.start) {
            if(lclc.start.start == 0)
                logitn(NULL,-623,"dr",itask-29);
            else
                logitn(NULL,-624,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(shm_addr->dbbc3_core3h_modex[itask-30].set &&
                (int) (shm_addr->dbbc3_clockr*1.e6+0.5) != lclm.clockrate.clockrate) {
            logitn(NULL,-625,"dr",itask-29);
            ierr=-600-(itask-29);
        }
        if(ierr!=0) {
            goto error2;
        }
    }
    return;

error:
    if(i!=nrecs-1)
        cls_clr(iclass);
    ip[0]=0;
    ip[1]=0;
error2:
    ip[2]=ierr;
    ip[4]=0;
    memcpy(ip+3,"dr",2);
    return;
}
