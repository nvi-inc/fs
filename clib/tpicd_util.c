/* tpicd buffer parsing utilities */

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

static char *cont_key[ ]={"no","yes"};
static char *bits_key[ ]={"auto","1","2"};

#define CHD_KEY  sizeof(chd_key)/sizeof( char *)
#define CONT_KEY sizeof(cont_key)/sizeof( char *)
#define BITS_KEY sizeof(cont_key)/sizeof( char *)

static char chanm[] = "0123";
static char chanv[] = "0abcd";
static char chanl[] = "01234";
static char hex[]= "0123456789abcdef";
static char det[] = "dlu34567";
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};

int tpicd_dec(lcl,count,ptr)
struct tpicd_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_key(), arg_int();
    int i, j, k;
    double freq;
    static int iconv, isb;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
      ierr=arg_key(ptr,cont_key,CONT_KEY,&lcl->continuous,0,TRUE);
      for(i=0;i<MAX_DET;i++)
	lcl->itpis[i]=0;
      break;
    case 2:
      ierr=arg_int(ptr,&lcl->cycle,0,FALSE);
      if(ierr==0 & lcl->cycle < 0)
	ierr=-200;
      break;
    default:
      if(shm_addr->equip.rack==MK3) {
	if(shm_addr->imodfm==0||shm_addr->imodfm==2) {
              for(i=0;i<14;i++)
		lcl->itpis[i]=1;
	} else if(shm_addr->imodfm==1) {
              for(i=0;i<14;i=i+2)
		lcl->itpis[i]=1;
	} else if(shm_addr->imodfm==3) {
		lcl->itpis[1]=1;
	}
      } else if(shm_addr->equip.rack==MK4&&shm_addr->equip.rack_type==MK45 &&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS)) {
	mk5vcd(lcl->itpis);
      } else if(shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	mk4vcd(lcl->itpis);
      } else if(shm_addr->equip.rack==VLBA) {
	vlbabbcd(lcl->itpis);
      } else if(shm_addr->equip.rack==VLBA4 && 
		shm_addr->equip.rack_type==VLBA45 &&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS)) {
	mk5bbcd(lcl->itpis); 
      } else if(shm_addr->equip.rack==VLBA4) {
	mk4bbcd(lcl->itpis);
      } else if(shm_addr->equip.rack==LBA) {
	lbaifpd(lcl->itpis);
      } else if(shm_addr->equip.rack==DBBC &&
		shm_addr->equip.drive[0]==MK5 &&
		(shm_addr->equip.drive_type[0]==MK5B ||
		 shm_addr->equip.drive_type[0]==MK5B_BS)) {
	mk5dbbcd(lcl->itpis); 
      }

      if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	for (i=0;i<14;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=abs(shm_addr->ifp2vc[i]);
	    if(lcl->ifc[i]<0||lcl->ifc[i]>3)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0) /*select the corresponding IFs too*/
	      lcl->itpis[14+lcl->ifc[i]-1]=1;
	    lcl->lwhat[i][0]=hex[i+1];
	    if(shm_addr->ITPIVC[i]==-1)
	      lcl->lwhat[i][1]='x';
	    else
	      lcl->lwhat[i][1]=det[shm_addr->ITPIVC[i]&0x7];
	  }
	for (i=14;i<17;i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-13;
	    lcl->lwhat[i][0]='i';
	    lcl->lwhat[i][1]=hex[i-13];
	  }
      }else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	for (i=0;i<2*MAX_VLBA_BBC;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->bbc[i%MAX_BBC].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>MAX_IF)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0)
	      lcl->itpis[2*MAX_BBC+lcl->ifc[i]-1]=1;
	    strncpy(lcl->lwhat[i],lwhat[i],2);
	  }
	for (i=2*MAX_BBC;i<(2*MAX_BBC+MAX_VLBA_IF);i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-(2*MAX_BBC-1);
	    strncpy(lcl->lwhat[i],lwhat[i],2);
	  }
      }else if (shm_addr->equip.rack==LBA) {
        for (i=0;i<2*shm_addr->n_das;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->das[i/2].ifp[i%2].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>4)
	      lcl->ifc[i]=0;
	    strncpy(lcl->lwhat[i],lwhat[i+MAX_BBC],2);
	    lcl->lwhat[i][1]=det[0];
	  }
      }else if (shm_addr->equip.rack==DBBC) {
	for (i=0;i<2*MAX_DBBC_BBC;i++)
	  if(lcl->itpis[i]!=0){
	    lcl->ifc[i]=shm_addr->dbbcnn[i%MAX_DBBC_BBC].source+1;
	    if(lcl->ifc[i]<0||lcl->ifc[i]>MAX_DBBC_IF)
	      lcl->ifc[i]=0;
	    if(lcl->ifc[i]!=0)
	      lcl->itpis[2*MAX_DBBC_BBC+lcl->ifc[i]-1]=1;
	    strncpy(lcl->lwhat[i],lwhat[i],2);
	  }
	for (i=2*MAX_DBBC_BBC;i<2*MAX_DBBC_BBC+MAX_DBBC_IF;i++)
	  if(lcl->itpis[i]!=0) {
	    lcl->ifc[i]=i-(2*MAX_DBBC_BBC-1);
	    strncpy(lcl->lwhat[i],lwhat[i],2);
	  }
      } 

      /*
      for(i=0;i<MAX_DET;i++)
	if(lcl->itpis[i]!=0)
	  printf("i %d lcl->itpis[i] %d lcl->ifc[i] %d lcl->lwhat[i] %2.2s\n",
		 i,lcl->itpis[i],lcl->ifc[i],lcl->lwhat[i]);
      */
      *count=-1;
       break;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void tpicd_enc(output,count,lcl)
char *output;
int *count;
struct tpicd_cmd *lcl;
{
  int ivalue,i,j,k,lenstart,limit;

  output=output+strlen(output);

  if(*count == 1) {
    ivalue=lcl->continuous;
    if (ivalue >=0 && ivalue <CONT_KEY)
      strcat(output,cont_key[ivalue]);
    else
      strcat(output,BAD_VALUE);
    strcat(output,",");

    sprintf(output+strlen(output),"%d",lcl->cycle);
    goto end;
  }
    
  if(*count >= 2 && *count <=7 ) {
    for(j=*count-2;j<5;j++) {
      *count=j+2;
      if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	sprintf(output+strlen(output),"%c",chanm[j]);
	limit=17;
      }else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	sprintf(output+strlen(output),"%c",chanv[j]);
	limit=MAX_DET;
      }else if (shm_addr->equip.rack==LBA) {
	sprintf(output+strlen(output),"%c",chanl[j]);
	limit=2*shm_addr->n_das;
      }else if (shm_addr->equip.rack==DBBC) {
	sprintf(output+strlen(output),"%c",chanv[j]);
	limit=MAX_DBBC_DET;
      }
      lenstart=strlen(output);
      for (k=0;k<limit;k++) {
	if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	  i=k;
	}else if (shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	  if(k<2*MAX_BBC)
	    i=MAX_BBC*(k%2)+k/2;
	  else
	    i=k;
	}else if (shm_addr->equip.rack==LBA) {
	  i=k;
	}else if (shm_addr->equip.rack==DBBC) {
	  if(k<2*MAX_DBBC_BBC)
	    i=MAX_DBBC_BBC*(k%2)+k/2;
	  else
	    i=k;
	}
	if(lcl->itpis[i]!=0 && lcl->ifc[i]==j) {
	  int len;
	  strcat(output,",");
	  len=strlen(output);
	  strncat(output,lcl->lwhat[i],2);
	  output[len+2]=0;
	}
      }
      if(output[lenstart]!=0 ) {
	goto end;
      }
      output[lenstart-1]=0;
    }
    *count=-1;
  }

 end:
  return;
}
