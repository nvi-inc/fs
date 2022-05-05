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
/* tpicd buffer parsing utilities */

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

static char *cont_key[ ]={"no","yes"};
static char *bits_key[ ]={"auto","1","2"};

#define CHD_KEY  sizeof(chd_key)/sizeof( char *)
#define CONT_KEY sizeof(cont_key)/sizeof( char *)
#define BITS_KEY sizeof(cont_key)/sizeof( char *)

static char chanm[] = "0123";
static char chanv[] = "0abcd";
static char chan3[] = "0abcdefgh";
static char chanl[] = "01234";
static char hex[]= "0123456789abcdef";
static char det[] = "dlu34567";
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};
static char *lwhati[ ]={
"ia","ib","ic","id"};
static char *lwhat3[ ]={
"001l", "002l", "003l", "004l", "005l", "006l", "007l", "008l",
"009l", "010l", "011l", "012l", "013l", "014l", "015l", "016l",
"017l", "018l", "019l", "020l", "021l", "022l", "023l", "024l",
"025l", "026l", "027l", "028l", "029l", "030l", "031l", "032l",
"033l", "034l", "035l", "036l", "037l", "038l", "039l", "040l",
"041l", "042l", "043l", "044l", "045l", "046l", "047l", "048l",
"049l", "050l", "051l", "052l", "053l", "054l", "055l", "056l",
"057l", "058l", "059l", "060l", "061l", "062l", "063l", "064l",
"065l", "066l", "067l", "068l", "069l", "070l", "071l", "072l",
"073l", "074l", "075l", "076l", "077l", "078l", "079l", "080l",
"081l", "082l", "083l", "084l", "085l", "086l", "087l", "088l",
"089l", "090l", "091l", "092l", "093l", "094l", "095l", "096l",
"097l", "098l", "099l", "100l", "101l", "102l", "103l", "104l",
"105l", "106l", "107l", "108l", "109l", "110l", "111l", "112l",
"113l", "114l", "115l", "116l", "117l", "118l", "119l", "120l",
"121l", "122l", "123l", "124l", "125l", "126l", "127l", "128l",
"001u", "002u", "003u", "004u", "005u", "006u", "007u", "008u",
"009u", "010u", "011u", "012u", "013u", "014u", "015u", "016u",
"017u", "018u", "019u", "020u", "021u", "022u", "023u", "024u",
"025u", "026u", "027u", "028u", "029u", "030u", "031u", "032u",
"033u", "034u", "035u", "036u", "037u", "038u", "039u", "040u",
"041u", "042u", "043u", "044u", "045u", "046u", "047u", "048u",
"049u", "050u", "051u", "052u", "053u", "054u", "055u", "056u",
"057u", "058u", "059u", "060u", "061u", "062u", "063u", "064u",
"065u", "066u", "067u", "068u", "069u", "070u", "071u", "072u",
"073u", "074u", "075u", "076u", "077u", "078u", "079u", "080u",
"081u", "082u", "083u", "084u", "085u", "086u", "087u", "088u",
"089u", "090u", "091u", "092u", "093u", "094u", "095u", "096u",
"097u", "098u", "099u", "100u", "101u", "102u", "103u", "104u",
"105u", "106u", "107u", "108u", "109u", "110u", "111u", "112u",
"113u", "114u", "115u", "116u", "117u", "118u", "119u", "120u",
"121u", "122u", "123u", "124u", "125u", "126u", "127u", "128u",
"ia", "ib", "ic", "id", "ie", "if", "ig", "ih"
};

int tpicd_dec(lcl,count,ptr)
struct tpicd_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k, jend, icore, ik;
    double freq;
    static int iconv, isb;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,cont_key,CONT_KEY,&lcl->continuous,0,TRUE);
      for(i=0;i<MAX_GLOBAL_DET;i++)
	lcl->itpis[i]=0;
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->cycle,0,FALSE);
      if(ierr==0 & lcl->cycle < 0)
	ierr=-200;
      break;
    default:
      if(shm_addr->equip.rack==MK3) {
	if(shm_addr->imodfm==0||shm_addr->imodfm==2) {
              for(i=0;i<14;i++)
		lcl->itpis[i]=1;
	} else if(shm_addr->imodfm==1) {
              for(i=0;i<14;i=i+2)
		lcl->itpis[i]=1;
	} else if(shm_addr->imodfm==3) {
		lcl->itpis[1]=1;
	}
      } else if(shm_addr->equip.rack==MK4&&shm_addr->equip.rack_type==MK45 &&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS ||
		 shm_addr->equip.drive_type[0]==MK5C ||
		 shm_addr->equip.drive_type[0]==MK5C_BS ||
		 shm_addr->equip.drive_type[0]==FLEXBUFF) ) {
	mk5vcd(lcl->itpis);
      } else if(shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	mk4vcd(lcl->itpis);
      } else if(shm_addr->equip.rack==VLBA) {
	vlbabbcd(lcl->itpis);
      } else if(shm_addr->equip.rack==VLBA4 && 
		shm_addr->equip.rack_type==VLBA45 &&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS ||
		 shm_addr->equip.drive_type[0]==MK5C ||
		 shm_addr->equip.drive_type[0]==MK5C_BS ||
		 shm_addr->equip.drive_type[0]==FLEXBUFF) ) {
	mk5bbcd(lcl->itpis); 
      } else if(shm_addr->equip.rack==VLBA4) {
	mk4bbcd(lcl->itpis);
      } else if(shm_addr->equip.rack==LBA) {
	lbaifpd(lcl->itpis);
      } else if(shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_DDC ||
		 shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
		&&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS ||
		 shm_addr->equip.drive_type[0]==MK5C ||
		 shm_addr->equip.drive_type[0]==MK5C_BS ||
		 shm_addr->equip.drive_type[0]==FLEXBUFF) ) {
	mk5dbbcd(lcl->itpis); 
      } else if(shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_PFB ||
		 shm_addr->equip.rack_type == DBBC_PFB_FILA10G)
		&&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS ||
		 shm_addr->equip.drive_type[0]==MK5C ||
		 shm_addr->equip.drive_type[0]==MK5C_BS ||
		 shm_addr->equip.drive_type[0]==FLEXBUFF) ) {
	mk5dbbcd_pfb(lcl->itpis); 
      } else if(shm_addr->equip.rack==DBBC3) {  /* find BBCs */
	for (i=0;i<shm_addr->dbbc3_ddc_ifs;i++) {
	  jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	  if(8<jend) jend=8;
	  for (j=0;j<jend;j++) {
	    lcl->itpis[j+i*8]=1;
	    lcl->itpis[j+i*8+MAX_DBBC3_BBC]=1;
	  }
	  if(shm_addr->dbbc3_ddc_bbcs_per_if>8) {
	    jend=shm_addr->dbbc3_ddc_bbcs_per_if;
	    if(16<jend) jend=16;
	    for (j=8;j<jend;j++) {
	      lcl->itpis[64+j-8+i*8]=1;
	      lcl->itpis[64+j-8+i*8+MAX_DBBC3_BBC]=1;
	    }
	  }   
	}
      }

      if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	for (i=0;i<14;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=abs(shm_addr->ifp2vc[i]);
	    if(lcl->ifc[i]<0||lcl->ifc[i]>3)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0) /*select the corresponding IFs too*/
	      lcl->itpis[14+lcl->ifc[i]-1]=1;
	    lcl->lwhat[i][0]=hex[i+1];
	    if(shm_addr->ITPIVC[i]==-1)
	      lcl->lwhat[i][1]='x';
	    else
	      lcl->lwhat[i][1]=det[shm_addr->ITPIVC[i]&0x7];
	    lcl->lwhat[i][2]=0;
	  }
	for (i=14;i<17;i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-13;
	    lcl->lwhat[i][0]='i';
	    lcl->lwhat[i][1]=hex[i-13];
	    lcl->lwhat[i][2]=0;
	  }
      }else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	for (i=0;i<2*MAX_VLBA_BBC;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->bbc[i%MAX_BBC].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>MAX_IF)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0)
	      lcl->itpis[2*MAX_BBC+lcl->ifc[i]-1]=1;
	    strncpy(lcl->lwhat[i],lwhat[i],3);
	  }
	for (i=2*MAX_BBC;i<(2*MAX_BBC+MAX_VLBA_IF);i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-(2*MAX_BBC-1);
	    strncpy(lcl->lwhat[i],lwhat[i],3);
	  }
      }else if (shm_addr->equip.rack==LBA) {
        for (i=0;i<2*shm_addr->n_das;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->das[i/2].ifp[i%2].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>4)
	      lcl->ifc[i]=0;
	    strncpy(lcl->lwhat[i],lwhat[i+MAX_BBC],3);
	    lcl->lwhat[i][1]=det[0];
	  }
      }else if (shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_DDC ||
		 shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
		) {
	for (i=0;i<2*MAX_DBBC_BBC;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->dbbcnn[i%MAX_DBBC_BBC].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>MAX_DBBC_IF)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0)
	      lcl->itpis[2*MAX_DBBC_BBC+lcl->ifc[i]-1]=1;
	    strncpy(lcl->lwhat[i],lwhat[i],3);
	  }
	for (i=2*MAX_DBBC_BBC;i<2*MAX_DBBC_BBC+MAX_DBBC_IF;i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-(2*MAX_DBBC_BBC-1);
	    strncpy(lcl->lwhat[i],lwhat[i],3);
	  }
      }else if (shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_PFB ||
		 shm_addr->equip.rack_type == DBBC_PFB_FILA10G)
		) {
	icore=0;
	for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	  for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	    icore++;
	    for(k=1;k<16;k++) {
	      ik=k+(icore-1)*16;
	      if(1==lcl->itpis[ik]) {
		lcl->ifc[ik]=i+1;
		if(lcl->ifc[ik]<0||lcl->ifc[ik]>MAX_DBBC_IF)
		  lcl->ifc[ik]=0;
		if(lcl->ifc[ik]!=0)
		  lcl->itpis[i+MAX_DBBC_PFB]=1;
		snprintf(lcl->lwhat[ik],4,"%c%02d",lwhati[i][1],k+j*16);
	      }
	    }
	    if(lcl->itpis[i+MAX_DBBC_PFB]!=0) {
	      lcl->ifc[i+MAX_DBBC_PFB]=i+1;
	      strncpy(lcl->lwhat[i+MAX_DBBC_PFB],lwhati[i],3);
	    }
	  }
	}
      }else if (shm_addr->equip.rack==DBBC3) {
	for (i=0;i<2*MAX_DBBC3_BBC;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>MAX_DBBC3_IF)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0)
	      lcl->itpis[2*MAX_DBBC3_BBC+lcl->ifc[i]-1]=1;
	    strncpy(lcl->lwhat[i],lwhat3[i],4);
	  }
	for (i=2*MAX_DBBC3_BBC;i<2*MAX_DBBC3_BBC+MAX_DBBC3_IF;i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-(2*MAX_DBBC3_BBC-1);
	    strncpy(lcl->lwhat[i],lwhat3[i],4);
	  }
      }

      /*
      for(i=0;i<MAX_DET;i++)
	if(lcl->itpis[i]!=0)
	  printf("i %d lcl->itpis[i] %d lcl->ifc[i] %d lcl->lwhat[i] %4.4s\n",
		 i,lcl->itpis[i],lcl->ifc[i],lcl->lwhat[i]);
      */
      *count=-1;
       break;
    }
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void tpicd_enc(output,count,lcl)
char *output;
int *count;
struct tpicd_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;

  output=output+strlen(output);

  if(*count == 1) {
    ivalue=lcl->continuous;
    if (ivalue >=0 && ivalue <CONT_KEY)
      strcat(output,cont_key[ivalue]);
    else
      strcat(output,BAD_VALUE);
    strcat(output,",");

    sprintf(output+strlen(output),"%d",lcl->cycle);
    goto end;
  }
  if(*count >= 2 && *count <=11 ) {
    for(j=*count-2;j<9;j++) {
      *count=j+2;
      if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||
	 shm_addr->equip.rack==LBA4) {
	sprintf(output+strlen(output),"%c",chanm[j]);
	limit=17;
      }else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	sprintf(output+strlen(output),"%c",chanv[j]);
	limit=MAX_DET;
      }else if (shm_addr->equip.rack==LBA) {
	sprintf(output+strlen(output),"%c",chanl[j]);
	limit=2*shm_addr->n_das;
      }else if (shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_DDC ||
		 shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
		) {
	sprintf(output+strlen(output),"%c",chanv[j]);
	limit=MAX_DBBC_DET;
      }else if (shm_addr->equip.rack==DBBC && 
		(shm_addr->equip.rack_type == DBBC_PFB ||
		 shm_addr->equip.rack_type == DBBC_PFB_FILA10G)
		) {
	sprintf(output+strlen(output),"%c",chanv[j]);
	limit=MAX_DBBC_PFB_DET;
      }else if (shm_addr->equip.rack==RDBE) {
	limit=0; /* we always do all */
      }else if (shm_addr->equip.rack==DBBC3) {
	sprintf(output+strlen(output),"%c",chan3[j]);
	limit=MAX_DBBC3_DET;
      }
      lenstart=strlen(output);

      for (k=0;k<limit;k++) {
	if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||
	   shm_addr->equip.rack==LBA4) {
	  i=k;
	}else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	  if(k<2*MAX_BBC)
	    i=MAX_BBC*(k%2)+k/2;
	  else
	    i=k;
	}else if (shm_addr->equip.rack==LBA) {
	  i=k;
	}else if (shm_addr->equip.rack==DBBC && 
		  (shm_addr->equip.rack_type == DBBC_DDC ||
		   shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
		  ) {
	  if(k<2*MAX_DBBC_BBC)
	    i=MAX_DBBC_BBC*(k%2)+k/2;
	  else
	    i=k;
	}else if (shm_addr->equip.rack==DBBC3) {
	  if(k<2*MAX_DBBC3_BBC)
	    i=MAX_DBBC3_BBC*(k%2)+k/2;
	  else
	    i=k;
	}else if (shm_addr->equip.rack==DBBC && 
		  (shm_addr->equip.rack_type == DBBC_PFB ||
		   shm_addr->equip.rack_type == DBBC_PFB_FILA10G)
		  ) {
	  i=k;
	}
	if(lcl->itpis[i]!=0 && lcl->ifc[i]==j) {
	  int len;
	  strcat(output,",");
	  len=strlen(output);
	  if (shm_addr->equip.rack==DBBC && 
	      (shm_addr->equip.rack_type == DBBC_PFB ||
	       shm_addr->equip.rack_type == DBBC_PFB_FILA10G))
	    strncat(output,lcl->lwhat[i],3);
	  else {
	    strncat(output,lcl->lwhat[i],2);
	    output[len+2]=0;
	  }
	  if(shm_addr->equip.rack!=DBBC3) {
	    strncat(output,lcl->lwhat[i],2);
	    output[len+2]=0;
	  } else {
	    strncat(output,lcl->lwhat[i],4);
	    output[len+4]=0;
          }	
	}
      }
      if(output[lenstart]!=0 ) {
	goto end;
      }
      output[lenstart-1]=0;
    }
    *count=-1;
  }
 end:
  return;
}
