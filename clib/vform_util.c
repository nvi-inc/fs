/* ifd vlba formatter buffer parsing utilities */

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"
                                             /* parameter keywords */
static char *key_mode[ ]={ "prn", "v"  , "m"  , "a"  , "b"  , "c"  ,
			   "b1" , "b2" , "c1" , "c2" ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28"};

static int mode_trk[ ][32]={
{ -1,  2,  0, 18, 16, 10, 27, 25,  6,  4, 22, 20, 14, 31, 29, -1,
  -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1},
{ -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1,
  -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1},
{ -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1,
  -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1},
{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1},
{ -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1},
{ -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
};

static char *key_rate[ ]={ "0.25", "0.5", "1", "2", "4", "8", "16", "32"};
static char *key_fan[ ]={ "X0","X1","4:1","2:1","1:1","1:2","1:4", "X7"};
static char *key_brl[ ]={ "off", "8:1", "8:2", "8:4",
                         "off4","16:1","16:2","16:4"};

static int tape_clock[][8]={
               /* X0   X1  4:1  2:1  1:1  1:2  1:4   X7 */
/*   .25 */    {  -1,  -1, 0x4, 0x3, 0x2,  -1,  -1,  -1 },
/*   .5  */    {  -1,  -1, 0x5, 0x4, 0x3, 0x2,  -1,  -1 },
/*  1    */    {  -1,  -1, 0x6, 0x5, 0x4, 0x3, 0x2,  -1 },
/*  2    */    {  -1,  -1, 0x7, 0x6, 0x5, 0x4, 0x3,  -1 },
/*  4    */    {  -1,  -1,  -1, 0x7, 0x6, 0x5, 0x4,  -1 },
/*  8    */    {  -1,  -1,  -1,  -1, 0x7, 0x6, 0x5,  -1 },
/* 16    */    {  -1,  -1,  -1,  -1,  -1, 0x7, 0x6,  -1 },
/* 32    */    {  -1,  -1,  -1,  -1,  -1,  -1, 0x7,  -1 }
};

                                          /* number of elem. keyword arrays */
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_RATE sizeof(key_rate)/sizeof( char *)
#define NKEY_FAN  sizeof(key_fan )/sizeof( char *)
#define NKEY_BRL sizeof(key_brl )/sizeof( char *)


int vform_dec(lcl,count,ptr)
struct vform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(),len,i,j,ivalue,ish;
    unsigned mode, datain;
    int ioff, ifm;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      lcl->last=1;
      ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode,4,TRUE);

/* for now we set qa here in case there are any pre 2.92 systems out there
 * that need to have this set before configuring
 */
        lcl->qa.drive=1;
	lcl->qa.chan=3;

        if(lcl->mode == 0){   /* prn */
          lcl->format=0x0003;
          lcl->enable.low   =0xFFFF;     /* enable all tracks */
          lcl->enable.high  =0xFFFF;
          lcl->enable.system=0x000F;
	  for (i=0; i< 32;i++)
	    lcl->codes[i]=-1;

	} else if (lcl->mode == 1) { /* vlba */
	  lcl->format=0x0110;

        } else if (lcl->mode > 1) {  /* m3 */
/* hex version prior to 2.40 requires a different command */
          if (shm_addr->form_version < 0x240) 
            lcl->format=0x7000; 
          else
            lcl->format=0x0002;
	}

/* now adjust arbitrary track mappings for odd/even heads, don't adjust
 * anything if there are both odd and even recorder tracks in use since
 * the user can do this
 */
	if ((lcl->mode == 1 || lcl->mode == 2) && shm_addr->wrhd_fs!=0) {
	  if(shm_addr->wrhd_fs==1) {
	    ioff=TRUE;
	    for (i=0;i<16;i++)
	      ioff &= (lcl->codes[i] == -1);
	    if(ioff && lcl->enable.low == 0) {
	      lcl->enable.low=lcl->enable.high;
	      lcl->enable.high=0;
	      for (i=0;i<16;i++) {
		lcl->codes[i]=lcl->codes[i+16];
		lcl->codes[i+16]= -1;
	      }
	    }
	  } else if(shm_addr->wrhd_fs==2) {
	    ioff=TRUE;
	    for (i=16;i<32;i++)
	      ioff &= (lcl->codes[i] == -1);
	    if(ioff && lcl->enable.high == 0) {
	      lcl->enable.high=lcl->enable.low;
	      lcl->enable.low=0;
	      for (i=16;i<32;i++) {
		lcl->codes[i]=lcl->codes[i-16];
		lcl->codes[i-16]= -1;
	      }
	    }
	  }
	} else if (lcl->mode > 2) {            /* m3 mode a, b, or c */
	  if(shm_addr->equip.rack_type != VLBAG && lcl->mode < 10){
	    ierr=-300;
	    break;
	  }
	  lcl->enable.low   =0;
	  lcl->enable.high  =0;
	  lcl->enable.system=0x0000;
	  
	  switch (lcl->mode) {
	  case 3:
	  case 4:
	  case 5:
	    lcl->enable.low   =0x7FFE;     /* enable M3 tracks only */
	    lcl->enable.high  =0x7FFE;
	  case 6:
	  case 7:
	  case 8:
	  case 9:
	    if (shm_addr->wrhd_fs == 1 && (lcl->mode ==6 || lcl->mode == 8))
	      lcl->mode++;
	    else if(shm_addr->wrhd_fs == 2 && (lcl->mode ==7 || lcl->mode == 9))
	      lcl->mode--;
	    
	    if(lcl->mode%2==1)
	      lcl->enable.low =0x7FFE;
	    else
	      lcl->enable.high=0x7FFE;
	    
	    for (i=0;i<32;i++)
	      lcl->codes[i]=mode_trk[lcl->mode-3][i];
	    break;
	  default:                  /* mode dX */
	    for (i=0;i<32;i++)
	      lcl->codes[ i]=-1;
	    
	    i=lcl->mode-9;       /* M3 track number for mode d */
	    if(i>=1 && i<=28){
	      ifm=17*(i%2)+i/2;      /* formatter track number */
	      lcl->codes[ ifm]=3;
	      if (ifm<16)            /* enable one track only */
		lcl->enable.low |= 1 << ifm;
	      else
		lcl->enable.high |= 1 << (ifm-16);
	      
	      if((i+3)%2==0) { /*recorder track number turn on other odd/even*/
		i++;
	      } else {
		i--;
	      }
	      ifm=17*(i%2)+i/2;      /* formatter track number */
	      lcl->codes[ ifm]=3;
	      if (ifm<16)            /* enable one track only */
		lcl->enable.low |= 1 << ifm;
	      else
		lcl->enable.high |= 1 << (ifm-16);
	    }
	    break;
	  }
	}
	break;
      case 2:
        ierr=arg_key_flt(ptr,key_rate,NKEY_RATE,&lcl->rate,4,TRUE);
        break;
    case 3:
      ierr=arg_key(ptr,key_fan,NKEY_FAN,&lcl->fan,4,TRUE);
      if(ierr==0) {
	lcl->tape_clock=tape_clock[lcl->rate][lcl->fan];
	if (lcl->tape_clock == -1) {
	  ierr = -300;
	  break;
	} else if (lcl->mode != 1)
	  lcl->tape_clock+= 0x8;
      }
      if (shm_addr->vfm_xpnt == 0 || (lcl->fan !=5 && lcl->fan !=6 ))
	break;
      if (lcl->fan == 6)
	for (i=0;i<32;i+=4)
	  lcl->codes[i+1]=lcl->codes[i+2]=lcl->codes[i+3]=lcl->codes[i];
      else if (lcl->fan == 5)
	for (i=0;i<32;i+=2)
	  lcl->codes[i+1]=lcl->codes[i];
      break;
    case 4:
        ierr=arg_key(ptr,key_brl,NKEY_BRL,&lcl->barrel,0,TRUE);
	break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void vform_enc(output,count,lcl)
char *output;
int *count;
struct vform_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    int codes, clock;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      codes = TRUE;
      for (i=0;i<32;i++)
	codes &= shm_addr->vform.codes[i] == lcl->codes[i];
      
      if(codes &&
	 shm_addr->vform.format        == lcl->format        &&
         shm_addr->vform.enable.low    == lcl->enable.low    &&
	 shm_addr->vform.enable.high   == lcl->enable.high   &&
	 shm_addr->vform.enable.system == lcl->enable.system &&
	 shm_addr->vform.mode >=0 && shm_addr->vform.mode < NKEY_MODE)
	strcpy(output,key_mode[shm_addr->vform.mode]);
      else
          strcpy(output,BAD_VALUE);
      break;
    case 2:
      ivalue=lcl->rate;
      if(ivalue>=0 && ivalue <NKEY_RATE)
	strcpy(output,key_rate[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 3:
      ivalue=lcl->fan;
      clock=tape_clock[lcl->rate][lcl->fan];
      if(lcl->format != 0x0110 )
	clock+=0x8;
      if((ivalue>=0 && ivalue <NKEY_FAN)         &&
	 (lcl->rate >=0 && lcl->rate <NKEY_RATE) &&
	 (lcl->tape_clock == clock))
	strcpy(output,key_fan[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 4:
      ivalue=lcl->barrel;
      if(ivalue>=0 && ivalue <NKEY_BRL)
	strcpy(output,key_brl[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    default:
      *count=-1;
      break;
   }
   if(*count>0) *count++;
   return;
}

void vform_mon(output,count,lcl)
char *output;
int *count;
struct vform_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%x.%02.2x",0xFF&(lcl->version >> 8),0xFF&lcl->version);
        break;
      case 2:
        if(lcl->sys_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->sys_st);
        break;
      case 3:
        if(lcl->mcb_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->mcb_st);
        break;
      case 4:
        if(lcl->hdw_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->hdw_st);
        break;
      case 5:
        if(lcl->sfw_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->sfw_st);
        break;
      case 6:
        if(lcl->int_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->int_st);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void vform8Dmc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=lcl->enable.low;
}

void vform8Emc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=lcl->enable.high;
}

void vform8Fmc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data= 0x8000 | (bits16on(4) & lcl->enable.system);
}

void vform90mc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(15) & lcl->format); 
}

void vform91mc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->rate);
}

void vform92mc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->fan);
}

void vform93mc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->barrel);
}

void vform99mc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data= 0x8000 | (bits16on(2) & lcl->qa.drive);
}

void vform9Amc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->qa.chan);
}
void vform9Cmc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
  *data=0x8002;

}

void vform9Dmc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    if((lcl->tape_clock &0x7) == 5)
      *data=0x8019;
    else if((lcl->tape_clock &0x7) == 6)
      *data=0x8032;
    else if((lcl->tape_clock &0x7) == 7)
      *data=0x8064;
    else
      *data=0x8032;    /* rates below 2 MHz we can't handle */
}


void vformA6mc(data, hwid, lcl)
unsigned *data;
unsigned char hwid;
struct vform_cmd *lcl;
{
  if(lcl->mode == 1) /* VLBA */
    *data= (hwid << 8);
  else
    *data= hwid;
}

void vformA7mc(data, posn) 
unsigned *data;
float posn;
{
  float posv;
  int ival, ibcd, idigit, i;

  posv=posn;
  if(posn<0.0)
    posv = -posn;
  ival=posv+.5;

  ibcd=0;
  for (i=0; ival > 0 && i < 4; i++) {
    idigit=ival%10;
    ival=ival/10;
    ibcd|= idigit<<(i*4);
  }

  *data= (posn > 0.0? 0: 0x8000) | ibcd;
}

void vformADmc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=bits16on(4) &lcl->tape_clock;
}

void vformD2mc(itracks, lcl)
int itracks[32];
struct vform_cmd *lcl;
{
     int i, ivalue;

     for (i=0;i<32;i++) {
       ivalue=lcl->codes[ i];
       if( ivalue <0 )
	 itracks[ i]=0;
       else
	 itracks[ i]=0x8000 | (bits16on(5) & ivalue);
     }
     
     return;
}

void mc20vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->sys_st=0xF80F & data;
}

void mc21vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->mcb_st=0xEC3F & data;
}

void mc22vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->hdw_st=0xFE00 & data;
}

void mc23vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->sfw_st=0xFE3F & data;
}

void mc24vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->int_st=0x9FFF & data;
}

void mc60vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->version=data;
}

void mc8Dvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.low= data;
}

void mc8Evform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.high= data;
}

void mc8Fvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.system=bits16on(4) & data;
      if((data & 0x8000)==0) lclc->enable.system=-1;
}

void mc90vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->format= bits16on(15) & data;
      if((data & 0x8000)==0) lclc->format=-1;
}

void mc91vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->rate=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->rate=-1;
}

void mc92vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->fan=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->fan=-1;
}

void mc93vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->barrel=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->barrel=-1;
}

void mc99vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->qa.drive=bits16on(2) & data;
      if((data & 0x8000)==0) lclc->qa.drive=-1;
}

void mc9Avform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->qa.chan=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->qa.chan=-1;
}

void mcA6vform(hwid,data, lcl)
unsigned data;
unsigned char *hwid;
struct vform_cmd *lcl;
{
  if(lcl->format == 0x0110) /* probably VLBA */
    *hwid = (data >> 8) && 0x00FF;
  else
    *hwid=data;
  return;
}

void mcADvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->tape_clock=bits16on(4) & data;
      return;
}

void mcD2vform(lclc,itracks)
struct vform_cmd *lclc;
int itracks[ ];
{
       int i;

       for (i=0;i<32;i++)
	 if(itracks[i] == 0)
	   lclc->codes[i]=-1;
	 else
	   lclc->codes[i]=0x7FFF & itracks[i];

       return;
}


