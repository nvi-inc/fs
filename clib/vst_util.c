/* vlba vst buffer parsing utilities */

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

/*true speeds*/
static char *sp1_key[ ]={
        "8.44", "16.88", "33.75", "67.5", "135",    "270",
   "0", "8.33", "16.66", "33.33", "66.66", "133.33", "266.66",
        "5",    "10",    "20",    "40",    "80",    "160" };
/* nominal M3 speeds that are different */
static char *sp2_key[ ]={"7.5",    "15",    "30",   "60",   "120",
			   "240"};
/* speeds in 0.01 ips */
static int   sp3_key[ ]={
       844,    1688,   3375,    6750,   13500,  27000,
  0,   833,    1666,   3333,    6666,   13333,  26666,
       500,    1000,   2000,    4000,    8000,  16000};
/*true M3 speeds that are different */
static char *sp4_key[ ]={"8.4375","16.875"};
static char *sp5_key[ ]={"7"};
static char *sp6_key[ ]={"7.88"};
static char *sp7_key[ ]={"7.875"};
static char *dir_key[ ]={"rev","for"};
static char *rec_key[ ]={"off","on"};

#define SP1_KEY sizeof(sp1_key)/sizeof( char *)
#define SP2_KEY sizeof(sp2_key)/sizeof( char *)
#define SP3_KEY sizeof(sp3_key)/sizeof( char *)
#define SP4_KEY sizeof(sp4_key)/sizeof( char *)
#define SP5_KEY sizeof(sp5_key)/sizeof( char *)
#define SP6_KEY sizeof(sp6_key)/sizeof( char *)
#define SP7_KEY sizeof(sp7_key)/sizeof( char *)
#define DIR_KEY sizeof(dir_key)/sizeof( char *)
#define REC_KEY sizeof(rec_key)/sizeof( char *)

int vst_dec(lcl,count,ptr)
struct vst_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key();
    int arg_key_flt();
    int i;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,dir_key,DIR_KEY,&lcl->dir,0,FALSE);
        break;
      case 2:
	ierr=arg_key_flt(ptr,sp1_key,SP1_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0)
          ierr=arg_key_flt(ptr,sp2_key,SP2_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0)
          ierr=arg_key_flt(ptr,sp4_key,SP4_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0)
          ierr=arg_key_flt(ptr,sp5_key,SP5_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0)
          ierr=arg_key_flt(ptr,sp6_key,SP6_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0)
          ierr=arg_key_flt(ptr,sp7_key,SP7_KEY,&lcl->speed,0,FALSE);
	if (ierr==0) {
	  lcl->cips=sp3_key[lcl->speed];
	  lcl->speed=-3;
	} else if (ierr == -100 && (
		   (shm_addr->equip.rack == VLBA && 
		    shm_addr->bit_density > 0    &&
		    shm_addr->vform.tape_clock > 0) ||
				    (shm_addr->equip.rack == MK3 &&
				     shm_addr->iratfm > 0))){
	  lcl->speed=-3;
	  ierr = 0;
	  if (shm_addr->equip.rack == MK3) {
	    int idum;

	    idum=shm_addr->iratfm;
	    if(idum=0)
	      idum=8;
	    lcl->cips=100*((9e6/(1<<8-idum))/shm_addr->bit_density);
	  } else if (shm_addr->equip.rack == VLBA)
	    if (shm_addr->vform.tape_clock<8)
	      lcl->cips=100*((9.072e6/(1<<(0x7-shm_addr->vform.tape_clock)))/
			     shm_addr->bit_density); 
	    else
	      lcl->cips=100*((9e6/(1<<(0xf-shm_addr->vform.tape_clock)))/
			     shm_addr->bit_density);
	  }
        break;
      case 3:
        ierr=arg_key(ptr,rec_key,REC_KEY,&lcl->rec,1,TRUE);
        break;
      default:
       *count=-1;
      }

    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void vst_enc(output,count,lcl)
char *output;
int *count;
struct vst_cmd *lcl;
{
    int ind, ivalue, ivalue2;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue = lcl->dir;
        if (ivalue >=0 && ivalue <DIR_KEY)
          strcpy(output,dir_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
        ivalue = lcl->speed;
        if (ivalue == -1)
          strcpy(output,"330");
        else if (ivalue == -2)
          strcpy(output,"360");
	else if (ivalue == -3)
	  sprintf(output,"%d.%02d",lcl->cips/100,lcl->cips%100);
        else if (ivalue >=0 && ivalue <SP1_KEY)
          strcpy(output,sp1_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        ivalue = lcl->rec;
        if (ivalue >=0 && ivalue <REC_KEY)
          strcpy(output,rec_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        ind=*count;
        break;
      case 5:
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void vstb1mc(data,lcl)
unsigned *data;
struct vst_cmd *lcl;
{

  *data = (bits16on(1) & lcl->dir);

  return;
}

void vstb5mc(data,lcl)
unsigned *data;
struct vst_cmd *lcl;
{

  *data = bits16on(16) & (lcl->cips);

  return;

}

void mcb5vst(lcl, data)
struct vst_cmd *lcl;
unsigned data;
{
  int ivalue;
  int i;
  
  ivalue = ( data >>  0 ) & bits16on(16);


  lcl->speed = -3;
  lcl->cips = ivalue;

  return;

}

void mcb1vst(lcl, data)
struct vst_cmd *lcl;
unsigned data;
{

       lcl->dir = ( data >>  0 ) & bits16on(1);
       return;
}
