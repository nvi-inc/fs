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
/* core3h_modex commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *disk_key[ ]=         { "disk_record_ok" };

#define NDISK_KEY sizeof(disk_key)/sizeof( char *)

char *m5trim();

int dbbc3_core3h_modex_dec(lcl,count,ptr)
    struct dbbc3_core3h_modex_cmd *lcl;
    int *count;
    char *ptr;
{
    int ierr, i, arg_key();
    float sample;
    int crate;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
        case 1:
            ierr=arg_uns(ptr,&lcl->mask2.mask2 ,0x0,TRUE);
            m5state_init(&lcl->mask2.state);
            if(ierr==0) {
                lcl->mask2.state.known=1;
            } else {
                lcl->mask2.state.error=1;
            }
            break;
        case 2:
            ierr=arg_uns(ptr,&lcl->mask1.mask1 ,0xffffffff,TRUE);
            m5state_init(&lcl->mask1.state);
            if(ierr==0) {
                lcl->mask1.state.known=1;
            } else {
                lcl->mask1.state.error=1;
            }
            break;
        case 3:
            lcl->decimate.decimate=0;
            ierr=arg_int(ptr,&lcl->decimate.decimate ,1,FALSE);
            m5state_init(&lcl->decimate.state);
            if(ierr == 0) {
                if(lcl->decimate.decimate<1 ||
                        lcl->decimate.decimate>255)
                    ierr=-200;
                else if(DBBC3_DDCV == shm_addr->equip.rack_type &&
                        2!= lcl->decimate.decimate)
                    ierr=-210;
            }
            if(ierr==0) {
                lcl->decimate.state.known=1;
            } else if(ierr!=-100) {
                lcl->decimate.state.error=1;
            }
            if(ierr==-100)
                ierr=0;
            break;
        case 4:
            if(DBBC3_DDCU == shm_addr->equip.rack_type)
                crate=256;
            else
                crate=128;
            ierr=arg_float(ptr,&sample,0.0,FALSE);
            if(lcl->decimate.state.known != 0) {
                if(ierr != -100)
                    ierr=-220;
                else if(ierr == -100) {
                    ierr = 0;
                    break;
                }
            } else if(lcl->decimate.state.known == 0 && ierr == -100) {
                if(DBBC3_DDCU == shm_addr->equip.rack_type)
                    sample=crate;
                else
                    sample=crate/2;
                ierr=0;
            }
            if(ierr == 0 ) {
                if(sample <= 0.499) {
                    ierr=-200;
                } else {
                    lcl->decimate.decimate=(crate/sample)+0.5;
                    if( fabs(lcl->decimate.decimate*sample-crate)/ crate
                            > 0.001)
                        ierr=-210;
                    else if( lcl->decimate.decimate <1 ||
                            lcl->decimate.decimate >255)
                        ierr=-210;
                    else if(DBBC3_DDCV == shm_addr->equip.rack_type &&
                            2!= lcl->decimate.decimate)
                        ierr=-230;
                }
            }
            if(ierr==0) {
                lcl->decimate.state.known=1;
            } else {
                lcl->decimate.state.error=1;
            }
            break;
        case 5:
            ierr=arg_key(ptr,disk_key,NDISK_KEY,&lcl->disk.disk,-1,TRUE);
            m5state_init(&lcl->disk.state);
            if(ierr==0) {
                lcl->disk.state.known=1;
            } else {
                lcl->disk.state.error=1;
            }
            break;
        default:
            *count=-1;
    }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void dbbc3_core3h_modex_enc(output,count,lclc,board)
    char *output;
    int *count;
    struct dbbc3_core3h_modex_cmd *lclc;
    int board;
{

    int ivalue;
    int crate;

    output=output+strlen(output);

    switch (*count) {
        case 1:
            if(lclc->mask2.state.known && lclc->mask2.mask2) {
                strcpy(output,"0x");
                m5sprintf(output+2,"%x",&lclc->mask2.mask2,&lclc->mask2.state);
            }
            break;
        case 2:
            strcpy(output,"0x");
            m5sprintf(output+2,"%x",&lclc->mask1.mask1,&lclc->mask1.state);
            break;
        case 3:
            m5sprintf(output,"%d",&lclc->decimate.decimate,&lclc->decimate.state);
            break;
        case 4:  /* commanded value only */
            if(DBBC3_DDCU == shm_addr->equip.rack_type)
                crate=256;
            else
                crate=128;
            if(shm_addr->dbbc3_core3h_modex[board].decimate.state.known &&
                    shm_addr->dbbc3_core3h_modex[board].decimate.decimate!=0) {
                sprintf(output,"(%.3f)", (float) crate/
                        shm_addr->dbbc3_core3h_modex[board].decimate.decimate+0.0001 );
                m5state_encode(output,&lclc->decimate.state);
            }
            break;
        default:
            *count=-1;
    }

    if(*count>0) *count++;
    return;
}
void dbbc3_core3h_modex_mon(output,count,lclm)
    char *output;
    int *count;
    struct dbbc3_core3h_modex_mon *lclm;
{

    int ivalue;

    output=output+strlen(output);

    switch (*count) {
        case 1:
            m5sprintf(output,"%d",&lclm->clockrate.clockrate,
                    &lclm->clockrate.state);
            break;
        default:
            *count=-1;
    }

    if(*count>0) *count++;
    return;
}

void vsi_bitmask_2_dbbc3_core3h(ptr,lclc,board,masks)
    char *ptr;
    struct dbbc3_core3h_modex_cmd *lclc;
    char board[];
    int masks;
{
    if(4<=masks)
        sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x 0x%x 0x%x 0x%x",board,
                lclc->mask2.mask2,
                lclc->mask1.mask1,
                lclc->mask2.mask2,
                lclc->mask1.mask1);
    else
        sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x",board,lclc->mask1.mask1);

}
void vsi_samplerate_2_dbbc3_core3h(ptr,lclc,board)
    char *ptr;
    struct dbbc3_core3h_modex_cmd *lclc;
    char board[ ];
{
// Disabled for now
//    sprintf(ptr,"core3h=%1.1s,vsi_samplerate %d  %d",board,
//            (int) (shm_addr->m5b_crate*1.0e6+0.5),lclc->decimate.decimate);

}
void vdif_frame_2_dbbc3_core3h(ptr,lclc,board)
    char *ptr;
    struct dbbc3_core3h_modex_cmd *lclc;
    char board[ ];
{
    int bits=0;
    unsigned bitmask2=lclc->mask2.mask2;
    unsigned bitmask1=lclc->mask1.mask1;
    int bits_p_chan = 0 ;
    int channels = 0;
    int i;

    for(i=0;i<32;i++) {
        if(bitmask2 & 0x1<<i)
            bits++;
        if(bitmask1 & 0x1<<i)
            bits++;
    }

    if((0xaaaaaaaU & bitmask2 || 0xaaaaaaaU & bitmask1 ) &&
            (0x5555555U & bitmask2 || 0x5555555U & bitmask1 ))
        bits_p_chan = 2 ;
    else if(bitmask1 || bitmask2)
        bits_p_chan = 1 ;

    if(bits_p_chan > 0)
        channels = bits/bits_p_chan;

    sprintf(ptr,"core3h=%1.1s,vdif_frame %d %d 8000", board,
            bits_p_chan,channels);

}

int dbbc3_core3h_2_vsi_bitmask(ptr,lclc) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
{
    char string[]= "VSI input bitmask :";

    m5state_init(&lclc->mask2.state);
    m5state_init(&lclc->mask1.state);

    ptr=strstr(ptr,string);
    if(ptr == NULL) {
        return -1;
    }

    ptr=strtok(ptr+strlen(string)," \n\r");
    if(m5sscanf(ptr,"%x",&lclc->mask1.mask1,&lclc->mask1.state)) {
        return -1;
    }
    ptr=strtok(NULL," \n\r");
    if(ptr!=NULL && strncmp(ptr,"0x",2)==0) {
        memcpy(&lclc->mask2,&lclc->mask1,sizeof(lclc->mask2));
        if(m5sscanf(ptr,"%x",&lclc->mask1.mask1,&lclc->mask1.state)) {
            return -1;
        }
    }

    return 0;
}
int dbbc3_core3h_2_vsi_samplerate(ptr,lclc,lclm) /* return values:
                                             *  0 == no error
                                             *  0 != error
                                             */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    char string[]= "VSI sample rate :";
    char string2[]= "Hz /";

    m5state_init(&lclc->decimate.state);
    m5state_init(&lclm->clockrate.state);

    ptr=strstr(ptr,string);
    if(ptr == NULL) {
        return -1;
    }

    if(m5sscanf(ptr+sizeof(string),"%d",
                &lclm->clockrate.clockrate,&lclm->clockrate.state)) {
        return -1;
    }
    ptr=strstr(ptr+sizeof(string),string2);
    if(ptr == NULL)
        return 0;

    if(m5sscanf(ptr+sizeof(string2),"%d",
                &lclc->decimate.decimate,&lclc->decimate.state)) {
        return -1;
    }

    return 0;
}
int dbbc3_core3h_2_output(ptr,lclc) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
{
    char string1[]= "stopped";
    char string2[]= "started";


    if(strstr(ptr,string1))
        lclc->set=0;
    else if (ptr,string2)
        lclc->set=1;
    else
        return -1;

    return 0;
}
