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
/* lba das ifp buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

/* function prototypes */
int arg_key();
int arg_dble();
int arg_key_flt();

/* global variables/definitions */
static char *sb_key[ ]={"usb","lsb"};
static char *bw_key[ ]={"0.0625","0.125","0.25","0.5","1","2","4","8","16","32","64"};
static char *md_key[ ]={"none","scb","dsb","acb","sc1","ds2","ds4","ds6","ac1"};
static char *en_key[ ]={"off","on"};

#define NSB_KEY sizeof(sb_key)/sizeof( char *)
#define NBW_KEY sizeof(bw_key)/sizeof( char *)
#define NMD_KEY sizeof(md_key)/sizeof( char *)
#define NEN_KEY sizeof(sb_key)/sizeof( char *)

int lba_ft_dec(lcl,count,ptr)
  struct ifp *lcl;
  int *count;
  char *ptr;
{
    int ierr, ft_bw;
    double frequency;

    ierr=0;
    if(ptr == NULL) ptr="";
    switch (*count) {
      case 1:
          ierr=arg_key(ptr,sb_key,NSB_KEY,&lcl->bs.digout.setting,_USB,TRUE);
        break;
      case 2:
          ierr=arg_dble(ptr,&frequency,8.0/pow(2,lcl->bs.clock_decimation),TRUE);
          lcl->ft_lo = frequency * pow(2,lcl->bs.clock_decimation);
          if (lcl->ft_lo < 0.0 || lcl->ft_lo > 16.0)
             ierr = -200;
        break;
      case 3:
          ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&ft_bw,lcl->bandwidth,TRUE);
          lcl->ft.clock_decimation = _16D00 - lcl->bs.clock_decimation - ft_bw;
          if (lcl->ft.clock_decimation < 0 || lcl->ft.clock_decimation > 4)
             ierr = -200;
        break;
      case 4:
          ierr=arg_key(ptr,md_key,NMD_KEY,&lcl->ft_filter_mode,_NONE,TRUE);
          if (lcl->ft_filter_mode >= _SC1 ||
              (lcl->ft_filter_mode == _NONE && lcl->ft.clock_decimation != 0) ||
              (lcl->ft_filter_mode == _DSB && lcl->ft.clock_decimation < 1))
             ierr = -200;
        break;
      case 5:
          ierr=arg_dble(ptr,&frequency,0.0,TRUE);
          lcl->ft_offs = frequency * pow(2,lcl->bs.clock_decimation);
          if (lcl->ft_lo + lcl->ft_offs < 0.0 ||
              lcl->ft_lo + lcl->ft_offs > 16.0)
             ierr = -200;
        break;
      case 6:
          ierr=arg_dble(ptr,&lcl->ft_phase,0.0,TRUE);
          if (lcl->ft_phase < 0.0 || lcl->ft_phase > 360.0)
             ierr = -200;
        break;
      case 7:
          ierr=arg_key(ptr,en_key,NEN_KEY,&lcl->ft.nco_test,_OFF,TRUE);
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void lba_ft_enc(output,count,lcl)
char *output;
int *count;
struct ifp *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->bs.digout.setting;
        if (ivalue >=0 && ivalue <NSB_KEY)
          strcpy(output,sb_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
        sprintf(output,"%-.2f",lcl->ft_lo/pow(2,lcl->bs.clock_decimation));
        break;
      case 3:
        ivalue = _16D00 - lcl->bs.clock_decimation - lcl->ft.clock_decimation;
        if (ivalue >=0 && ivalue <NBW_KEY)
          strcpy(output,bw_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 4:
        ivalue = lcl->ft_filter_mode;
        if (ivalue >=0 && ivalue <NMD_KEY)
          strcpy(output,md_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
        sprintf(output,"%-.2f",lcl->ft_offs);
        break;
      case 6:
        sprintf(output,"%-.2f",lcl->ft_phase);
        break;
      case 7:
        ivalue = lcl->ft.nco_test;
        if (ivalue >=0 && ivalue <NEN_KEY)
          strcpy(output,en_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}
