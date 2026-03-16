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
/* dbbc3 sub_lo buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *sb_key[ ]={"all","usb","lsb"};
static char *star_key[ ]={"*"};

#define SB_KEY  sizeof(sb_key)/sizeof( char *)
#define STAR_KEY sizeof(star_key)/sizeof( char *)

int dbbc3_sub_lo_dec(lcl,count,ptr,itask)
struct dbbc3_sub_lo_table *lcl;
int *count;
char *ptr;
{
    int ierr=0;
    int ind, arg_key();
    int dum=-1;
    double ddefault, ddum;
 
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 2:
        ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
        if(ierr == 0 && dum == -1) {
           ierr=-110;
           break;
        }
        ierr=arg_dble(ptr,&lcl->freq,0.0,FALSE);
        if(ierr==0 && lcl->freq <= 0.0)
            ierr=-200;
        break;
      case 3:
        ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
        if(ierr == 0 && dum == -1) {
           ierr=-210;
           break;
        }
	ierr=arg_key(ptr,sb_key,SB_KEY,&lcl->sb,0,FALSE);
        if(0==ierr&& 0==lcl->sb)
            ierr=-200;
        break;
      case 4:
        ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
        if(ierr == 0 && dum == -1) {
           ierr=-110;
           break;
        }
        ddum=1.0;
        ierr=arg_dble(ptr,&ddum,0.0,FALSE);
        if(ierr==0 && ddum <=0.0) {
          ierr=-200;
          break;
        }
        ierr=arg_dble(ptr,&lcl->lo_min,-1.0,TRUE);
        break;
      case 5:
        ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
        if(ierr == 0 && dum == -1) {
           ierr=-110;
           break;
        }
        ddum=1.0;
        ierr=arg_dble(ptr,&ddum,0.0,FALSE);
        if(ierr==0 && ddum <=0.0) {
          ierr=-200;
          break;
        }
        ierr=arg_dble(ptr,&lcl->lo_max,lcl->lo_min,TRUE);
        if(lcl->lo_max < lcl->lo_min || lcl->lo_min < 0.0 && lcl->lo_max > 0.0)
           ierr=-200;
        break;
      case 6:
        ierr=arg_key(ptr,star_key,STAR_KEY,&dum,0,FALSE);
        if(ierr == 0 && dum == -1) {
           ierr=-110;
           break;
        }
	ierr=arg_key(ptr,sb_key,SB_KEY,&lcl->lo_sb,0,TRUE);
        break;
      default:
        *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc3_sub_lo_enc(output,count,lcl,itable)
char *output;
int *count;
struct dbbc3_sub_lo_table *lcl;
int itable;
{
    int ivalue;

    output=output+strlen(output);

    int valid=itable>=0 && itable<shm_addr->dbbc3_sub_lo.count;
    if(valid)
      lcl+=itable;
    switch (*count) {
      case 2:
        if(!valid)
            break;
        if(lcl->freq>0.0) {
            sprintf(output,"%f",lcl->freq);
            int len=strlen(output);
            while(len-->0 && '0' == output[len])
                output[len]=0;
            if(len>=0 && '.'==output[len])
                output[len]=0;
        }
        break;
      case 3:
        if(!valid)
            break;
        ivalue=lcl->sb;
        if (ivalue >0 && ivalue <SB_KEY)
          strcpy(output,sb_key[ivalue]);
        break;
      case 4:
        if(!valid)
            break;
        if(lcl->lo_min>=0.0) {
            sprintf(output,"%f",lcl->lo_min);
            int len=strlen(output);
            while(len-->0 && '0' == output[len])
                output[len]=0;
            if(len>=0 && '.'==output[len])
                output[len]=0;
        }
        break;
      case 5:
        if(!valid)
            break;
        if(lcl->lo_max>=0.0) {
            sprintf(output,"%f",lcl->lo_max);
            int len=strlen(output);
            while(len-->0 && '0' == output[len])
                output[len]=0;
            if(len>=0 && '.'==output[len])
                output[len]=0;
        }
        break;
      case 6:
        if(!valid)
            break;
        ivalue=lcl->lo_sb;
        if (ivalue >=0 && ivalue <SB_KEY)
          strcpy(output,sb_key[ivalue]);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}
int find_sub_lo(ilo,freq,sb)
int ilo;
double *freq;
int *sb;
{
   int i;

   if(ilo<0 || ilo>shm_addr->dbbc3_ddc_ifs-1)
       return -2;

    if (shm_addr->lo.lo[ilo]<0)
        return -1;
    
    for (i=0;i<shm_addr->dbbc3_sub_lo.count;i++) {
        if(shm_addr->dbbc3_sub_lo.table[i].ifc!=-1 && shm_addr->dbbc3_sub_lo.table[i].ifc!=ilo)
            continue;
        if(shm_addr->dbbc3_sub_lo.table[i].lo_min>=0.0 && shm_addr->lo.lo[ilo] < shm_addr->dbbc3_sub_lo.table[i].lo_min-0.001)
            continue;
        if(shm_addr->dbbc3_sub_lo.table[i].lo_max>=0.0 && shm_addr->lo.lo[ilo] > shm_addr->dbbc3_sub_lo.table[i].lo_max+0.001)
            continue;
        if(shm_addr->dbbc3_sub_lo.table[i].lo_sb!=0  && shm_addr->lo.sideband[ilo] != shm_addr->dbbc3_sub_lo.table[i].lo_sb)
            continue;
        if(shm_addr->dbbc3_sub_lo.table[i].lo_sb!=0  && shm_addr->lo.sideband[ilo] != shm_addr->dbbc3_sub_lo.table[i].lo_sb)
            continue;
        *freq=shm_addr->dbbc3_sub_lo.table[i].freq;
        *sb=shm_addr->dbbc3_sub_lo.table[i].sb;
        return i;
    }

    return -1;
}

