/* mark IV formatter buffer parsing utilities */

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
static char *key_mode[ ]={ "m"  , "a"  , "b1" , "b2" , "c1" , "c2" ,
                           "e1" , "e2" , "e3" , "e4" ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28"};

static int mode_trk[ ][32]={
{ /* mode A */
 -1,  -1,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,
0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,  -1, -1
},
{ /* mode B1 */
  -1, -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,
0x10, -1,0x12,  -1,0x14,  -1,0x16,  -1,0x18,  -1,0x1A,  -1,0x1C,  -1,  -1,  -1
},
{ /* mode B2 */
 -1,  -1,  -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,
 -1,0x10,  -1,0x12,  -1,0x14,  -1,0x16,  -1,0x18,  -1,0x1A,  -1,0x1C,  -1,  -1
},
{ /* mode C1 */
  -1, -1,0x01,  -1,0x03,  -1,0x05,  -1,0x07,  -1,0x09,  -1,0x0B,  -1,0x0D,  -1,
0x00, -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,  -1,  -1
},
{ /* mode C2 */
 -1,  -1,  -1,0x01,  -1,0x03,  -1,0x05,  -1,0x07,  -1,0x09,  -1,0x0B,  -1,0x0D,
 -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,  -1
},
{ /* mode E1 */
 -1,  -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,
 -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
},
{ /* mode E2 */
 -1,  -1,  -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,
 -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
},
{ /* mode E3 */
  -1, -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
0x00, -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,  -1,  -1
},
{ /* mode E4 */
 -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
 -1,0x00,  -1,0x02,  -1,0x04,  -1,0x06,  -1,0x08,  -1,0x0A,  -1,0x0C,  -1,  -1
},
};
static char *key_rate[ ]={"0.125","0.25","0.5","1","2","4","8","16","32"};
static int   key_irate[]={   125,250,500,1000,2000,4000,8000,16000,32000};
static char *key_fan[ ]={ "4:1","2:1","1:1","1:2","1:4"};
static int   key_ifan[]={  41,   21,   11,   12,   14};
static char *key_brl[ ]={ "off"};
static char *key_syn[ ]={ "off"};
                                          /* number of elem. keyword arrays */
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_RATE sizeof(key_rate)/sizeof( char *)
#define NKEY_FAN  sizeof(key_fan )/sizeof( char *)
#define NKEY_BRL  sizeof(key_brl )/sizeof( char *)
#define NKEY_SYN  sizeof(key_syn )/sizeof( char *)

int form4_dec(lcl,count,ptr)
struct form4_cmd *lcl;
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
    ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode,0,FALSE);
    
    if(0 < lcl->mode && lcl->mode < 10) {
      switch (lcl->mode) {
      case 1: /* A  */
	lcl->enable[0]=0x3FFFFFFC;     /* enable all Mark III tracks */
	break;
      case 2: /* B1 */
      case 4: /* C1 */
	lcl->enable[0]=0x15555554;
	break;
      case 3: /* B2 */
      case 5: /* C2 */
	lcl->enable[0]=0x2AAAAAA8;
	break;
      case 6: /* E1 */
	lcl->enable[0]=0x00005554;
	break;
      case 7: /* E2 */
	lcl->enable[0]=0x0000AAA8;
	break;
      case 8: /* E3 */
	lcl->enable[0]=0x15550000;
	break;
      case 9: /* E4 */
	lcl->enable[0]=0x2AAA0000;
	break;
      }
      lcl->enable[1]=0x0;
      for (i=0; i< 32;i++)
	lcl->codes[i]=0x100|mode_trk[lcl->mode-1][i];
      for (i=32; i<64;i++)
	lcl->codes[i]=-1;
    } else if (lcl->mode >= 10) {
      lcl->enable[0]=0x4<<(lcl->mode-10);
      for (i=0; i<64;i++)
	lcl->codes[i]=-1;
      lcl->codes[2+lcl->mode-10]=0x100|0;
    }
    break;
  case 2:
    ierr=arg_key_flt(ptr,key_rate,NKEY_RATE,&lcl->rate,5,TRUE);
    break;
  case 3:
    ierr=arg_key(ptr,key_fan,NKEY_FAN,&lcl->fan,2,TRUE);
    if(ierr==0) {
      int ic;
      if (lcl->fan == 2) {
      	for (i=0;i<64;i++)
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100))
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
      } else if (lcl->fan == 4)
	for (ic=0;ic<64;ic+=8) {
	  i=ic;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1||lcl->codes[i+4]!=-1
	       ||lcl->codes[i+6]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	    lcl->codes[i+4]=lcl->codes[i]|(2<<6);
	    lcl->codes[i+6]=lcl->codes[i]|(3<<6);
	  }
	  i=ic+1;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1||lcl->codes[i+4]!=-1
	       ||lcl->codes[i+6]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	    lcl->codes[i+4]=lcl->codes[i]|(2<<6);
	    lcl->codes[i+6]=lcl->codes[i]|(3<<6);
	  }
	}
      else if (lcl->fan == 3)
	for (ic=0;ic<64;ic+=4) {
	  i=ic;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	  }
	  i=ic+1;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	  }
	}
    }
    break;
  case 4:
    ierr=arg_key(ptr,key_brl,NKEY_BRL,&lcl->barrel,0,TRUE);
    break;
  case 5:
    ierr=arg_key(ptr,key_brl,NKEY_SYN,&lcl->synch, 0,FALSE);
    if(ierr!=0) {
      ierr=arg_int(ptr,&lcl->synch      ,1,TRUE);
      if(ierr==0 & (lcl->synch < 0 || lcl->synch > 16))
	ierr=-200;
    } else
      lcl->synch=-1;
    break;
  default:
    *count=-1;
  }
  if(ierr!=0) ierr-=*count;
  if(*count>0) (*count)++;
  return ierr;
}

void form4_enc(output,count,lcl)
char *output;
int *count;
struct form4_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    int codes, clock;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      codes = TRUE;
      for (i=0;i<64;i++) {
	if(shm_addr->form4.codes[i]!=-1) {
	  codes &= shm_addr->form4.codes[i] == lcl->codes[i];
	}
      }

      if(codes &&
         shm_addr->form4.enable[0] == lcl->enable[0]  &&
	 shm_addr->form4.enable[1] == lcl->enable[1]  &&
	 shm_addr->form4.mode >=0 && shm_addr->form4.mode < NKEY_MODE)
	strcpy(output,key_mode[shm_addr->form4.mode]);
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
      if(ivalue>=0 && ivalue <NKEY_FAN)
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
    case 5:
      ivalue=lcl->synch;
      if(ivalue==-1)
	strcpy(output,"off");
      else if(ivalue==-2)
	strcpy(output,"pass");
      else if(ivalue==-3)
	strcpy(output,"fail");
      else if(0 <= ivalue && ivalue <= 16)
	sprintf(output+strlen(output),"%d",ivalue);
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

void form4_mon(output,count,lcl)
char *output;
int *count;
struct form4_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%d",lcl->version);
        break;
      case 2:
        sprintf(output,"0x%02x",lcl->rack_ids&0xFF);
        break;
      case 3:
	if(0==(lcl->status&(1<<15)))
	  strcpy(output,"okay");
	else
	  sprintf(output,"0x%x",lcl->error);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

int form4CONma(buff, lcl)
char *buff;
struct form4_cmd *lcl;
{
  buff+=4;

  if(lcl->mode==1)
    strcpy(buff,"/CON 1");
  else if (lcl->mode==2 || lcl->mode==3 ||lcl->mode==6||lcl->mode==7)
    strcpy(buff,"/CON 2");
  else if (lcl->mode==4 || lcl->mode==5 ||lcl->mode==8||lcl->mode==9)
    strcpy(buff,"/CON 3");
  else if (lcl->mode>9)
    strcpy(buff,"/CON 4");
  else {
    int twobits=0;
    int twostacks=0;
    int i,can;

    for (i=0;i<32;i++)
      if(lcl->codes[i]!= -1)
	if(lcl->codes[i]& (1<<5))
	  twobits=1;
	
    for (i=32;i<64;i++)
      if(lcl->codes[i]!= -1) {
	twostacks=1;
	if(lcl->codes[i]& (1<<5))
	  twobits=1;
      }

    if(!twostacks) {
      if(twobits&&lcl->fan==4)
	can=100;
      else if((!twobits)&&lcl->fan==4)
	can=104;
      else if(twobits && lcl->fan==3)
	can=108;
      else if((!twobits) && lcl->fan==3)
	can=112;
      else if(twobits && lcl->fan==2)
	can=114;
      else if((!twobits) && lcl->fan==2)
	can=116;
      else
	return -1;
    } else {
      if(twobits&&lcl->fan==4)
	can=200;
      else if((!twobits)&&lcl->fan==4)
	can=202;
      else if(twobits && lcl->fan==3)
	can=204;
      else if((!twobits) && lcl->fan==3)
	can=206;
      else if(twobits && lcl->fan==2)
	can=207;
      else
	return -1;
    }
    sprintf(buff,"/CON %d",can);
  }
  return 0;
}

void form4RATma(buff, lcl)
char *buff;
struct form4_cmd *lcl;
{
  buff+=4;

  sprintf(buff,"/RAT %d",key_irate[lcl->rate]);
}
void form4LIMma(buff, lcl)
char *buff;
struct form4_cmd *lcl;
{
  buff+=4;

  if(lcl->synch>=0 && lcl->synch <= 16)
    sprintf(buff,"/LIM %d",lcl->synch);
  else if(lcl->synch==-1)
    sprintf(buff,"/LIM");
  else
    sprintf(buff,"/LIM 1");
}
int form4ASSma(buff,lcl,start)
char *buff;
struct form4_cmd *lcl;
int start;
{
  int count=0;
  int first=1;
  int i;

  buff+=4;

  buff[0]=0;
  for (i=start;i<64;i++)
    if(lcl->codes[i]!=-1) {
      if(first) {
	strcpy(buff,"/ASS 0");
	first=0;
      }
      sprintf(buff+strlen(buff)," %d:0x%x",i,0xFF & lcl->codes[i]);
      if(++count==8)
	return i+1;
    }

  return -1;
}
int form4ENAma(buff,lcl,start)
char *buff;
struct form4_cmd *lcl;
int start;
{
  int count=0;
  int first=1;
  unsigned long enable;
  int i;

  buff+=4;

  buff[0]=0;

  for (i=start;i<64;i++) {
    if(i<32)
      enable=lcl->enable[0];
    else
      enable=lcl->enable[1];

    if(enable&(1<<(i%32))) {
      if(first) {
	strcpy(buff,"/ENA");
	first=0;
      }
      sprintf(buff+strlen(buff)," %d",i);
      if(++count==16)
	return i+1;
    }

  }

  return -1;
}

void maSTAform4(lclc,lclm,buff)
struct form4_cmd *lclc;
struct form4_mon *lclm;
char *buff;
{
  int status, error, con, rate, fan, start, end, step, i;

  sscanf(buff+2,"%i %i %i %d %d %d %d %d %d %d",
	 &lclm->status,&lclm->error,&lclm->rack_ids,&lclm->version,
	 &con,&rate,&fan,&start,&end,&step);

  lclc->fan=-1;
  for (i=0; i<NKEY_FAN;i++)
    if(fan==key_ifan[i]) {
      lclc->fan=i;
      break;
    }

  lclc->rate=-1;
  for (i=0; i<NKEY_RATE;i++)
    if(rate==key_irate[i]) {
      lclc->rate=i;
      break;
    }

  if(0==(lclm->status & (1<<11)) && start==0 && end == 0 && step == 0)
    lclc->barrel=0;
  else
    lclc->barrel=-1;

  if(lclm->error & (1<<15))
    lclc->synch=-3;
  else
    lclc->synch=-2;

}
void maSHOform4(lclc,buff)
struct form4_cmd *lclc;
char *buff;
{

  int i, itrack, map, stack, head, code[16], icount;

  icount=sscanf(buff+2,
	 "map[%i].stack[%i].head[%i] = x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x",
	 &map,&stack,&head,
	 code+0,code+1,code+2 ,code+3 ,code+4 ,code+5 ,code+6 ,code+7,
	 code+8,code+9,code+10,code+11,code+12,code+13,code+14,code+15);

  if(map!=0 || icount <4)
    return;

  if(stack!=1 && stack!=2)
    return;

  if(head <2 || head >33)
    return;

  itrack=32*(stack-1)+head-2;

  for (i=0;i<(icount-3);i++) {
    if(code[i]==0xff)
      lclc->codes[itrack+i]=-1;
    else
      lclc->codes[itrack+i]=0x100|code[i];
  }
}

void maSSTform4(lclc,buff)
struct form4_cmd *lclc;
char *buff;
{
  int i;
  unsigned low1, high1, low2, high2;

  sscanf(buff+2," %x %x ; %x %x",&low1,&high1,&low2,&high2);

  lclc->enable[0]=0;
  lclc->enable[1]=0;

  for (i=0;i<16;i++) {
    if(low1 & (1<<(15-i)))
      lclc->enable[0]|=1<<i;
    if(high1 & (1<<(15-i)))
      lclc->enable[0]|=1<<i+16;
    if(low2 & (1<<(15-i)))
      lclc->enable[1]|=1<<i;
    if(high2 & (1<<(15-i)))
      lclc->enable[1]|=1<<i+16;
  }

}
