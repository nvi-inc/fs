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
#include <string.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int if_cmd(ibuf,nchar)
     char *ibuf,*nchar;
{
  char *ptr, *ptr_cond, *ptr_true, *ptr_false, ifchar;
  int ddc,pfb,itpis_test[MAX_DBBC_PFB_DET], i, ibbc, ifc, ic;
  int dbbc3;
  char ifs[ ]={"abcd"};

  ptr=memchr(ibuf,'=',*nchar);
  if(NULL==ptr)
    return -1;   /* no equals */

  /* find condition */

  ptr_cond="";
  if(0!=*++ptr && ','!=*ptr) {
    while (' '==*ptr && 0!=*++ptr ) /* remove leading blanks */
      ;
    if(0!=*ptr) {
      ptr_cond=ptr;
      while (0!=*++ptr && ','!=*ptr) {
	if('\\'==*ptr) {            /* '\' is escape character */
	  char *to,*from;
	  for(to=ptr,from=ptr+1;0!=*from;to++,from++) 
	    *to=*from;
	  *to=0;
	}
      }
    }
  }

  ptr_true="";
  if(0!=*ptr) {
    *ptr=0;       /* terminate condition */
    while(' '==ptr_cond[strlen(ptr_cond)-1]) /* remove trailing blanks */
      ptr_cond[strlen(ptr_cond)-1]=0;

    for(i=0;i<strlen(ptr_cond);i++) /* condition is cass insensitive */
      ptr_cond[i]=tolower(ptr_cond[i]);

    while (0!=*++ptr && ' '==*ptr) /* remove leading blanks */
      ;

    if(0!=*ptr && ','!=*ptr) {
      ptr_true=ptr;
      while (0!=*++ptr && ','!=*ptr) {
	if('\\'==*ptr) {            /* '\' is escape character */
	  char *to,*from;
	  for(to=ptr,from=ptr+1;0!=*from;to++,from++) 
	    *to=*from;
	  *to=0;
	}
      }
    }
  }

  ptr_false="";
  if(0!=*ptr) {
    *ptr=0;       /* terminate true-command */
    while (0!=*++ptr && ' '==*ptr) /* remove leading blanks */
      ;
    if(0!=*ptr && ','!=*ptr) {
      ptr_false=ptr;
      while (0!=*++ptr && ','!=*ptr) {
	if('\\'==*ptr) {            /* '\' is escape character */
	  char *to,*from;
	  for(to=ptr,from=ptr+1;0!=*from;to++,from++) 
	    *to=*from;
	  *to=0;
	}
      }
    }
  }

  ddc=shm_addr->equip.rack==DBBC && 
    (shm_addr->equip.rack_type == DBBC_DDC ||
     shm_addr->equip.rack_type == DBBC_DDC_FILA10G);
     
  pfb=shm_addr->equip.rack==DBBC && 
    (shm_addr->equip.rack_type == DBBC_PFB ||
     shm_addr->equip.rack_type == DBBC_PFB_FILA10G);

  dbbc3=shm_addr->equip.rack==DBBC3;

  for(i=0;i<MAX_DBBC_PFB_DET;i++)
    itpis_test[i]=0;

  if(shm_addr->equip.drive[0]==MK5 &&
     (shm_addr->equip.drive_type[0]==MK5B ||
      shm_addr->equip.drive_type[0]==MK5B_BS ||
      shm_addr->equip.drive_type[0]==MK5C ||
      shm_addr->equip.drive_type[0]==MK5C_BS ||
      shm_addr->equip.drive_type[0]==FLEXBUFF) )
    if(ddc) {
      mk5dbbcd(itpis_test); 
    } else if(pfb)
      mk5dbbcd_pfb(itpis_test);
  
  if(0!=*ptr)
    *ptr=0;      /* terminate false-command */

  if(!strlen(ptr_cond))
    return -2;    /* no condition */

  if(!strcmp("true",ptr_cond))
    strcpy(ibuf,ptr_true);

  else if(!strcmp("false",ptr_cond))
    strcpy(ibuf,ptr_false);

  else if(!strcmp("ddc",ptr_cond))
    if(ddc)
      strcpy(ibuf,ptr_true);
    else
      strcpy(ibuf,ptr_false);

  else if(!strcmp("pfb",ptr_cond))
    if(pfb)
      strcpy(ibuf,ptr_true);
    else
      strcpy(ibuf,ptr_false);

  else if(!strcmp("cont_cal",ptr_cond))
    if((ddc||pfb) && 1==shm_addr->dbbc_cont_cal.mode
            || dbbc3 && 1==shm_addr->dbbc3_cont_cal.mode)
      strcpy(ibuf,ptr_true);
    else
      strcpy(ibuf,ptr_false);      

  else if(1==sscanf(ptr_cond,"bbc%2d",&ibbc) && strlen(ptr_cond)==5 &&
	  ibbc >= 1 &&  ibbc <= MAX_DBBC_BBC &&
	  strchr("01",ptr_cond[3]) && strchr("0123456789",ptr_cond[4]))
    if(ddc)
      if(itpis_test[-1+ibbc] || itpis_test[-1+ibbc+MAX_DBBC_BBC])
	strcpy(ibuf,ptr_true);
      else
	strcpy(ibuf,ptr_false);
    else
	strcpy(ibuf,ptr_false);

  else if(1==sscanf(ptr_cond,"if%1c",&ifchar) && strlen(ptr_cond)==3 &&
	  NULL!=strchr(ifs,ifchar)) {
    ifc=strchr(ifs,ifchar)-ifs;
    if(ddc) {
      for(i=0;i<MAX_DBBC_BBC;i++)
	if((itpis_test[i] || itpis_test[i+MAX_DBBC_BBC]) &&
	   shm_addr->dbbcnn[i].source==ifc){
	  strcpy(ibuf,ptr_true);
	  break;
	}
      if(i>=MAX_DBBC_BBC)
	strcpy(ibuf,ptr_false);
    } else if(pfb) {
      int icore=0;
      int true=0;
      int j,k,ik;
      for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	if(ifc >= i)
	  for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	    icore++;
	    if(ifc==i) {
	      for(k=1;k<16;k++) {
		ik=k+(icore-1)*16;
		if(itpis_test[ik]==1) {
		  true=1;
		  break;
		}
	      }
	    }
	  }
      }
      if(true)
	strcpy(ibuf,ptr_true);
      else
	strcpy(ibuf,ptr_false);	
    } else
      strcpy(ibuf,ptr_false);

  } else if(1==sscanf(ptr_cond,"core%1d",&ic) && strlen(ptr_cond)==5 &&
	  ic >= 1 &&  ic <= 4)
    if(pfb) {
      for(i=0;i<16;i++)
	if(itpis_test[(ic-1)*16+i]==1) {
	  strcpy(ibuf,ptr_true);
	  break;
	}
      if(i>=16)
	strcpy(ibuf,ptr_false);
    } else if(ddc) {
      for(i=0;i<4;i++) {
	if(itpis_test[(ic-1)*4+i]==1||itpis_test[(ic-1)*4+i+MAX_DBBC_BBC]==1) {
	  strcpy(ibuf,ptr_true);
	  break;
	}
      }
      if(i>=4)
	strcpy(ibuf,ptr_false);
    } else
      strcpy(ibuf,ptr_false);

  else if(!strncmp("schedule",ptr_cond,strlen("schedule"))) {
    char *ptr, *ptr2;

    ptr=strtok(ptr_cond,":");
    if(NULL!=ptr)
      ptr2=strtok(NULL,":");
    if(NULL==ptr || NULL==ptr2)
      if(!strncmp(shm_addr->LSKD,"none    ",8))
	strcpy(ibuf,ptr_false);
      else
	strcpy(ibuf,ptr_true);
    else
      if(!strncmp(shm_addr->LSKD,ptr2,strlen(ptr2)))
	strcpy(ibuf,ptr_true);
      else
	strcpy(ibuf,ptr_false);
  } else 
    return -3;  /*unknown condition*/

  return(strlen(ibuf));

}
