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
static char *key_brl[ ]={ "off", "8", "16", "m"};
static char *key_mod[ ]={ "off", "on"};
static char *key_syn[ ]={ "off"};
                                          /* number of elem. keyword arrays */
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_RATE sizeof(key_rate)/sizeof( char *)
#define NKEY_FAN  sizeof(key_fan )/sizeof( char *)
#define NKEY_BRL  sizeof(key_brl )/sizeof( char *)
#define NKEY_MOD  sizeof(key_mod )/sizeof( char *)
#define NKEY_SYN  sizeof(key_syn )/sizeof( char *)

int form4_dec(lcl,count,ptr)
struct form4_cmd *lcl;
int *count;
char *ptr;
{
  int ierr, ind, arg_key(),len,i,j,k,ivalue,ish;
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
    lcl->bits=1;
    for (i=0;i<64;i++)
      if(lcl->codes[i]!= -1)
	if(lcl->codes[i]& (1<<5))
	  lcl->bits=2;
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
      } else if (lcl->fan == 4) {
	for (i=0;i<64;i++)
	  if(lcl->codes[i]>=0 && (lcl->codes[i]&0xF) >= 8 &&
	     (lcl->codes[i]&(1<<5))) {
	    ierr=-505;
	    goto done;
	  }
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
	  }else if((lcl->codes[i+2]!= -1 && 0==(lcl->codes[i+2]&0x100)) ||
		   (lcl->codes[i+4]!= -1 && 0==(lcl->codes[i+4]&0x100)) ||
		   (lcl->codes[i+6]!= -1 && 0==(lcl->codes[i+6]&0x100)))
	    ierr=-300;
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
	  } else if((lcl->codes[i+2]!= -1 && 0==(lcl->codes[i+2]&0x100)) ||
		    (lcl->codes[i+4]!= -1 && 0==(lcl->codes[i+4]&0x100)) ||
		    (lcl->codes[i+6]!= -1 && 0==(lcl->codes[i+6]&0x100)))
	    ierr=-300;

	}
      } else if (lcl->fan == 3)
	for (ic=0;ic<64;ic+=4) {
	  i=ic;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	  } else if(lcl->codes[i+2]!= -1 && 0==(lcl->codes[i+2]&0x100))
	    ierr=-300;
	  i=ic+1;
	  if(lcl->codes[i]!=-1 && 0==(lcl->codes[i]&0x100)) {
	    if(lcl->codes[i+2]!=-1){
	      ierr=-300;
	      break;
	    }
	    lcl->codes[i  ]=lcl->codes[i]|0x100;
	    lcl->codes[i+2]=lcl->codes[i]|(1<<6);
	  } else if(lcl->codes[i+2]!= -1 && 0==(lcl->codes[i+2]&0x100))
	    ierr=-300;
	}
    }
    break;
  case 4:
    ierr=arg_key(ptr,key_brl,NKEY_BRL,&lcl->barrel,0,TRUE);
    if(ierr!=0)
      break;
    else if(lcl->barrel !=0 && shm_addr->imk4fmv <40) {
      ierr=-506;
      goto done;
    } else if(lcl->barrel== 1) {
      for(k=0;k<2;k++) {
	for(i=0;i<8;i++) {
	  for(j=0;j<16;j++) {
	    lcl->roll[i][k*32+j]=2+(16+j-2*i)%16;
	  }
	  for(j=16;j<32;j++) {
	    lcl->roll[i][k*32+j]=18+(16+j-2*i)%16;
	  }
	}
	for (i=8;i<16;i++)
	  for(j=0;j<32;j++)
	    lcl->roll[i][k*32+j]=-2;
      }
      lcl->start_map=0;
      lcl->end_map=7;
    } else if(lcl->barrel == 2)  {
      for(k=0;k<2;k++) {
	for(i=0;i<8;i++) {
	  for(j=0;j<16;j++) {
	    lcl->roll[i][k*32+j]=2+(16+j-2*i)%16;
	  }
	  for(j=16;j<32;j++) {
	    lcl->roll[i][k*32+j]=18+(16+j-2*i)%16;
	  }
	}

      /* roll by 16 is roll by 8 and then swap the two ends for the rest */
	
	for (i=8;i<16;i++)
	  for(j=0;j<32;j++)
	    lcl->roll[i][k*32+j]=lcl->roll[i-8][k*32+(j+16)%32];
      }
      lcl->start_map=0;
      lcl->end_map=15;
    } else if(lcl->barrel == 0 ||lcl->start_map<0 ||lcl->end_map<0)  {
      for(k=0;k<2;k++) {
	for(j=0;j<32;j++) {
	  lcl->roll[0][k*32+j]=2+j;
	}
	for (i=1;i<16;i++)
	  for(j=0;j<32;j++)
	    lcl->roll[i][k*32+j]=-2;
      }
      lcl->start_map=0;
      lcl->end_map=0;
    }
    /*
    for (j=0;j<32;j++) {
      printf("%2.2x rl %2.2d=",lcl->codes[j],j+2);
      for (i=0;i<16;i++)
	printf(" %2.2d",lcl->roll[i][j]&0xFF);
      printf("\n");
    }
    printf(" start_map %d end_map %d\n",lcl->start_map,lcl->end_map);
    */
    for (i=0;i<16;i++)
      for (j=0;j<64;j++)
	lcl->a2d[i][j]=-2;
    
    for(i=lcl->start_map;i<lcl->end_map+1;i++)
      for(k=0;k<2;k++)
	for(j=0;j<32;j++)
	  if(lcl->roll[i][k*32+j] >=2) {
	    if(lcl->codes[k*32+j]!=-1)
	      lcl->a2d[i][k*32+lcl->roll[i][k*32+j]-2]=
		lcl->codes[k*32+j] &0xFF;
	    else
	      lcl->a2d[i][k*32+lcl->roll[i][k*32+j]-2]=-1;
	  }
    /*
    for (j=0;j<32;j++) {
      printf("%2.2x tk %2.2d=",lcl->codes[j],j+2);
      for (i=0;i<16;i++)
	printf(" %2.2x",lcl->a2d[i][j]&0xFF);
      printf("\n");
      }
      */

    break;
  case 5:
    ierr=arg_key(ptr,key_mod,NKEY_MOD,&lcl->modulate, 0,TRUE);
    if(ierr == 0 && lcl->modulate==1 && shm_addr->imk4fmv<40) {
      ierr=-507;
      goto done;
    }
    break;
  case 6:
    ierr=arg_key(ptr,key_syn,NKEY_SYN,&lcl->synch, 0,FALSE);
    if(ierr!=0) {
      ierr=arg_int(ptr,&lcl->synch      ,3,TRUE);
      if(ierr==0 & (lcl->synch < 0 || lcl->synch > 16))
	ierr=-200;
    } else
      lcl->synch=-1;
    break;
  default:
    *count=-1;
  }
  if(ierr!=0) ierr-=*count;
done:
  if(*count>0) (*count)++;
  return ierr;
}

void form4_enc(output,count,lcl)
char *output;
int *count;
struct form4_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    int a2d, clock, roll;

    output=output+strlen(output);

    switch (*count) {
    case 1:
      a2d = TRUE;
	for (i=0;i<64;i++) {
	  int on;
	  if (i <32)
	    on= 0 != (lcl->enable[0] & 1 << i);
	  else
	    on= 0 != (lcl->enable[1] & 1 << (i-32));
	  if(on) { 
	    for (j=shm_addr->form4.start_map;j<shm_addr->form4.end_map+1;j++) {
	      if(shm_addr->form4.a2d[j][i] != lcl->a2d[j][i] &&
		 (shm_addr->form4.a2d[j][i] > 0 ||
		  lcl->a2d[j][i]>0)) {
		a2d=FALSE;
		break;
	      }
	    }
	  }
	  if(!a2d)
	    break;
	}
	
      if(a2d && shm_addr->form4.bits == lcl->bits &&
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
      ivalue=shm_addr->form4.barrel;
      if(lcl->start_map == shm_addr->form4.start_map &&
	 lcl->end_map   == shm_addr->form4.end_map &&
	 ivalue>=0 && ivalue <NKEY_BRL)
	strcpy(output,key_brl[ivalue]);
      else
	strcpy(output,BAD_VALUE);
      break;
    case 5:
      ivalue=lcl->modulate;
      if(ivalue>=0 && ivalue <NKEY_MOD)
	strcpy(output,key_mod[ivalue]);
      else if(ivalue!=-1)
	strcpy(output,BAD_VALUE);
      break;
    case 6:
      ivalue=lcl->synch;
      if(ivalue==-1)
	strcpy(output,"off");
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
      if(lcl->error & (1<<15))
	strcpy(output,"fail");
      else
	strcpy(output,"pass");
      break;
    case 2:
      sprintf(output,"%d",lcl->version);
      break;
    case 3:
      sprintf(output,"0x%02x",lcl->rack_ids&0xFF);
      break;
    case 4:
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
      else if(lcl->fan==2)
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
void form4MUXma(buff, lcl)
char *buff;
struct form4_cmd *lcl;
{

  buff+=4;
  
  if(lcl->fan<0 || lcl->fan>=NKEY_FAN)
     sprintf(buff,"/MUX 11 %d",lcl->bits);
  else
    sprintf(buff,"/MUX %2.2d %d",key_ifan[lcl->fan],lcl->bits);

}
void form4LIMma(buff, lcl)
char *buff;
struct form4_cmd *lcl;
{
  buff+=4;

  if(lcl->synch>=0 && lcl->synch <= 16)
    sprintf(buff,"/LIM %d",lcl->synch);
  else if(lcl->synch==-1 && shm_addr->imk4fmv < 40)
    sprintf(buff,"/LIM");
  else if(lcl->synch==-1)
    sprintf(buff,"/LIM 99");
  else
    sprintf(buff,"/LIM 8");
}
int form4ASSma(buff,lcl,start,start_map)
char *buff;
struct form4_cmd *lcl;
int start,*start_map;
{
  int count=0;
  int first=1;
  int i, j;

  buff+=4;

  buff[0]=0;
  if(lcl->barrel < 3) {
    for (i=start;i<64;i++)
      if(lcl->codes[i]>=0) {
	if(first) {
	  strcpy(buff,"/ASS 0");
	  first=0;
	}
	sprintf(buff+strlen(buff)," %d:0x%x",i,0xFF & lcl->codes[i]);
	if(++count==8)
	  return i+1;
      }
  } else {
    for(j=*start_map;j<16;j++) {
      first=TRUE;
      for(i=start;i<64;i++) {
	if(lcl->a2d[j][i]>=0) {
	  if(first) {
	    sprintf(buff, "/ASS %d",j);
	    first=0;
	  }
	  if(lcl->a2d[j][i]>=0) {
	    sprintf(buff+strlen(buff)," %d:0x%x",
		    i,lcl->a2d[j][i]);
	    if(++count==8)
	      return i+1;
	  }
	}
      }
      start=0;
      (*start_map)++;
      if(count!=0) {
	return 64;
      }
    }
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
void form4ROLma(buff,lcl)
char *buff;
struct form4_cmd *lcl;
{
  int j,i;

  buff+=4;

  buff[0]=0;

  if(lcl->barrel==0 || (lcl->start_map==0 && lcl->end_map==0))
    strcpy(buff,"/ROLL 0 0 0 0");
  else if(lcl->barrel==1)
    strcpy(buff,"/ROLL 0 0 1 8");
  else if(lcl->barrel==2)
    strcpy(buff,"/ROLL 0 0 1 16");
  else
    sprintf(buff,"/ROL %d %d 1 0",lcl->start_map,lcl->end_map);

}
void form4MODma(buff,lcl)
char *buff;
struct form4_cmd *lcl;
{
  int j,i;

  buff+=4;

  buff[0]=0;

  if(lcl->modulate==1)
    strcpy(buff,"/MOD 1");
  else 
    strcpy(buff,"/MOD 0");
}

void maLIMform4(lclc,buff)
struct form4_cmd *lclc;
char *buff;
{

  sscanf(buff+2,"%i",&lclc->synch);

}

void maSTAform4(lclc,lclm,buff)
struct form4_cmd *lclc;
struct form4_mon *lclm;
char *buff;
{
  int status, error, con, rate, fan, start, end, step, i;

  sscanf(buff+2,"%i %i %i %d %d %d %d %d %d %d",
	 &lclm->status,&lclm->error,&lclm->rack_ids,&lclm->version,
	 &con,&rate,&fan,&lclc->start_map,&lclc->end_map,&step);

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

  if(0==(lclm->status & (1<<11)) || step == 0) {
    lclc->start_map=0;
    lclc->end_map=0;
  }

  if(0!=(lclm->status & (1<<7)))
    lclc->bits=2;
  else
    lclc->bits=1;

  lclc->modulate=-1;
}
void maSHOform4(lclc,buff)
struct form4_cmd *lclc;
char *buff;
{

  int i, itrack, map, stack, head, a2d[16], icount;

  icount=sscanf(buff+2,
	 "map[%i].stack[%i].head[%i] = x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x x%x",
	 &map,&stack,&head,
	 a2d+0,a2d+1,a2d+2 ,a2d+3 ,a2d+4 ,a2d+5 ,a2d+6 ,a2d+7,
	 a2d+8,a2d+9,a2d+10,a2d+11,a2d+12,a2d+13,a2d+14,a2d+15);

  if(map< 0 || map > 15 || icount <4)
    return;

  if(stack!=1 && stack!=2)
    return;

  if(head <2 || head >33)
    return;

  itrack=32*(stack-1)+head-2;

  for (i=0;i<(icount-3);i++) {
    if(a2d[i]==0xff)
      lclc->a2d[map][itrack+i]=-1;
    else
      lclc->a2d[map][itrack+i]=a2d[i];
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
