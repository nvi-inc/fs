/* vlba bbc buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/bbc_ds.h"

static char *if_key[ ]={ "a", "b", "c", "d" }; /* if input source */
/*static double bw_key[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0};*/
static char *bw_key[ ]={"0.0625","0.125","0.25","0.5","1","2","4","8","16","32"};
static int bwbits[ ]={ 0x00, 0x01, 0x02, 0x04, 0x08, 0x11, 0x24, 0x6f, 0xfb, 0xfc};
static int bwbitc[ ]={ 0x2b, 0x29, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80};
static char *gm_key[ ]={ "man","agc"};
static char *av_key[ ]={ "0","1","2","4","10","20","40","60"};/* av. period */

#define NIF_KEY sizeof(if_key)/sizeof( char *)
#define NBW_KEY sizeof(bw_key)/sizeof( char *)
#define NGM_KEY sizeof(gm_key)/sizeof( char *)
#define NAV_KEY sizeof(av_key)/sizeof( char *)

int bbc_dec(lcl,count,ptr)
struct bbc_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key();
    int arg_key_flt();
    double atof(), gain;
    int bblvcode();
    char buffer[80];
    int ilen, jlen, klen, mlen;
    char *decloc, *ctemp;
    int freq, ifreq, freq2bbc();
    int i;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        if(ptr == NULL || *ptr == '\0') {
          ierr=-100;
          break;
        }
        ctemp=buffer;
        for (i=0;i<80;i++)
          buffer[i]='\0';
        freq=0;
        ifreq=0;
        jlen=0;
        ilen = strlen(ptr);
        decloc = strchr(ptr,'.');
        if (decloc != NULL)
          jlen = strlen(decloc);

   /* no more than 2 digits in frcational part , don't count trailing spaces */

	mlen=jlen;
	while(mlen > 0 && *(decloc+mlen-1)==' ')
	  mlen--;
	if(mlen > 3) {
	  ierr=-200;
	  break;
	}

        if (ilen == jlen) 
          klen = ilen;
        else
          klen = ilen - jlen;
        
        if ((klen == ilen) && (jlen == 0))
          freq = atoi(ptr)*100;
        else {
          strncpy(ctemp,ptr,klen);
          freq = atoi(ctemp)*100;
          for (i=0;i<80;i++)
            buffer[i]='\0';
          if (decloc != NULL)
            decloc++;
          if (jlen > 1) {
            strncpy(ctemp,decloc,jlen-1);
            ifreq = atoi(ctemp);
           }
          if ((jlen == 2) && (ifreq < 10))
            ifreq = ifreq * 10;
        }
        freq = freq+ifreq;
        if (strcmp(ptr,"*")!=0)
          if ((freq < 45000) || (freq > 105000))
            ierr = -200;
          else
            lcl->freq = freq2bbc(freq);
        break;
      case 2:
        ierr=arg_key(ptr,if_key,NIF_KEY,&lcl->source,0,FALSE);
        break;
      case 3:
      case 4:
        ind=*count-3;
        if (ind==0)
          ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lcl->bw[ind],5,TRUE);
        else if (ind==1)
         ierr=arg_key_flt(ptr,bw_key,NBW_KEY,&lcl->bw[ind],lcl->bw[ind-1],TRUE);
        lcl->bwcomp[ind]=lcl->bw[ind];
        break;
      case 5:
        ierr=arg_key(ptr,av_key,NAV_KEY,&lcl->avper,1,TRUE);
        break;
      case 6:
        ierr=arg_key(ptr,gm_key,NGM_KEY,&lcl->gain.mode,1,TRUE);
        break;
      case 7:
      case 8:
/* the gain is only used when the gain mode is man */ 
        ind=*count-7;
        if (lcl->gain.mode==1) {
          *count=-1; /* values are legit only for manual mode */
        }
        else if (*ptr==0) {
          lcl->gain.value[ind]=-999; /* signal for default */
          break;
        }
        else {
          gain = atof(ptr);
          if ((gain < -18.0) || (gain > 12.0)) {
            if (gain < 0.0 ) {
              if ( (fabs(18.0 - fabs(gain))) > 1e-5)
                ierr=-200;
            }
            else if(gain > 0.0) {
              if ((fabs (12.0 - gain)) > 1e-5 )
                ierr=-200;
            }
          }
          else
            lcl->gain.value[ind] = bblvcode(gain);
        }
        break;
      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void bbc_enc(output,count,lcl)
char *output;
int *count;
struct bbc_cmd *lcl;
{
    int ind, ivalue, ivalue2;
    int bbc2freq(),freq;
    double bblvdB();

    output=output+strlen(output);

    switch (*count) {
      case 1:
        freq=bbc2freq(lcl->freq);
        sprintf(output,"%-06.2f",(float)freq/100);
        break;
      case 2:
        ivalue = lcl->source;
        if (ivalue >=0 && ivalue <NIF_KEY)
          strcpy(output,if_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
      case 4:
        ind=*count-3;
        ivalue = lcl->bw[ind];
        ivalue2 = lcl->bw[ind];
        if (ivalue >=0 && ivalue <NBW_KEY && ivalue == ivalue2)
          strcpy(output,bw_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 5:
        ivalue = lcl->avper;
        if (ivalue >=0 && ivalue <NAV_KEY)
          strcpy(output,av_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 6:
        ivalue = lcl->gain.mode;
        if (ivalue >=0 && ivalue <NGM_KEY)
          strcpy(output,gm_key[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 7:
      case 8:
        ind=*count-7;
/*        ulga = bblvdB(lcl->gain.value[ind]); */
        sprintf(output,"%6.2f",bblvdB(lcl->gain.value[ind]));
        break;
      default:
       *count=-1;
   }

   if(*count>0) *count++;
   return;
}

void bbc_mon(output,count,lcl)
char *output;
int *count;
struct bbc_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        if(lcl->lock==0) strcpy(output,"unlock");
        else if(lcl->lock==1) strcpy(output,"lock");
        break;
      case 2:
      case 3:
        ind=*count-2;
        sprintf(output,"%5u",0xFFFF & lcl->pwr[ind]);
        break;
      case 4:
        sprintf(output,"%d",0xFFF & lcl->serno);
        break;
      case 5:
        if(lcl->timing==0) strcpy(output,"no_1pps");
        else if(lcl->timing==1) strcpy(output,"1pps");
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void bbc00mc(data,lcl)
unsigned *data;
struct bbc_cmd *lcl;

{

/* USB uses bits 8-15 */
/* LSB uses bits 0-7 */

  *data = ((bits16on(8) & bwbits[lcl->bw[0]]) << 8) | 
           (bits16on(8)  & bwbits[lcl->bw[1]]) ;

       return;
}

void bbc01mc(data,lcl)
unsigned *data;
struct bbc_cmd *lcl;

{
/* bandwidth gain compensation */

  *data = ((bits16on(8) & bwbitc[lcl->bwcomp[0]]) <<  8)
            | bwbitc[lcl->bwcomp[1]] ;

       return;

}

void bbc02mc(data,lcl)
unsigned *data;
struct bbc_cmd *lcl;

{
unsigned datatmp1, datatmp2, datatmp3, datatmp4;

/* LO frequency -most significant 4 bits, bit pos 0-3 */
/* IF input selection bit pos 6-7 */
/* manual gain control bit pos 8 */
/* averaging period selection, bit pos 12-14 */

  datatmp1 =  (bits16on(3) & lcl->avper) << 12;
  datatmp2 =  (bits16on(2) & lcl->source) << 6;
  datatmp3 =  (bits16on(1) & lcl->gain.mode) << 8;
  datatmp4 =  (lcl->freq>>16) & bits16on(4);
  *data = datatmp1 | datatmp2 | datatmp3 | datatmp4;

  return;

}

void bbc03mc(data,lcl)
unsigned *data;
struct bbc_cmd *lcl;

{

/* LO frequency along with word 02 */

  *data = lcl->freq & bits16on(16);

}

void bbc05mc(data,lcl)
unsigned *data;
struct bbc_cmd *lcl;

{

/* gain control */

}

void mc00bbc(lcl, data)
struct bbc_cmd *lcl;
unsigned data;
{
int ivalue;
int i;
  
  ivalue = ( data >>  0 ) & bits16on(8);
  i = 0;
  for (i=0; i< NBW_KEY; i++) {
    if (ivalue == bwbits[i]) {
      lcl->bw[1] =  i;
      break;
    }
    lcl->bw[1] = -1;
  }

  ivalue = ( data >>  8 ) & bits16on(8);
  i = 0;
  for (i=0; i< NBW_KEY;i++) {
    if (ivalue == bwbits[i]) {
      lcl->bw[0] =  i;
      break;
    }
    lcl->bw[0] = -1;
  }

  return;

}

void mc01bbc(lcl, data)
struct bbc_cmd *lcl;
unsigned data;
{
int i;
int ivalue;
  
  ivalue = ( data >>  0 ) & bits16on(8);
  i = 0;
  for (i=0; i<= NBW_KEY;i++) {
    if (ivalue == bwbitc[i]) {
      lcl->bwcomp[1] =  i;
      break;
    }
    lcl->bwcomp[1] = -1;
  }

  ivalue = ( data >>  8 ) & bits16on(8);
  i = 0;
  for (i=0; i<= NBW_KEY;i++) {
    if (ivalue == bwbitc[i]) {
      lcl->bwcomp[0] =  i;
      break;
    }
    lcl->bwcomp[0] = -1;
  }

  return;
}

void mc02bbc(lcl, data)
struct bbc_cmd *lcl;
unsigned data;
{
       lcl->gain.mode = ( data >>  8 ) & bits16on(1);
       lcl->source    = ( data >>  6 ) & bits16on(2);
       lcl->avper     = ( data >> 12 ) & bits16on(3);
       lcl->freq     &= 0xFFFF;
       lcl->freq     |= (( data >>  0 ) & bits16on(4))<<16;
       return;
}

void mc03bbc(lcl, data)
struct bbc_cmd *lcl;
unsigned data;
{
/* 4 most significant bits in freq from 02 */

  lcl->freq &= 0xF0000;
  lcl->freq |= data;
  return;

}

void mc04bbc(lcl, data)
struct bbc_mon *lcl;
unsigned data;
{
      lcl->serno  = ( data >>  0 ) & bits16on(12);
      lcl->timing = ( data >> 12 ) & bits16on(1);
      lcl->lock   = ( data >> 15 ) & bits16on(1);
      
      return;
}

void mc05bbc(lcl, data)
struct bbc_cmd *lcl;
unsigned data;
{

/* gain control */
/* LSB gain bits 0-7 */
/* USB gain bits 8-15 */

 lcl->gain.value[0] = (data >> 8) & bits16on(8);
 lcl->gain.value[1] = (data >> 0) & bits16on(8);

  return;

}

void mc06bbc(lcl, data)
struct bbc_mon *lcl;
unsigned data;
{
        /* USB total power */

       lcl->pwr[ 0] = ( data >>  0)  & bits16on(16);

       return;
}

void mc07bbc(lcl, data)
struct bbc_mon *lcl;
unsigned data;
{
        /* LSB total power */

       lcl->pwr[ 1] = ( data >>  0)  & bits16on(16);

       return;
}
