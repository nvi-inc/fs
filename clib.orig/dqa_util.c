/* vlba dqa parsing utilities */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int dqa_dec(lcl,count,ptr)
struct dqa_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_int();

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_int(ptr,&lcl->dur,0,FALSE);
        if((ierr==0) && (lcl->dur<1 || lcl->dur>5) ) ierr=-200;
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void dqa_enc(output,count,lcl)
char *output;
int *count;
struct dqa_cmd *lcl;
{
    int ind, ivalue;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%d",lcl->dur);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}

void dqa_mon(output,count,lcl,dur,rate)
char *output;
int *count;
struct dqa_mon *lcl;
int dur;
float rate;
{
    int ind;
    static int kfirst = TRUE;
    static char *type;
    char *code2bs();

    if (kfirst) {
      if(shm_addr->equip.rack == VLBA) {
	if(shm_addr->equip.rack_type == VLBA)
	  type="vlba";
	else if(shm_addr->equip.rack_type == VLBAG)
	  type="vlbag";
	else
	  type="";
      } else
	type="vlbag";  /* only VLBAG were every modified to include other formatters: VLBA4 or VLBA45 */
      kfirst=FALSE;
    }  

    output=output+strlen(output);

    switch (*count) {
      case 1:
	if(shm_addr->equip.rack==VLBA)
	  sprintf(output,"%4s",code2bs(lcl->a.bbc,type));
	else /*VLBA4*/
	  sprintf(output,"%6s",code2bsfo(lcl->a.bbc));
        break;
      case 2:
        sprintf(output,"%2.2d",lcl->a.track);
        break;
      case 3:
        flt2str(output,(lcl->a.parity*8e6)/(dur*rate),7,0);
        break;
      case 4:
        flt2str(output,(lcl->a.resync*8e6)/(dur*rate),7,0);
        output[strlen(output)-1]='\0';
        break;
      case 5:
        flt2str(output,(lcl->a.nosync*8e6)/(dur*rate),7,0);
        output[strlen(output)-1]='\0';
        break;
      case 6:
        flt2str(output,lcl->a.amp,-4,1);
        break;
      case 7:
        flt2str(output,(float)(lcl->a.phase*180.0/M_PI),-6,0);
        output[strlen(output)-1]='\0';
        break;
      case 8:
	if(shm_addr->equip.rack==VLBA)
	  sprintf(output,"%4s",code2bs(lcl->b.bbc,type));
	else /*VLBA4*/
	  sprintf(output,"%6s",code2bsfo(lcl->b.bbc));
        break;
      case 9:
        sprintf(output,"%2.2d",lcl->b.track);
        break;
      case 10:
        flt2str(output,(lcl->b.parity*8e6)/(dur*rate),7,0);
        break;
      case 11:
        flt2str(output,(lcl->b.resync*8e6)/(dur*rate),7,0);
        output[strlen(output)-1]='\0';
        break;
      case 12:
        flt2str(output,(lcl->b.nosync*8e6)/(dur*rate),7,0);
        output[strlen(output)-1]='\0';
        break;
      case 13:
        flt2str(output,lcl->b.amp,-4,1);
        break;
      case 14:
        flt2str(output,(float)(lcl->b.phase*180.0/M_PI),-6,0);
        output[strlen(output)-1]='\0';
        break;
      default:
        *count=-1;
        break;
   }
   if(*count > 0) *count++;
   return;
}

void mcCAdqa(lcl, uarray)
struct dqa_mon *lcl;
unsigned uarray[32];
{
    struct dqa_data {            /* raw data unpacked from uarray */
       unsigned long cos;
       unsigned long sin;
       unsigned long cos_tot;
       unsigned long sin_tot;
    } a;                        /* channel A */
    struct dqa_data b;          /* channel B */

    struct dqa_norm {            /* normalized values */
       double cos;
       double sin;
    } n_a;                        /* channel A */
    struct dqa_norm n_b;          /* channel B */

    float abytes, bbytes;

/* get raw phase-cal data */

    a.cos=((0xFFFF & uarray[ 20])<< 16) | (0xFFFF & uarray[ 21]);
    b.cos=((0xFFFF & uarray[ 22])<< 16) | (0xFFFF & uarray[ 23]);

    a.sin=((0xFFFF & uarray[ 24])<< 16) | (0xFFFF & uarray[ 25]);
    b.sin=((0xFFFF & uarray[ 26])<< 16) | (0xFFFF & uarray[ 27]);

    a.cos_tot=((0xFFFF & uarray[ 28])<< 16) | (0xFFFF & uarray[ 29]);
    b.cos_tot=((0xFFFF & uarray[ 30])<< 16) | (0xFFFF & uarray[ 31]);

    a.sin_tot=((0xFFFF & uarray[ 32])<< 16) | (0xFFFF & uarray[ 33]);
    b.sin_tot=((0xFFFF & uarray[ 34])<< 16) | (0xFFFF & uarray[ 35]);

/* normalize the values */

    if(a.cos_tot !=0)
      n_a.cos=(2.0*a.cos-a.cos_tot)/(double) a.cos_tot;
    else
      n_a.cos=0.0;

    if(b.cos_tot !=0)
      n_b.cos=(2.0*b.cos-b.cos_tot)/(double) b.cos_tot;
    else
      n_b.cos=0.0;

    if(a.sin_tot !=0)
      n_a.sin=(2.0*a.sin-a.sin_tot)/(double) a.sin_tot;
    else
     n_a.sin=0.0;

    if(b.sin_tot !=0)
      n_b.sin=(2.0*b.sin-b.sin_tot)/(double) b.sin_tot;
    else
      n_b.sin=0.0;

    n_a.cos = sin(n_a.cos*M_PI/2.0);
    n_a.sin = sin(n_a.sin*M_PI/2.0);

    n_b.cos = sin(n_b.cos*M_PI/2.0);
    n_b.sin = sin(n_b.sin*M_PI/2.0);

    lcl->a.amp=sqrt( n_a.cos*n_a.cos + n_a.sin*n_a.sin )*100.0;
    lcl->b.amp=sqrt( n_b.cos*n_b.cos + n_b.sin*n_b.sin )*100.0;

    if(n_a.sin == 0.0 && n_a.cos == 0.0)
      lcl->a.phase=999.9;
    else
      lcl->a.phase=-atan2(n_a.sin,n_a.cos);

    if(n_b.sin == 0.0 && n_b.cos == 0.0)
      lcl->b.phase=999.9;
    else
      lcl->b.phase=-atan2(n_b.sin,n_b.cos);

/*average number of bits */

    lcl->a.num_bits=a.cos_tot/2+a.sin_tot/2+(a.cos_tot%2+a.sin_tot%2)/2;
    lcl->b.num_bits=b.cos_tot/2+b.sin_tot/2+(b.cos_tot%2+b.sin_tot%2)/2;

    lcl->a.parity=((0xFFFF & uarray[ 0])<<16) | (0xFFFF &uarray[ 1]);
    lcl->b.parity=((0xFFFF & uarray[ 2])<<16) | (0xFFFF &uarray[ 3]);

    lcl->a.crcc_a=((0xFFFF & uarray[ 4])<<16) | (0xFFFF &uarray[ 5]);
    lcl->b.crcc_a=((0xFFFF & uarray[ 6])<<16) | (0xFFFF &uarray[ 7]);

    lcl->a.crcc_b=((0xFFFF & uarray[ 8])<<16) | (0xFFFF &uarray[ 9]);
    lcl->b.crcc_b=((0xFFFF & uarray[10])<<16) | (0xFFFF &uarray[11]);

    lcl->a.resync=((0xFFFF & uarray[12])<<16) | (0xFFFF &uarray[13]);
    lcl->b.resync=((0xFFFF & uarray[14])<<16) | (0xFFFF &uarray[15]);

    lcl->a.nosync=((0xFFFF & uarray[16])<<16) | (0xFFFF &uarray[17]);
    lcl->b.nosync=((0xFFFF & uarray[18])<<16) | (0xFFFF &uarray[19]);

    return;
}


