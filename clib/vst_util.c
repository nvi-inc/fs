/* vlba vst buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/vst_ds.h"

static char *sp1_key[ ]={"0","3.375","7.875","16.875","33.75","67.5","135",
                         "270"};
static char *sp2_key[ ]={"0","3",    "7",    "15",    "30",   "60",  "120",
                         "240"};
static float sp3_key[ ]={0,   3.375,  7.875,  16.875,  33.75,  67.5,  135., 
                          270.};
static char *dir_key[ ]={ "rev","for"};
static char *rec_key[ ]={ "off","on"};

#define SP1_KEY sizeof(sp1_key)/sizeof( char *)
#define SP2_KEY sizeof(sp2_key)/sizeof( char *)
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
        ierr=arg_key(ptr,sp1_key,SP1_KEY,&lcl->speed,0,FALSE);
        if (ierr !=0) {
          ierr=0;
          ierr=arg_key_flt(ptr,sp2_key,SP2_KEY,&lcl->speed,0,FALSE);
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

  *data = (bits16on(16) &  (int)(sp3_key[lcl->speed]*100.0));

       return;

}

void mcb5vst(lcl, data)
struct vst_cmd *lcl;
unsigned data;
{
int ivalue;
int i;
  
   ivalue = ( data >>  0 ) & bits16on(16);
   if (ivalue == 0x80e8)   /* speed is 330 */
     lcl->speed = -1;
   else if (ivalue == 0x8ca0)   /* speed is 360 */
     lcl->speed = -2;
   else {
     for (i=0;i< SP1_KEY;i++) {
       if (( fabs ((double)((float)ivalue/100) - sp3_key[i])) < 1e-5)
         lcl->speed=i;
     }
   }
  return;

}

void mcb1vst(lcl, data)
struct vst_cmd *lcl;
unsigned data;
{

       lcl->dir = ( data >>  0 ) & bits16on(1);
       return;
}
