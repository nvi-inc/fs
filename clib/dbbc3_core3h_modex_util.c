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
/* core3h_modex commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>
#include <ctype.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *force_key[ ]=         { "$", "force" };
static char *disk_key[ ]=         { "disk_record_ok" };
static char *split_key[ ]=         { "off", "on" };
static char *input_key[ ]=         { "tvg","vsi1","vsi2","vsi1-2","vsi1-2-3-4","gps" };
static char *format_key[ ]=         { "stopped","vdif","mk5b","raw" };
static char *sync_key[ ]=         { "unsynced","synced" };

#define NFORCE_KEY sizeof(force_key)/sizeof( char *)
#define NDISK_KEY sizeof(disk_key)/sizeof( char *)
#define NSPLIT_KEY sizeof(split_key)/sizeof( char *)
#define NINPUT_KEY sizeof(input_key)/sizeof( char *)
#define NFORMAT_KEY sizeof(format_key)/sizeof( char *)
#define NSYNC_KEY sizeof(sync_key)/sizeof( char *)

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
        case 2:
            ierr=arg_uns(ptr,&lcl->mask2.mask2 ,0x0,TRUE);
            m5state_init(&lcl->mask2.state);
            if(ierr==0) {
                lcl->mask2.state.known=1;
            } else {
                lcl->mask2.state.error=1;
            }
            break;
        case 3:
            ierr=arg_uns(ptr,&lcl->mask1.mask1 ,0xffffffff,TRUE);
            m5state_init(&lcl->mask1.state);
            if(ierr==0) {
                lcl->mask1.state.known=1;
            } else {
                lcl->mask1.state.error=1;
            }
            break;
        case 4:
            lcl->decimate.decimate=0;
            ierr=arg_int(ptr,&lcl->decimate.decimate ,1,FALSE);
            m5state_init(&lcl->decimate.state);
            if(ierr == 0) {
                if(lcl->decimate.decimate<1 ||
                        lcl->decimate.decimate>255)
                    ierr=-200;
                else if(DBBC3_DDCV == shm_addr->equip.rack_type &&
                        2!= lcl->decimate.decimate &&
                        1!= lcl->decimate.decimate)
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
        case 5:
            if(DBBC3_DDCU == shm_addr->equip.rack_type)
                crate=256;
            else
                crate=128;
            sample=lcl->samplerate.samplerate;
            m5state_init(&lcl->samplerate.state);
            ierr=arg_float(ptr,&sample,0.0,FALSE);
            lcl->samplerate.samplerate=sample;
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
                    lcl->samplerate.samplerate=sample;
                    lcl->samplerate.decimate=(crate/sample)+0.5;
                    if( fabs(lcl->samplerate.decimate*sample-crate)/ crate
                            > 0.001)
                        ierr=-210;
                    else if( lcl->samplerate.decimate <1 ||
                            lcl->samplerate.decimate >255)
                        ierr=-210;
                    else if(DBBC3_DDCV == shm_addr->equip.rack_type &&
                            2!= lcl->samplerate.decimate &&
                            1!= lcl->samplerate.decimate)
                        ierr=-230;
                }
            }
            if(ierr==0) {
                lcl->samplerate.state.known=1;
            } else {
                lcl->samplerate.state.error=1;
            }
            break;
        case 6:
            ierr=arg_key(ptr,force_key,NFORCE_KEY,&lcl->force.force,0,TRUE);
            m5state_init(&lcl->force.state);
            if(ierr==0) {
                lcl->force.state.known=1;
            } else {
                lcl->force.state.error=1;
            }
            break;
        case 7:
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

void dbbc3_core3h_modex_enc(output,count,lclc,lclm,iboard)
    char *output;
    int *count;
    struct dbbc3_core3h_modex_cmd *lclc;
    struct dbbc3_core3h_modex_mon *lclm;
    int iboard;
{

    int ivalue;
    int crate;

    output=output+strlen(output);

    switch (*count) {
        case 1:
            snprintf(output,2,"%d",iboard);
            break;
        case 2:
            if((lclc->mask2.state.known && lclc->mask2.mask2 ||
                lclm->mask4.state.known && lclm->mask4.mask4) &&
                lclm->none1.state.known && lclm->none1.none1)
                    strcpy(output,"{");
            if(lclc->mask2.state.known && lclc->mask2.mask2) {
                output=output+strlen(output);
                strcpy(output,"0x");
                m5sprintf(output+2,"%x",&lclc->mask2.mask2,&lclc->mask2.state);
            }
            if(DBBC3_DDCU == shm_addr->equip.rack_type &&
              lclm->mask4.state.known && lclc->mask2.state.known &&
              lclm->mask4.mask4 != lclc->mask2.mask2) {
                output=output+strlen(output);
                strcpy(output,"[0x");
                m5sprintf(output+3,"%x",&lclm->mask4.mask4,&lclm->mask4.state);
                output=output+strlen(output);
                strcpy(output,"]");
            }
            if((lclc->mask2.state.known && lclc->mask2.mask2 ||
                lclm->mask4.state.known && lclm->mask4.mask4) &&
                lclm->none1.state.known && lclm->none1.none1) {
                    output=output+strlen(output);
                    strcpy(output,"}");
            }
            break;
        case 3:
            if((lclc->mask1.state.known && lclc->mask1.mask1 ||
                lclm->mask3.state.known && lclm->mask3.mask3) &&
                lclm->none0.state.known && lclm->none0.none0)
                    strcpy(output,"{");
            if(lclc->mask1.state.known) {
                output=output+strlen(output);
                strcpy(output,"0x");
                m5sprintf(output+2,"%x",&lclc->mask1.mask1,&lclc->mask1.state);
            }
            if(DBBC3_DDCU == shm_addr->equip.rack_type &&
              lclm->mask3.state.known && lclm->mask3.mask3 != lclc->mask1.mask1) {
                output=output+strlen(output);
                strcpy(output,"[0x");
                m5sprintf(output+3,"%x",&lclm->mask3.mask3,&lclm->mask3.state);
                output=output+strlen(output);
                strcpy(output,"]");
            }
            if((lclc->mask1.state.known && lclc->mask1.mask1 ||
                lclm->mask3.state.known && lclm->mask3.mask3) &&
                lclm->none0.state.known && lclm->none0.none0) {
                    output=output+strlen(output);
                    strcpy(output,"}");
            }
            break;
        case 4:
            m5sprintf(output,"%d",&lclc->decimate.decimate,&lclc->decimate.state);
            break;
        case 5:
            if(DBBC3_DDCU == shm_addr->equip.rack_type)
                crate=256;
            else
                crate=128;
            if(lclc->samplerate.state.known) {
                sprintf(output,"%.3f", lclc->samplerate.samplerate+0.0001 );
                while(output[strlen(output)-1]=='0')
                  output[strlen(output)-1]=0;
                m5state_encode(output,&lclc->samplerate.state);
            } else if(lclc->decimate.state.known && lclc->decimate.decimate!=0) {
                sprintf(output,"(%.3f", (float) crate/ lclc->decimate.decimate+0.0001 );
                while(output[strlen(output)-1]=='0')
                  output[strlen(output)-1]=0;
                strcat(output,")");
                m5state_encode(output,&lclc->decimate.state);
            }
            break;
        default:
            *count=-1;
    }

    if(*count>0) *count++;
    return;
}
void dbbc3_core3h_modex_mon(output,count,lclc,lclm)
    char *output;
    int *count;
    struct dbbc3_core3h_modex_cmd *lclc;
    struct dbbc3_core3h_modex_mon *lclm;
{

    int ivalue;

    output=output+strlen(output);

    switch (*count) {
        case 1:
            m5sprintf(output,"%d",&lclm->clockrate.clockrate,
                    &lclm->clockrate.state);
            break;
        case 2:
            ivalue = lclm->splitmode.splitmode;
            if (ivalue >=0 && ivalue <NSPLIT_KEY)
                strcat(output,split_key[ivalue]);
            else
                strcat(output,BAD_VALUE);
            break;
        case 3:
            ivalue = lclm->vsi_input.vsi_input;
            if (ivalue >=0 && ivalue <NINPUT_KEY)
                strcat(output,input_key[ivalue]);
            else
                strcat(output,BAD_VALUE);
            break;
        case 4:
            m5sprintf(output,"%d",&lclc->channels.channels,
                    &lclc->channels.state);
            break;
        case 5:
            m5sprintf(output,"%d",&lclc->width.width,
                    &lclc->width.state);
            break;
        case 6:
            m5sprintf(output,"%d",&lclc->payload.payload,
                    &lclc->payload.state);
            break;
        case 7:
            ivalue = lclm->format.format;
            if(0==lclc->start.start)
              ivalue = 0;
            if (ivalue >=0 && ivalue <NFORMAT_KEY)
                strcat(output,format_key[ivalue]);
            else
                strcat(output,BAD_VALUE);
            break;
        case 8:
            if(lclm->sync.state.known) {
                ivalue = lclm->sync.sync;
                if (ivalue >=0 && ivalue <NSYNC_KEY)
                    strcat(output,sync_key[ivalue]);
                else
                    strcat(output,BAD_VALUE);
            }
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
        if(lclc->mask1.state.known && lclc->mask1.mask1 &&
                lclc->mask2.state.known && lclc->mask2.mask2)
            sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x 0x%x 0x%x 0x%x",board,
                    lclc->mask2.mask2,
                    lclc->mask1.mask1,
                    lclc->mask2.mask2,
                    lclc->mask1.mask1);
        else if(lclc->mask1.state.known && lclc->mask1.mask1)
            sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x 0x%x 0x%x 0x%x",board,
                    lclc->mask1.mask1,
                    lclc->mask1.mask1,
                    lclc->mask1.mask1,
                    lclc->mask1.mask1);
        else
            sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x 0x%x 0x%x 0x%x",board,
                    lclc->mask2.mask2,
                    lclc->mask2.mask2,
                    lclc->mask2.mask2,
                    lclc->mask2.mask2);
    else
        sprintf(ptr,"core3h=%1.1s,vsi_bitmask 0x%x",board,lclc->mask1.mask1);

}
void vsi_samplerate_2_dbbc3_core3h(ptr,lclc,board)
    char *ptr;
    struct dbbc3_core3h_modex_cmd *lclc;
    char board[ ];
{
    int decimate;

    if(lclc->decimate.state.known)
      decimate=lclc->decimate.decimate;
    else
      decimate=lclc->samplerate.decimate;

    sprintf(ptr,"core3h=%1.1s,vsi_samplerate %d %d",board,
            (int) (shm_addr->dbbc3_clockr*1.0e6+0.5),decimate);

}

int dbbc3_vdif_frame_params(lclc)
    struct dbbc3_core3h_modex_cmd *lclc;
{
    int payload;
    unsigned bitmask2=lclc->mask2.mask2;
    unsigned bitmask1=lclc->mask1.mask1;
    int bpc = 0 ;
    int channels = 0;
    int channels1 = 0;
    int channels2 = 0;
    int i;
    int bits1[ ] ={0 , 0, 0, 0};
    int bits2[ ] ={0 , 0, 0, 0};

    for(i=0;i<16;i++) {
        bits1[bitmask1 >> i*2 & 0x3U]++;
        bits2[bitmask2 >> i*2 & 0x3U]++;
    }

    if((bits1[1] || bits1[2] || bits2[1] || bits2[2]) &&
       (bits1[3] || bits2[3]))
       return -308;
    else if(bits1[3]||bits2[3])
        bpc = 2;
    else
        bpc = 1;

    channels1=bits1[1]+bits1[2]+bits1[3];
    channels2=bits2[1]+bits2[2]+bits2[3];

    if(bitmask1 && bitmask2 &&
       channels1 != channels2)
       return -309;
    else if(channels1)
       channels=channels1;
    else
       channels=channels2;

    switch (channels) { /* trap zero in caller */
        case 0: case 1: case 2: case 4: case 8: case 16:
            break;
        default:
            return -310;
            break;
    }

    m5state_init(&lclc->width.state);
    lclc->width.width=bpc;
    lclc->width.state.known=1;

    m5state_init(&lclc->channels.state);
    lclc->channels.channels=channels;
    lclc->channels.state.known=1;

    m5state_init(&lclc->payload.state);
    lclc->payload.payload=8000;
    lclc->payload.state.known=1;

    return 0;
}

void vdif_frame_2_dbbc3_core3h(ptr,lclc,board)
    char *ptr;
    struct dbbc3_core3h_modex_cmd *lclc;
    char board[ ];
{
    sprintf(ptr,"core3h=%1.1s,vdif_frame %d %d %d ct=off", board,
            lclc->width.width,lclc->channels.channels,lclc->payload.payload);

}

int dbbc3_core3h_2_splitmode(ptr,lclc,lclm) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    int i;
    char string[]=  "Split mode:";

    m5state_init(&lclm->splitmode.state);

    ptr=strstr(ptr,string);
    if(ptr == NULL) {
        return -1;
    }

    ptr=strtok(ptr+strlen(string)," \n\r");
    if(ptr == NULL) {
        return -1;
    }

    for(i=0;i<NSPLIT_KEY;i++)
        if(0==strcmp(ptr,split_key[i])) {
            lclm->splitmode.splitmode=i;
            lclm->splitmode.state.known=1;
            return 0;
        }

    return -1;
}

int dbbc3_core3h_2_destination0(ptr,lclc,lclm) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    int i;
    char string[]=  "Output 0 destination:";

    m5state_init(&lclm->none0.state);

    ptr=strstr(ptr,string);
    if(ptr == NULL) {
        return -1;
    }

    ptr=strtok(ptr+strlen(string)," \n\r");
    if(ptr == NULL) {
        return -1;
    }

    lclm->none0.none0= 0==strcmp(ptr,"none");
    lclm->none0.state.known=1;
    return 0;
}

int dbbc3_core3h_2_destination1(ptr,lclc,lclm) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    int i;
    char string[]=  "Output 1 destination:";

    m5state_init(&lclm->none1.state);

    ptr=strstr(ptr,string);
    if(ptr == NULL) {
        return -1;
    }

    ptr=strtok(ptr+strlen(string)," \n\r");
    if(ptr == NULL) {
        return -1;
    }

    lclm->none1.none1= 0==strcmp(ptr,"none");
    lclm->none1.state.known=1;
    return 0;
}
int dbbc3_core3h_status_fs(ptr,lclc,lclm) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    int i;

    m5state_init(&lclm->sync.state);
    m5state_init(&lclm->format.state);
    m5state_init(&lclc->start.state);

    ptr++;  /* skip leading \r */

    ptr=strtok(ptr,",\n");
    if(ptr == NULL) {
        return -1;
    }
    for(i=0;i<NSYNC_KEY;i++)
       if(0==strcmp(ptr,sync_key[i])) {
          lclm->sync.sync=i;
          lclm->sync.state.known=1;
          break;
       }

    ptr=strtok(NULL,",\n");
    if(ptr == NULL) {
        return -1;
    }
    for(i=0;i<NFORMAT_KEY;i++)
       if(0==strcmp(ptr,format_key[i])) {
          lclm->format.format=i;
          lclm->format.state.known=1;
          break;
       }

    ptr=strtok(NULL,",\n");
    if(ptr == NULL) {
        return -1;
    }
    if(0==strcmp(ptr,"stopped")) {
       lclc->start.start=0;
       lclc->start.state.known=0;
    } else if(0==strcmp(ptr,"started")) {
       lclc->start.start=1;
       lclc->start.state.known=0;
    }

    return 0;
}
int dbbc3_core3h_mode_fs(ptr,lclc,lclm) /* return values:
                                     *  0 == no error
                                     *  0 != error
                                     */
    char *ptr;           /* input buffer to be parsed */

    struct dbbc3_core3h_modex_cmd *lclc;  /* result structure with parameters */
    struct dbbc3_core3h_modex_mon *lclm;  /* result structure with parameters */
{
    char *ptr2;
    int i;
    int f1,f2,f3,f4;

    m5state_init(&lclm->vsi_input.state);
    m5state_init(&lclm->clockrate.state);
    m5state_init(&lclc->decimate.state);
    m5state_init(&lclc->samplerate.state);
    m5state_init(&lclc->mask1.state);
    m5state_init(&lclc->mask2.state);
    m5state_init(&lclm->mask3.state);
    m5state_init(&lclm->mask4.state);
    m5state_init(&lclc->width.state);
    m5state_init(&lclc->channels.state);
    m5state_init(&lclc->payload.state);

    ptr++;  /* skip leading \r */

    ptr=strtok(ptr,",\n");
    if(ptr == NULL) {
        return -1;
    }
    for(i=0;i<NINPUT_KEY;i++)
       if(0==strcmp(ptr,input_key[i])) {
          lclm->vsi_input.vsi_input=i;
          lclm->vsi_input.state.known=1;
          break;
       }

    ptr=strtok(NULL,",\n");
    if(ptr == NULL) {
        return -1;
    }
    if(m5sscanf(ptr,"%d",
                &lclm->clockrate.clockrate,&lclm->clockrate.state)) {
        return -1;
    }

    ptr2=strstr(ptr,"/");

    if(NULL==ptr2) {
        lclc->decimate.decimate=1;
        lclc->decimate.state.known=1;
    } else {
        if(m5sscanf(ptr2+1,"%d",
            &lclc->decimate.decimate,&lclc->decimate.state)) {
            return -1;
        }
    }

    ptr=strtok(NULL,",\n");
    if(ptr == NULL) {
        return -1;
    }

    lclc->mask1.mask1=0;
    lclc->mask1.state.known=1;
    lclc->mask2.mask2=0;
    lclc->mask2.state.known=1;
    lclm->mask3.mask3=0;
    lclm->mask3.state.known=1;
    lclm->mask4.mask4=0;
    lclm->mask4.state.known=1;
    int count=sscanf(ptr,"%x %x %x %x",&f1,&f2,&f3,&f4);
    if(0<count) {
        lclc->mask1.mask1=f1;
    }
    if(1<count) {
        memcpy(&lclc->mask2,&lclc->mask1,sizeof(lclc->mask2));
        lclc->mask1.mask1=f2;
    }
    if(2<count) {
        memcpy(&lclm->mask3,&lclc->mask2,sizeof(lclm->mask3));
        memcpy(&lclc->mask2,&lclc->mask1,sizeof(lclc->mask2));
        lclc->mask1.mask1=f3;
    }
    if(3<count) {
        memcpy(&lclm->mask4,&lclm->mask3,sizeof(lclm->mask4));
        memcpy(&lclm->mask3,&lclc->mask2,sizeof(lclm->mask3));
        memcpy(&lclc->mask2,&lclc->mask1,sizeof(lclc->mask2));
        lclc->mask1.mask1=f4;
    }

    ptr=strtok(NULL,",\n");  /* skip format, already have that */
    if(ptr == NULL) {
        return -1;
    }

    ptr=strtok(NULL,",\n");
    if(ptr == NULL) {
        return -1;
    }
    if(m5sscanf(ptr,"%d",&lclc->width.width,&lclc->width.state)) {
        return -1;
    }

    ptr=strtok(NULL,",\n");

    if(ptr == NULL) {
        return -1;
    }
    if(m5sscanf(ptr,"%d",&lclc->channels.channels,&lclc->channels.state)) {
        return -1;
    }

    ptr=strtok(NULL,",\n");

    if(ptr == NULL) {
        return -1;
    }
    if(m5sscanf(ptr,"%d",&lclc->payload.payload,&lclc->payload.state)) {
        return -1;
    }
    lclc->payload.payload*=8; /* this field is 1/8 of payload */

    return 0;
}
void dbbc3_core3h_modex_log_buf(char *outbuf, char *inbuf, size_t size_out,
     char* who)
{
  int in=0;
  int out=0;
  int len=strlen(inbuf);
  int j;

  if(size_out>=11) {
    strcpy(outbuf,"response: ");
    out+=10;
  } else {
    logite("no room to show response",-500,who);
    return;
  }

  for(j=0;j<len;j++) {
    if('\r'==inbuf[j]) {
       if(out>=size_out-2) {
         break;
       }
       strcpy(outbuf+out,"\\r");
       out+=2;
    } else if(!isprint(inbuf[j])) {
       if(out>=size_out-4) {
         break;
       }
       snprintf(outbuf+out,5,"\\x%02x",inbuf[j]);
       out+=4;
    } else {
      if(out>=size_out-1) {
        break;
      }
      outbuf[out++]=inbuf[j];
    }
  }
  outbuf[out]=0;
  logite(outbuf,-500,who);
}
