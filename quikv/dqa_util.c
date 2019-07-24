/* vlba dqa parsing utilities */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/dqa_ds.h"

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

    output=output+strlen(output);

    switch (*count) {
      case 1:
        flt2str(output,lcl->a.parity/(dur*rate),7,0);
        break;
      case 2:
        flt2str(output,lcl->a.resync/(dur*rate),7,0);
        break;
      case 3:
        flt2str(output,lcl->a.amp,5,2);
        break;
      case 4:
        flt2str(output,lcl->a.phase*180.0/M_PI,7,0);
        break;
      case 5:
        flt2str(output,lcl->b.parity/(dur*rate),7,0);
        break;
      case 6:
        flt2str(output,lcl->b.resync/(dur*rate),7,0);
        break;
      case 7:
        flt2str(output,lcl->b.amp,5,2);
        break;
      case 8:
        flt2str(output,lcl->b.phase*180.0/M_PI,6,1);
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
    a.sin_tot=((0xFFFF & uarray[ 34])<< 16) | (0xFFFF & uarray[ 35]);

/* normalize the values */
/* the numerator handles any value without breaking out of unsigned long */
/* it really is calculating 2*a.x-a.x_tot */

    n_a.cos=(2*(a.cos-a.cos_tot/2)-a.cos_tot%2)/(double) a.cos_tot;
    n_b.cos=(2*(b.cos-b.cos_tot/2)-b.cos_tot%2)/(double) b.cos_tot;

    n_a.sin=(2*(a.sin-a.sin_tot/2)-a.sin_tot%2)/(double) a.sin_tot;
    n_b.sin=(2*(b.sin-b.sin_tot/2)-b.sin_tot%2)/(double) b.sin_tot;

    lcl->a.amp=sqrt( n_a.cos*n_a.cos + n_a.sin*n_a.sin )*100.0;
    lcl->b.amp=sqrt( n_b.cos*n_b.cos + n_b.sin*n_b.sin )*100.0;

    lcl->a.phase=atan2(n_a.sin,n_a.cos);
    lcl->b.phase=atan2(n_b.sin,n_b.cos);

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
