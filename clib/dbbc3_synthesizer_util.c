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
/* dbbc3 synthesizer buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *output_key[ ]={"disable","enable"};
static char *check_key[ ]={"force","check","force_plus"};
static char *sb_key[ ]={"all","usb","lsb"};

static char *atten_key[ ]=
  { "0.0", "0.5", "1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0", "4.5",
    "5.0", "5.5", "6.0", "6.5", "7.0", "7.5", "8.0", "8.5", "9.0", "9.5",
   "10.0","10.5","11.0","11.5","12.0","12.5","13.0","13.5","14.0","14.5",
   "15.0","15.5","16.0","16.5","17.0","17.5","18.0","18.5","19.0","19.5",
   "20.0","20.5","21.0","21.5","22.0","22.5","23.0","23.5","24.0","24.5",
   "25.0","25.5","26.0","26.5","27.0","27.5","28.0","28.5","29.0","29.5",
   "30.0","30.5","31.0","31.5"
  };
static char *mode_key[ ]={"CW","SWEEP","LIST","unknown"};
static char *ref_source_key[ ]={"internal","external"};
static char *lock_key[ ]={"unlocked","locked","unknown"};

#define SB_KEY  sizeof(sb_key)/sizeof( char *)
#define NOUTPUT_KEY sizeof(output_key)/sizeof( char *)
#define NCHECK_KEY sizeof(check_key)/sizeof( char *)
#define NATTEN_KEY sizeof(atten_key)/sizeof( char *)
#define NMODE_KEY sizeof(mode_key)/sizeof( char *)
#define NREF_SOURCE_KEY sizeof(lock_key)/sizeof( char *)
#define NLOCK_KEY sizeof(lock_key)/sizeof( char *)

int dbbc3_synthesizer_dec(lcl,count,ptr,itask,ilo)
struct dbbc3_synthesizer_cmd *lcl;
int *count;
char *ptr;
int ilo;
{
    int ierr, ind, arg_key();

    int idefault, kdefault;
    double ddum;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 2:

        ddum=1.0;
        ierr=arg_dble(ptr,&ddum,0.0,FALSE);
        if(ierr==0 && ddum <=0.0) {
          ierr=-200;
          break;
        }
        m5state_init(&lcl->freq.state);
        m5state_init(&lcl->ext_lo_freq.state);
        m5state_init(&lcl->ext_lo_sb.state);
        m5state_init(&lcl->input_sb.state);

        ierr=arg_dble(ptr,&lcl->freq.freq,0.0,FALSE);
        if(-100==ierr) { /* default */
            if(1!=shm_addr->dbbc3_ifx[ilo].input && 2 !=shm_addr->dbbc3_ifx[ilo].input ||
                    shm_addr->lo.lo[ilo] < 0.0 && 2 ==shm_addr->dbbc3_ifx[ilo].input  ||
                    shm_addr->lo.sideband[ilo]<1  || 2<shm_addr->lo.sideband[ilo]) {
                lcl->freq.freq=-1.0;
            } else {
                double freq;
                int sb;
                int itable=find_ext_lo(ilo, &freq, &sb);
                if(itable>=0) {
                    if(shm_addr->lo.lo[ilo] < freq+0.001 &&
                            shm_addr->lo.lo[ilo] > freq-0.001) {  /* ext_lo == lo */
                        if(2==shm_addr->dbbc3_ifx[ilo].input) {
                            ierr=-220;
                            break;
                        } else if(shm_addr->lo.sideband[ilo]!=sb) {
                            ierr=-230;
                            break;
                        }
                        lcl->freq.freq=-1.0;
                    } else {  /* ext_lo != lo */
                        if(1==shm_addr->dbbc3_ifx[ilo].input) {
                            ierr=-240;
                            break;
                        } else if(freq<shm_addr->lo.lo[ilo]) { /* ext_lo < lo */
                            if(1!=sb) {
                                ierr=-250;
                                break;
                            }
                            lcl->input_sb.input_sb=shm_addr->lo.sideband[ilo];
                            lcl->input_sb.state.known=1;
                        } else { /* ext_lo > lo */
                            if(2!=sb) {
                                ierr=-260;
                                break;
                            } else  if(shm_addr->lo.lo[ilo] == 0.0 && 2==shm_addr->lo.sideband[ilo]) {
                                ierr=-270;
                                break;
                            }
                            lcl->input_sb.input_sb=3-shm_addr->lo.sideband[ilo];
                            lcl->input_sb.state.known=1;
                        }
                        lcl->freq.freq=fabs(shm_addr->lo.lo[ilo]-freq);
                    }
                    lcl->ext_lo_freq.ext_lo_freq=freq;
                    lcl->ext_lo_freq.state.known=1;
                    lcl->ext_lo_sb.ext_lo_sb=sb;
                    lcl->ext_lo_sb.state.known=1;
                } else { /* no ext_lo */
                    if(2==shm_addr->dbbc3_ifx[ilo].input) { /* synthesizer used */
                        if(shm_addr->lo.lo[ilo] == 0.0) {
                            ierr=-280;
                            break;
                        }
                        lcl->input_sb.input_sb=shm_addr->lo.sideband[ilo];
                        lcl->input_sb.state.known=1;
                        lcl->freq.freq=shm_addr->lo.lo[ilo];
                    } else
                        lcl->freq.freq=-1.0;
                }
            }
            ierr=0;
        }

        if(ierr==0 && lcl->freq.freq >0.0) {
            lcl->freq.state.known=1;
        } else if(ierr!=0) {
            lcl->freq.state.error=1;
        }
        break;
      case 3:
        kdefault=FALSE;
        if(2==shm_addr->dbbc3_ifx[ilo].input) {
           idefault=1;
           kdefault=TRUE;
        } else if(1==shm_addr->dbbc3_ifx[ilo].input) {
           idefault=0;
           kdefault=TRUE;
        }
	ierr=arg_key(ptr,output_key,NOUTPUT_KEY,&lcl->output.output,idefault,kdefault);
        m5state_init(&lcl->output.state);
        if(ierr==0 && lcl->output.output<0)
            ierr=-200;
        if(ierr==0) {
          lcl->output.state.known=1;
        } else {
            lcl->output.state.error=1;
        }
        break;
      case 4:
	ierr=arg_key(ptr,check_key,NCHECK_KEY,&lcl->check.check,1,TRUE);
        m5state_init(&lcl->check.state);
        if(ierr==0) {
            lcl->check.state.known=1;
        } else {
            lcl->check.state.error=1;
        }
        break;
      default:
        *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dbbc3_synthesizer_enc(output,count,lcl)
char *output;
int *count;
struct dbbc3_synthesizer_cmd *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 2:
        if(lcl->freq.state.known) {
            if(lcl->output.state.known && 0==lcl->output.output)
                strcpy(output++,"(");
            sprintf(output,"%f",lcl->freq.freq);
            int len=strlen(output);
            while(--len>0 && '0' == output[len])
                output[len]=0;
            if(len>0 && '.'==output[len])
                output[len]=0;
            if(lcl->output.state.known && 0==lcl->output.output)
                strcat(output,")");
        }
        break;
      case 3:
        if(lcl->output.state.known) {
          ivalue=lcl->output.output;
          if (ivalue >=0 && ivalue <NOUTPUT_KEY)
            strcpy(output,output_key[ivalue]);
          else
            strcpy(output,BAD_VALUE);
        }
        break;
      case 4:
        if(lcl->ext_lo_freq.state.known || lcl->ext_lo_sb.state.known) {
            strcpy(output++,"(");
            if(lcl->ext_lo_freq.state.known) {
                sprintf(output,"%f",lcl->ext_lo_freq.ext_lo_freq);
                int len=strlen(output);
                while(len-->0 && '0' == output[len])
                    output[len]=0;
                if(len>=0 && '.'==output[len])
                    output[len]=0;
            }

            strcat(output,"/");

            if(lcl->ext_lo_sb.state.known) {
                ivalue=lcl->ext_lo_sb.ext_lo_sb;
                if (ivalue >0 && ivalue <SB_KEY)
                    strcat(output,sb_key[ivalue]);
                else
                    strcat(output,BAD_VALUE);
            }
            strcat(output,")");
        }
        break;
      case 5:
        if(lcl->input_sb.state.known) {
          strcpy(output++,"(");
          ivalue=lcl->input_sb.input_sb;
          if (ivalue >0 && ivalue <SB_KEY)
            strcpy(output,sb_key[ivalue]);
          else
            strcpy(output,BAD_VALUE);
          strcat(output,")");
        }
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void dbbc3_synthesizer_mon(output,count,lcl)
char *output;
int *count;
struct dbbc3_synthesizer_mon *lcl;
{
    int ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue=lcl->atten.atten;
        if (ivalue >=0 && ivalue <NATTEN_KEY)
          strcpy(output,atten_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
        ivalue=lcl->mode.mode;
        if (ivalue >=0 && ivalue <NMODE_KEY)
          strcpy(output,mode_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        ivalue=lcl->ref_source.ref_source;
        if (ivalue >=0 && ivalue <NLOCK_KEY)
          strcpy(output,ref_source_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 4:
        if(lcl->ref_freq.state.known) {
            sprintf(output,"%f",lcl->ref_freq.ref_freq);
            int len=strlen(output);
            while(--len>0 && '0' == output[len])
                output[len]=0;
            if(len>0 && '.'==output[len])
                output[len]=0;
        }
        break;
      case 5:
        if(lcl->ref_doubler.state.known) {
          ivalue=lcl->ref_doubler.ref_doubler;
          if (ivalue >=0 && ivalue <NOUTPUT_KEY)
            strcpy(output,output_key[ivalue]);
          else
            strcpy(output,BAD_VALUE);
        }
        break;
      case 6:
        if(lcl->ref_divider.state.known) {
          ivalue=lcl->ref_divider.ref_divider;
          if (ivalue >=0 && ivalue <NOUTPUT_KEY)
            strcpy(output,output_key[ivalue]);
          else
            strcpy(output,BAD_VALUE);
        }
        break;
      case 7:
        if(lcl->freq_offset.state.known) {
            sprintf(output,"%f",lcl->freq_offset.freq_offset);
            int len=strlen(output);
            while(--len>0 && '0' == output[len])
                output[len]=0;
            if(len>0 && '.'==output[len])
                output[len]=0;
        }
        break;
      case 8:
        ivalue=lcl->lock.lock;
        if (ivalue >=0 && ivalue <NLOCK_KEY)
          strcpy(output,lock_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void synthesizer_freq_2_dbbc3(buff,lcl)
char *buff;
struct dbbc3_synthesizer_cmd *lcl;
{

  sprintf(buff+strlen(buff),";CW %f MHz",lcl->freq.freq/2);

  return;
}

void synthesizer_output_2_dbbc3(buff,lcl)
char *buff;
struct dbbc3_synthesizer_cmd *lcl;
{

  sprintf(buff+strlen(buff),";oen %d",lcl->output.output);

  return;
}

int dbbc3_2_synthesizer_freq(lclc,buff)
struct dbbc3_synthesizer_cmd *lclc;
char *buff;
{

  m5state_init(&lclc->freq.state);

  if(1!=sscanf(buff,"F %lf",&lclc->freq.freq))
      return -1;

  lclc->freq.freq*=2;

  lclc->freq.state.known=1;

  return 0;
}
int dbbc3_2_synthesizer_output(lclc,buff)
struct dbbc3_synthesizer_cmd *lclc;
char *buff;
{
  m5state_init(&lclc->output.state);

  if(1!=sscanf(buff,"OEN %d",&lclc->output.output))
     return -1;
  if(0!=lclc->output.output && 1!=lclc->output.output)
     return -1;

  lclc->output.state.known=1;

  return 0;
}
int dbbc3_2_synthesizer_atten(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  if(arg_key(buff+4,atten_key,NATTEN_KEY,&lclm->atten.atten,0,FALSE))
     return -1;

  return 0;
}
int dbbc3_2_synthesizer_mode(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  if(arg_key(buff+5,mode_key,NMODE_KEY-1,&lclm->mode.mode,0,FALSE)) {
      char buf[256];
      sprintf(buf,"Unknown synthesizer mode is '%s'",buff);
      logite(buf,-614,"dm");
      lclm->mode.mode=3;
  }

  return 0;
}

int dbbc3_2_synthesizer_lock(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  if(NULL!=strstr(buff,"unlocked")||strstr(buff,"not locked"))
     lclm->lock.lock=0;
  else if(NULL!=strstr(buff," locked"))
     lclm->lock.lock=1;
  else {
      char buf[256];
      sprintf(buf,"Unknown synthesizer lock status is '%s'",buff);
      logite(buf,-615,"dm");
      lclm->lock.lock=2;
  }

  return 0;
}

int dbbc3_2_synthesizer_ref_source(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  m5state_init(&lclm->ref_source.state);

  if(1!=sscanf(buff,"REFS %d",&lclm->ref_source.ref_source))
     return -1;
  if(0!=lclm->ref_source.ref_source && 1!=lclm->ref_source.ref_source)
     return -1;

  lclm->ref_source.state.known=1;

  return 0;
}
int dbbc3_2_synthesizer_ref_freq(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{

  m5state_init(&lclm->ref_freq.state);

  if(1!=sscanf(buff,"REF %lf",&lclm->ref_freq.ref_freq))
      return -1;

  lclm->ref_freq.state.known=1;

  return 0;
}
int dbbc3_2_synthesizer_ref_doubler(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  m5state_init(&lclm->ref_doubler.state);

  if(1!=sscanf(buff,"REFDB %d",&lclm->ref_doubler.ref_doubler))
     return -1;
  if(0!=lclm->ref_doubler.ref_doubler && 1!=lclm->ref_doubler.ref_doubler)
     return -1;

  lclm->ref_doubler.state.known=1;

  return 0;
}
int dbbc3_2_synthesizer_ref_divider(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{
  m5state_init(&lclm->ref_divider.state);

  if(1!=sscanf(buff,"REFDIV %d",&lclm->ref_divider.ref_divider))
     return -1;
  if(0!=lclm->ref_divider.ref_divider && 1!=lclm->ref_divider.ref_divider)
     return -1;

  lclm->ref_divider.state.known=1;

  return 0;
}

int dbbc3_2_synthesizer_freq_offset(lclm,buff)
struct dbbc3_synthesizer_mon *lclm;
char *buff;
{

  m5state_init(&lclm->freq_offset.state);

  if(1!=sscanf(buff,"OFFSET %lf",&lclm->freq_offset.freq_offset))
      return -1;

  lclm->freq_offset.state.known=1;

  return 0;
}
