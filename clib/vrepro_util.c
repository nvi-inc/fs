/* ifd vlba dist buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/vrepro_ds.h"
#include "../include/macro.h"

                                              /* parameter keywords */
static char *key_mode[ ]={ "read", "byp" };
static char *key_equ[ ]={ "std", "alt1", "alt2" };

                                     /* number of elements in keyword arrays */
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_EQU  sizeof(key_equ)/sizeof( char *)

int vrepro_dec(lcl,count,ptr)
struct vrepro_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(), idflt;

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
        ierr=arg_int(ptr,&lcl->track[ind],1,TRUE);
        if(ierr ==0 && (lcl->track[ind]>28 || lcl->track[ind]<1)) ierr=-200;
        break;
      case 5:
        idflt=1;                               /* alt1 is default */
      case 6:
        ind=*count-5;
        if(idflt==-1) idflt=lcl->equalizer[0];      /* equB defaults to equA */
        ierr=arg_key(ptr,key_equ,NKEY_EQU,&lcl->equalizer[ind],idflt,TRUE);
        break;
      default:
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
    int ind, ivalue;

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
        if(ivalue > 0 && ivalue < 29 )
           sprintf(output,"%d",lcl->track[ind]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
      case 6:
        ind=*count-5;
        ivalue=lcl->equalizer[ ind];
        if(ivalue>=0 && ivalue <NKEY_EQU )
          strcpy(output,key_equ[ivalue]);
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
/* VLBA rec track number = Mk3 track number + 3 */

   *data= bits16on(6) & (lcl->track[ 0]+3);

   return;
}

void vrepro91mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/* VLBA rec track number = Mk3 track number + 3 */

   *data= bits16on(6) & (lcl->track[ 1]+3);

   return;
}

void vrepro94mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
     *data= (bits16on(2) & lcl->equalizer[ 0]);

     return;
}

void vreproa8mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
     *data= 0x24;  /* double speed */
     if (lcl->equalizer[ 0] == 1) 
          *data= 0x34;   /* normal speed */

     return;
}

void vrepro95mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
     *data= (bits16on(2) & lcl->equalizer[ 1]);

     return;
}

void vrepro98mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/* hardcoded reproduce channel A to formatter output channel A, for now */

     *data= (bits16on(1) & lcl->mode[ 0]);

     return;
}

void vrepro99mc(data,lcl)
unsigned *data;
struct vrepro_cmd *lcl;
{
/* hardcoded reproduce channel B to formatter output channel B, for now */

     *data=  0x2 | (bits16on(1) & lcl->mode[ 1]); 

     return;
}

void mc90vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* Mk3 track number = VLBA rec track number - 3 */

       lcl->track[ 0] =  (data & bits16on(6))-3;

       return;
}

void mc91vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* Mk3 track number = VLBA rec track number - 3 */

       lcl->track[ 1] =  (data & bits16on(6))-3;

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

void mc98vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* only allow head output A to formatter output A, for now */

       lcl->mode[ 0] =  data & bits16on(3);
       if(lcl->mode[ 0] != 0 && lcl->mode[ 0] != 1) lcl->mode[ 0]=-1;

       return;
}

void mc99vrepro(lcl, data)
struct vrepro_cmd *lcl;
unsigned data;
{
/* only allow head output B to formatter output B, for now */

       lcl->mode[ 1] =  data & bits16on(3);
       if(lcl->mode[ 1] != 2 && lcl->mode[ 1] != 3) lcl->mode[ 1]=-1;
       else lcl->mode[ 1]-=2;

       return;
}
