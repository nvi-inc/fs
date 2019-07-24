/* ifd vlba dist buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/dist_ds.h"

                                             /* parameter keywords */
static char *key_att[ ]={ "0", "20" };
static char *key_inp[ ]={ "nor", "ext" };
static char *key_avg[ ]={ "0","1","2","4","10","20","40","60"};

                                            /* number of elem. keyword arrays */
#define NKEY_ATT sizeof(key_att)/sizeof( char *)
#define NKEY_INP sizeof(key_inp)/sizeof( char *)
#define NKEY_AVG sizeof(key_avg)/sizeof( char *)

int dist_dec(lcl,count,ptr)
struct dist_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
      case 2:
        ind=*count-1;
        if( 0==strcmp(ptr,"old"))
           lcl->atten[ind]=lcl->old[ind];
        else if( 0==strcmp(ptr,"max"))
           lcl->atten[ind]=1;
        else
           ierr=arg_key(ptr,key_att,NKEY_ATT,&lcl->atten[ind],0,TRUE);
        break;
      case 3:
      case 4:
        ind=*count-3;
        ierr=arg_key(ptr,key_inp,NKEY_INP,&lcl->input[ind],0,TRUE);
        break;
      case 5:
        ierr=arg_key(ptr,key_avg,NKEY_AVG,&lcl->avper,1,TRUE);
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dist_enc(output,count,lcl)
char *output;
int *count;
struct dist_cmd *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
      case 2:
        ind=*count-1;
        ivalue=lcl->atten[ ind];
        if(ivalue>=0 && ivalue <NKEY_ATT)
          strcpy(output,key_att[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
      case 4:
        ind=*count-3;
        ivalue=lcl->input[ ind];
        if(ivalue>=0 && ivalue <NKEY_INP )
          strcpy(output,key_inp[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
        ivalue=lcl->avper;
        if(ivalue>=0 && ivalue <NKEY_AVG )
          strcpy(output,key_avg[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}

void dist_mon(output,count,lcl)
char *output;
int *count;
struct dist_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
      case 2:
        ind=*count-1;
        sprintf(output,"%u",0xFFFF & lcl->totpwr[ind]);
        break;
      case 3:
        sprintf(output,"%d",0xFFF & lcl->serial);
        break;
      case 4:
        if(lcl->timing==0) strcpy(output,"no_1pps");
        else if(lcl->timing==1) strcpy(output,"1pps");
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void dist01mc(data,lcl)
unsigned *data;
struct dist_cmd *lcl;
{
   *data=
         ( (0x1 & lcl->atten[ 1]) <<  1 ) | 
         ( (0x1 & lcl->input[ 1]) <<  2 ) |
         ( (0x1 & lcl->atten[ 0]) <<  9 ) | 
         ( (0x1 & lcl->input[ 0]) << 10 );

       return;
}

void dist02mc(data,lcl)
unsigned *data;
struct dist_cmd *lcl;
{
     *data=
         ( (0x7 & lcl->avper) << 12 );

       return;
}

void mc01dist(lcl, data)
struct dist_cmd *lcl;
unsigned data;
{
       lcl->atten[ 1] = ( data >>  1 ) & 0x01;
       lcl->input[ 1] = ( data >>  2 ) & 0x01;
       lcl->atten[ 0] = ( data >>  9 ) & 0x01;
       lcl->input[ 0] = ( data >> 10 ) & 0x01;

       return;
}

void mc02dist(lcl, data)
struct dist_cmd *lcl;
unsigned data;
{
       lcl->avper = ( data >> 12 ) & 0x7;

       return;
}

void mc04dist(lcl, data)
struct dist_mon *lcl;
unsigned data;
{
      lcl->serial = ( data >>  0 ) & 0xFFF;
      lcl->timing = ( data >> 12 ) & 0x1;
      
      return;
}

void mc06dist(lcl, data)
struct dist_mon *lcl;
unsigned data;
{
       lcl->totpwr[ 0] = ( data >>  0)  &0xFFFF;

       return;
}

void mc07dist(lcl, data)
struct dist_mon *lcl;
unsigned data;
{
       lcl->totpwr[ 1] = ( data >>  0)  &0xFFFF;

       return;
}
