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
/* pcald buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>

#include "../include/macro.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *chd_key[ ]={
  "1u","2u","3u","4u","5u","6u","7u","8u",
  "9u","10u","11u","12u","13u","14u","15u","16u",
  "1l","2l","3l","4l","5l","6l","7l","8l",
  "9l","10l","11l","12l","13l","14l","15l","16l"
};
static char *cont_key[ ]={"no","yes"};
static char *bits_key[ ]={"auto","1","2"};

#define CHD_KEY  sizeof(chd_key)/sizeof( char *)
#define CONT_KEY sizeof(cont_key)/sizeof( char *)
#define BITS_KEY sizeof(cont_key)/sizeof( char *)

int bbc2freq(unsigned int );

int pcald_dec(lcl,count,ptr)
struct pcald_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k;
    double freq;
    static int iconv, isb;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,cont_key,CONT_KEY,&lcl->continuous,0,TRUE);
      for(i=0;i<2;i++)
	for(j=0;j<16;j++)
	  lcl->count[i][j]=0;
      break;
    case 2:
      ierr=arg_key(ptr,bits_key,BITS_KEY,&lcl->bits,0,TRUE);
      break;
    case 3:
      ierr=arg_int(ptr,&lcl->integration,0,TRUE);
      if(ierr==0 & lcl->integration < 0)
	ierr=-200;
      break;
    default:
      *count=-1;
      for(i=0;i<2;i++)
	for(j=0;j<16;j++)
	  for (k=0;k<shm_addr->pcalform.count[i][j];k++) {
	    if(shm_addr->pcalform.which[i][j][k]!=0) {
	      double freq,bw,offset,spacing;
	      int tone, if_source;
	      if(shm_addr->equip.rack == VLBA ||
		 shm_addr->equip.rack == VLBA4) {
		
		if_source=shm_addr->bbc[j].source;
		if(if_source < 0 || if_source >3) {
		  ierr=-100;
		  break;
		}
		freq=bbc2freq(shm_addr->bbc[j].freq)/100.;
		bw=(1<<shm_addr->bbc[j].bw[i])*0.0625;
	      } else { /* MK3 or Mk4 */
		if_source=abs(shm_addr->ifp2vc[j])-1;
		if(if_source < 0 || if_source >2) {
		  ierr=-96;
		  break;
		}
		freq=rint(shm_addr->freqvc[j]/.01)*.01;
		if(freq  < 0.005) {
		  ierr=-95;
		  break;
		}
		if(shm_addr->ibwvc[j]!=0) {
		  if(shm_addr->equip.rack==MK4 && shm_addr->ibwvc[j]==2)
		      bw=16.0;
		  else if(shm_addr->equip.rack==MK4 && shm_addr->ibwvc[j]==4)
		      bw=8.0;
		  else
		    bw=(1<<shm_addr->ibwvc[j])*.0625;
		} else if(shm_addr->extbwvc[j]<0.0) {
		  ierr=-94;
		} else
		  bw=shm_addr->extbwvc[j];
		if(if_source == 2) {
		  if(shm_addr->imixif3==1)
		    freq+=shm_addr->freqif3*.01;
		  else if(shm_addr->imixif3!=2)
		    ierr=-93;
		}
	      }
	      if(shm_addr->lo.lo[if_source] < 0.0) {
		ierr=-99;
		break;
	      } else if(shm_addr->lo.spacing[if_source] <0.0 &&
			shm_addr->lo.pcal[if_source] == 0) {
		ierr=-98;
		break;
	      } else if(shm_addr->lo.spacing[if_source] <0.0 &&
			shm_addr->lo.pcal[if_source] == 1) {
		break;
	      }
	      spacing=shm_addr->lo.spacing[if_source];
	      offset=shm_addr->lo.offset[if_source];
	      freq-=offset;
	      tone=shm_addr->pcalform.tones[i][j][k];
	      if(tone>0) {
		if(i==0)
		  freq=(tone+(int)(freq/spacing))*spacing-freq;
		else
		  freq=freq-
		    ((int)((freq-0.0000000005)/spacing)-(tone-1))*spacing;
		if(freq < -0.0000000005 || freq > bw+spacing) {
		  ierr=-97;
		  break;
		}
	      } else if (tone<0) {
		if(i==0)
		  freq=
		    (tone+1+(int)((freq+bw-.0000000005)/spacing))*spacing-
		      freq;
		else
		  freq=freq-((int)((freq-bw)/spacing)-tone)*spacing;
		if(freq < -0.0000000005 || freq > bw+spacing) {
		  ierr=-97;
		  break;
		}
	      } else
		freq=-1.0;
	      if(freq>-0.0000000005)
		freq=rint(freq/0.000000001)*0.000000001;
	      lcl->freqs[i][j][k]=freq;
	      lcl->count[i][j]++;
	    } else {
	      lcl->freqs[i][j][k]=shm_addr->pcalform.freqs[i][j][k];
	      lcl->count[i][j]++;
	    }
	  }
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void pcald_enc(output,count,lcl)
char *output;
int *count;
struct pcald_cmd *lcl;
{
  int ivalue,i;
  static int ich, inext;

  output=output+strlen(output);

  if(*count == 1) {
    ivalue=lcl->continuous;
    if (ivalue >=0 && ivalue <CONT_KEY)
      strcat(output,cont_key[ivalue]);
    else
      strcat(output,BAD_VALUE);
    strcat(output,",");

    ivalue=lcl->bits;
    if (ivalue >=0 && ivalue <BITS_KEY)
      strcat(output,bits_key[ivalue]);
    else
      strcat(output,BAD_VALUE);
    strcat(output,",");

    sprintf(output+strlen(output),"%d",lcl->integration);
    goto end;
  }
    
  if(*count == 2) {
    ich=0;
    inext=0;
  } else if( inext >= lcl->count[ich/16][ich%16]) {
    ich++;
    inext=0;
  }

  if(inext == 0) {
    while(ich<32 && lcl->count[ich/16][ich%16] <= 0)
      ich++;
    if(ich >= 32) {
      *count=-1;
      return;
    }
  }

  strcpy(output,chd_key[ich]);
  strcat(output,",");
  
  for(i=inext;i<lcl->count[ich/16][ich%16];i++) {
    int pos,idec,iwid;
    char test[36];

    iwid=17;
    if(lcl->freqs[ich/16][ich%16][i] < -0.0000000005) {
      if(strlen(output) > 40) {
	inext=i;
	goto end;
      } else {
	if(i!=inext)
	  strcat(output,",");
	strcat(output,"state_counting");
	continue;
      }
    }
    if(lcl->freqs[ich/16][ich%16][i] > .9999999995)
      idec=iwid-(2+log10(lcl->freqs[ich/16][ich%16][i]));
    else
      idec=iwid-2;
    test[0]='\0';
    dble2str(test,lcl->freqs[ich/16][ich%16][i],iwid,idec);
    pos=strlen(test)-1;
    while(test[pos]=='0') {
      test[pos]='\0';
      pos=strlen(test)-1;
    }
      
    pos=strlen(test)-1;
    if(test[pos]=='.')
      test[pos]='\0';
    if(strlen(test)+strlen(output) > 55) {
      inext=i;
      goto end;
    } else {
      if(i!=inext)
	strcat(output,",");
      strcat(output,test);
    }
  }
  inext=i;

 end:
  if(*count>0)
    *count++;
  return;
}
