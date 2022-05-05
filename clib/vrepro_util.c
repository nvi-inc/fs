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
/* ifd vlba dist buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */
                                              /* parameter keywords */
static char *key_mode[ ]={ "read", "byp" };
static char *key_equ [ ]={ "std", "alt1", "alt2", "dis"};
static char *key_equ0[ ]={ "160", "135", "270"};
static char *key_equ1[ ]={ "160", "80", "270"};
static char *key_equ2[ ]={ "135", "270"};
static char *key_equ3[ ]={ "0", "1", "2", "3"};

static char *key_bitsynch[ ] = { "16", "8", "4", "2", "1", "0.5"};

                                     /* number of elements in keyword arrays */
#define NKEY_MODE      sizeof(key_mode)/sizeof( char *)
#define NKEY_EQU       sizeof(key_equ)/sizeof( char *)
#define NKEY_EQU0      sizeof(key_equ0)/sizeof( char *)
#define NKEY_EQU1      sizeof(key_equ1)/sizeof( char *)
#define NKEY_EQU2      sizeof(key_equ2)/sizeof( char *)
#define NKEY_EQU3      sizeof(key_equ3)/sizeof( char *)
#define NKEY_BITSYNCH  sizeof(key_bitsynch)/sizeof( char *)

int vrepro_dec(lcl,count,ptr,indx)
struct vrepro_cmd *lcl;
int *count,indx;
char *ptr;
{
    int ierr, ind, arg_key(), idflt, odd, even;

    ierr=0;
    if(ptr == NULL) ptr="";

    idflt=-1;
    switch (*count) {
      case 1:
        idflt=1;                                /* modeA default byp */
      case 4:
        ind=(*count-1)/2;
        if( 0==strcmp(ptr,"raw")) ptr="read";   /* raw == read */
        if(idflt==-1) idflt=lcl->mode[0];        /* modeB defaults to modeA */
        ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode[ind],idflt,TRUE);
        break;
      case 2:
      case 3:
        ind=(*count-1)/2;
        ierr=arg_int(ptr,&lcl->track[ind],4,TRUE);
        if(ierr ==0 && (lcl->track[ind]>35 || lcl->track[ind]<0))
	  if (shm_addr->equip.drive[indx] == VLBA && !
	      (shm_addr->equip.drive[indx]==VLBA &&
	       shm_addr->equip.drive_type[indx]==VLBAB))
	    ierr=-200;
	  else if ((shm_addr->equip.drive[indx] == VLBA4 ||
		    (shm_addr->equip.drive[indx] == VLBA &&
		    shm_addr->equip.drive_type[indx] == VLBAB))&&
		   (lcl->track[ind]>135 || lcl->track[ind]<100))
	    ierr=-200;
	if(lcl->track[ind]<100)
	  lcl->head[ind]=1;
	else
	  lcl->head[ind]=2;

	lcl->track[ind]%=100;
        break;
      case 5:
        idflt=1;                               /* alt1 is default */
	if(lcl->mode[0]==1)
	  idflt=3;
	else if ((shm_addr->equip.drive[indx] == VLBA &&
		  shm_addr->equip.drive_type[indx] == VLBA2)||
		 (shm_addr->equip.drive[indx] == VLBA4 &&
		  shm_addr->equip.drive_type[indx] == VLBA42))
	  idflt=0;                         /* standard is default for VLBA2 */
      case 6:
        ind=*count-5;
        if(idflt==-1) idflt=lcl->equalizer[0];      /* equB defaults to equA */
        ierr=arg_key(ptr,key_equ3,NKEY_EQU3,&lcl->equalizer[ind],idflt,FALSE);
	if(ierr!=0) {
	  ierr=arg_key(ptr,key_equ,NKEY_EQU,&lcl->equalizer[ind],idflt,TRUE);
	  if(ierr!=0 && ((shm_addr->equip.drive[indx] == VLBA &&
			  shm_addr->equip.drive_type[indx] == VLBA2)||
			 (shm_addr->equip.drive[indx] == VLBA4 &&
			  shm_addr->equip.drive_type[indx] == VLBA42)))
	    ierr=arg_key(ptr,key_equ2,NKEY_EQU2,&lcl->equalizer[ind],idflt,TRUE);
	  else if(ierr !=0 &&!((shm_addr->equip.drive[indx] == VLBA &&
			       shm_addr->equip.drive_type[indx] == VLBA2)||
			       (shm_addr->equip.drive[indx] == VLBA4 &&
				shm_addr->equip.drive_type[indx] == VLBA42))) {
	    ierr=arg_key(ptr,key_equ0,NKEY_EQU0,&lcl->equalizer[ind],idflt,TRUE);
	    if(ierr!=0)
	      ierr=
		arg_key(ptr,key_equ1,NKEY_EQU1,&lcl->equalizer[ind],idflt,TRUE);
	  }
	}
        break;
      case 7:
	idflt=2; /* single speed */
	if (!((shm_addr->equip.drive[indx] == VLBA &&
	       shm_addr->equip.drive_type[indx] == VLBA2)||
	      (shm_addr->equip.drive[indx] == VLBA4 &&
	       shm_addr->equip.drive_type[indx] == VLBA42))) {
	  if (lcl->equalizer[0]==0 || lcl->equalizer[0]==2 ||
	      lcl->equalizer[1]==0 || lcl->equalizer[1]==2)
	    idflt=1;
	  else if(lcl->equalizer[0]==1 || lcl->equalizer[1]==1)
	    idflt=2;
	} else { /* VLBA2 */
	  if(lcl->equalizer[0]==0|| lcl->equalizer[1]==0)
	    idflt=2;
	  else if (lcl->equalizer[0]==1||lcl->equalizer[1]==1)
	    idflt=1;
	}
        ierr=arg_key(ptr,key_bitsynch,NKEY_BITSYNCH,&lcl->bitsynch,idflt,TRUE);
	break;
      default:
	if (shm_addr->wrhd_fs[indx] != 0) { /* fix odd of evenness of tracks */
	  odd = (lcl->track[0]%2 == 1 && lcl->head[0] == 1) || 
	    (lcl->track[1]%2 == 1 && lcl->head[1] == 1);
	  even= (lcl->track[0]%2 == 0 && lcl->head[0] == 1) ||
	    (lcl->track[1]%2 == 0 && lcl->head[1] == 1);
	  if (shm_addr->wrhd_fs[indx] == 1 && even && !odd) {
	    if(lcl->head[0] == 1)
	      lcl->track[0]++;
	    if(lcl->head[1] == 1)
	      lcl->track[1]++;
	  } else if (shm_addr->wrhd_fs[indx] == 2 && odd && !even) {
	    if(lcl->head[0] == 1)
	      lcl->track[0]--;
	    if(lcl->head[1] == 1)
	      lcl->track[1]--;
	  }
	}
	*count=-1;
      }
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void vrepro_enc(output,count,lcl)
char *output;
int *count;
struct vrepro_cmd *lcl;
{
    int ind, ivalue, ivalue2;

    output=output+strlen(output);

    switch (*count) {
      case 1:
      case 4:
        ind=(*count-1)/2;
        ivalue=lcl->mode[ ind];
        if(ivalue>=0 && ivalue <NKEY_MODE )
          strcpy(output,key_mode[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
      case 3:
        ind=(*count-1)/2;
        ivalue=lcl->track[ind];
	ivalue2=lcl->head[ind]-1;
        if(1 || ivalue > -1 && ivalue < 36 && (ivalue2 & 0x1 == ivalue2))
           sprintf(output,"%d",ivalue2*100+ivalue);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
      case 6:
        ind=*count-5;
        ivalue=lcl->equalizer[ ind];
        if(ivalue>=0 && ivalue <NKEY_EQU3 )
          strcpy(output,key_equ3[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 7:
	ivalue=lcl->bitsynch;
        if(ivalue>=0 && ivalue <NKEY_BITSYNCH )
          strcpy(output,key_bitsynch[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
	*count=-1;
   }
   if(*count>0) *count++;
   return;
}

void vrepro90mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{

   *data= bits16on(6) & lcl->track[ 0];

   return;
}

void vrepro91mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{

   *data= bits16on(6) & lcl->track[ 1];

   return;
}
void vrepro92mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{

   *data= bits16on(6) & lcl->track[ 0];

   return;
}

void vrepro93mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{

   *data= bits16on(6) & lcl->track[ 1];

   return;
}

void vrepro94mc(data,lcl,indx)
unsigned *data;
struct vrepro_cmd *lcl;
int indx;
{
  int idflt;

  if(lcl->equalizer[ 0] >= 4 ) {
    if ((shm_addr->equip.drive[indx] == VLBA &&
	 shm_addr->equip.drive_type[indx] == VLBA2)||
	(shm_addr->equip.drive[indx] == VLBA4 &&
	 shm_addr->equip.drive_type[indx] == VLBA42))
      idflt=0;  /* standard is default for VLBA2 */
    else
      idflt=1; /* alt.1 is default for VLBA */
  } else
    idflt=lcl->equalizer[ 0];
      
  *data= (bits16on(2) & idflt);
  
  return;
}

void vrepro95mc(data,lcl,indx)
unsigned *data;
struct vrepro_cmd *lcl;
int indx;
{
  int idflt;

  if(lcl->equalizer[ 1] >= 4 ) {
    if ((shm_addr->equip.drive[indx] == VLBA &&
	 shm_addr->equip.drive_type[indx] == VLBA2)||
	(shm_addr->equip.drive[indx] == VLBA4 &&
	 shm_addr->equip.drive_type[indx] == VLBA42))
      idflt=0;  /* standard is default for VLBA2 */
    else
      idflt=1; /* alt.1 is default for VLBA */
  } else
    idflt=lcl->equalizer[ 1];

  *data= (bits16on(2) & idflt);

     return;
}
void vrepro96mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
  int idflt;

  if(lcl->equalizer[ 0] >= 4 ) {
    idflt=1; /* alt.1 is default for VLBA */
  } else
    idflt=lcl->equalizer[ 0];
      
  *data= (bits16on(2) & idflt);
  
  return;
}

void vrepro97mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
  int idflt;

  if(lcl->equalizer[ 1] >= 4 ) {
    idflt=1; /* alt.1 is default for VLBA */
  } else
    idflt=lcl->equalizer[ 1];

  *data= (bits16on(2) & idflt);

     return;
}

void vrepro98mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/* hardcoded reproduce channel A to formatter output channel A, for now */

  if(lcl->head[0] == 1)
     *data= (bits16on(1) & lcl->mode[ 0]);
  else
     *data= 0x4 | (bits16on(1) & lcl->mode[ 0]);

     return;
}

void vrepro99mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/* hardcoded reproduce channel B to formatter output channel B, for now */

  if(lcl->head[1] == 1)
     *data=  0x2 | (bits16on(1) & lcl->mode[ 1]); 
  else
     *data=  0x6 | (bits16on(1) & lcl->mode[ 1]); 

  return;
}

void vrepro9cmc_vlba2(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/*VLBA2 drive requires uses 9c to select something to do with repro/raw */

     *data=  (bits16on(1) & lcl->mode[ 0]); 

     return;
}

void vreproa8mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
  switch (lcl->bitsynch) {
  case 0:
    *data=0x14;
    break;
  case 1:
    *data=0x24;
    break;
  case 2:
    *data=0x34;
    break;
  case 3:
    *data=0x44;
    break;
  case 4:
    *data=0x54;
    break;
  case 5:
    *data=0x64;
    break;
  default:
    *data=0x34;
  }

  return;
}


void mc90vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{

       lcl->track[ 0] =  data & bits16on(6);

       return;
}

void mc91vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{

       lcl->track[ 1] =  data & bits16on(6);

       return;
}
void mc92vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{

       lcl->track[ 0] =  data & bits16on(6);

       return;
}

void mc93vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{

       lcl->track[ 1] =  data & bits16on(6);

       return;
}

void mc94vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
       lcl->equalizer[ 0] =  data & bits16on(2);

       return;
}

void mc95vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
       lcl->equalizer[ 1] =  data & bits16on(2);

       return;
}

void mc96vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
       lcl->equalizer[ 0] =  data & bits16on(2);

       return;
}

void mc97vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
       lcl->equalizer[ 1] =  data & bits16on(2);

       return;
}

void mc98vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* only allow head output A to formatter output A, for now */

       lcl->mode[ 0] =  data & bits16on(2);

       if(lcl->mode[ 0] != 0 && lcl->mode[ 0] != 1)
	 lcl->mode[ 0]=-1;

       lcl->head[0]= 1 + ((data >> 2) & 0x1);

       return;
}

void mc99vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* only allow head output B to formatter output B, for now */

       lcl->mode[ 1] =  data & bits16on(2);
       if(lcl->mode[ 1] != 2 && lcl->mode[ 1] != 3)
	 lcl->mode[ 1]=-1;
       else
	 lcl->mode[ 1]-=2;

       lcl->head[1]= 1 + ((data >> 2) & 0x1);

       return;
}
void mca8vrepro(lcl,data)
struct vrepro_cmd *lcl;
unsigned data;
{
  if(0xF && data != 0x4)
    lcl->bitsynch=-1;

    lcl->bitsynch= (data >>4)-1;

  return;
}
