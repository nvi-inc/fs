/* rdbe_atten commmand buffer parsing utilities */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include <errno.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char *both_key[ ]=         { "both"}; 
static char   *if_key[ ]=         { "0", "1"}; 
static char *auto_key[ ]=         { "auto"}; 
static char *atten_key[ ]= 
  { "0.0", "0.5", "1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0", "4.5",
    "5.0", "5.5", "6.0", "6.5", "7.0", "7.5", "8.0", "8.5", "9.0", "9.5",
   "10.0","10.5","11.0","11.5","12.0","12.5","13.0","13.5","14.0","14.5",
   "15.0","15.5","16.0","16.5","17.0","17.5","18.0","18.5","19.0","19.5",
   "20.0","20.5","21.0","21.5","22.0","22.5","23.0","23.5","24.0","24.5",
   "25.0","25.5","26.0","26.5","27.0","27.5","28.0","28.5","29.0","29.5",
   "30.0","30.5","31.0","31.5"
  };

#define NBOTH_KEY sizeof(both_key)/sizeof( char *)
#define NIF_KEY sizeof(if_key)/sizeof( char *)
#define NAUTO_KEY sizeof(auto_key)/sizeof( char *)
#define NATTEN_KEY sizeof(atten_key)/sizeof( char *)

char *m5trim();

int rdbe_atten_dec(lcl,count,ptr)
struct rdbe_atten_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, i, arg_key();
    
    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,both_key,NBOTH_KEY,&lcl->ifc.ifc,-1,TRUE);
	if(0==ierr) {
	  lcl->ifc.ifc=-1;
	  ierr=0;
	} else {
	  ierr=arg_key(ptr,if_key,NIF_KEY,&lcl->ifc.ifc,-1,TRUE);
	}
	if(0==ierr) {
	  m5state_init(&lcl->ifc.state);
	  lcl->ifc.state.known=1;
	}
	break;
      case 2:
        ierr=arg_key(ptr,auto_key,NAUTO_KEY,&lcl->atten.atten,-1,TRUE);
	if(ierr==0) {
	  lcl->atten.atten=-1;
	} else {
	  ierr=arg_key_flt(ptr,atten_key,NATTEN_KEY,&lcl->atten.atten,-1,TRUE);
	}
	if(0==ierr) {
	  m5state_init(&lcl->atten.state);
	  lcl->atten.state.known=1;
	}
        break;
    case 3:
      ierr=arg_float(ptr,&lcl->target.target,shm_addr->rdbe_equip.rms_t,FALSE);
      if(lcl->atten.atten!=-1 && ierr==0)
	  ierr=-600;
      else {
	ierr=arg_float(ptr,&lcl->target.target,shm_addr->rdbe_equip.rms_t,TRUE);
	if(ierr==0)
	  if(0.0 > lcl->target.target || lcl->target.target > 128.0)
	    ierr=-200;
	  else{
	    m5state_init(&lcl->target.state);
	    lcl->target.state.known=1;
	  }
      }
      break;

      default:
       *count=-1;
   }

   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void rdbe_atten_enc(output,count,lclc)
char *output;
int *count;
struct rdbe_atten_cmd *lclc;
{
  int ivalue;

  output=output+strlen(output);

  switch (*count) {
  case 1:
    if(lclc->ifc.state.known == 1) 
      if(lclc->ifc.ifc >= 0 && lclc->ifc.ifc <NIF_KEY) { 
	m5key_encode(output,if_key,NIF_KEY,
		     lclc->ifc.ifc,&lclc->ifc.state);
      } else if(lclc->ifc.ifc == -1) {
	strcat(output,both_key[0]);
      } else
	strcat(output,BAD_VALUE);
    break;
  case 2:
    if(lclc->atten.state.known == 1) 
      if(lclc->atten.atten >= 0 && lclc->atten.atten <NATTEN_KEY) { 
	m5key_encode(output,atten_key,NATTEN_KEY,
		     lclc->atten.atten,&lclc->atten.state);
      } else if(lclc->atten.atten == -1) {
	strcat(output,auto_key[0]);
      } else
	strcat(output,BAD_VALUE);
    break;
  case 3:
    if(lclc->target.state.known == 1)  {
      sprintf(output,"%.1f",lclc->target.target);
      m5state_encode(output,&lclc->target.state);
    }
    break;
  default:
    *count=-1;
  }
  
  if(*count>0) *count++;
  return;
}
void rdbe_atten_mon(output,count,lclm)
char *output;
int *count;
struct rdbe_atten_mon *lclm;
{
  int i;

  output=output+strlen(output);

  i=(*count-1)/3;

  if(*count<1 || i>1) {
    *count=-1;
    return;
  }
  if(1== *count)
    strcat(output,",,,"); /*device doesn't report first three parameters */

  output=output+strlen(output);

  switch ((*count-1)%3+1) {
  case 1:
    if(lclm->ifc[i].ifc.state.known == 1) 
      if(lclm->ifc[i].ifc.ifc >= 0 && lclm->ifc[i].ifc.ifc <NIF_KEY) { 
	m5key_encode(output,if_key,NIF_KEY,
		     lclm->ifc[i].ifc.ifc,&lclm->ifc[i].ifc.state);
      } else if(lclm->ifc[i].ifc.ifc == -1) {
	strcat(output,both_key[0]);
      } else
	strcat(output,BAD_VALUE);
    break;
  case 2:
    if(lclm->ifc[i].atten.state.known == 1) 
      if(lclm->ifc[i].atten.atten >= 0 &&
	 lclm->ifc[i].atten.atten <NATTEN_KEY) { 
	m5key_encode(output,atten_key,NATTEN_KEY,
		     lclm->ifc[i].atten.atten,&lclm->ifc[i].atten.state);
      } else if(lclm->ifc[i].atten.atten == -1) {
	strcat(output,auto_key[0]);
      } else
	strcat(output,BAD_VALUE);
    break;
  case 3:
    if(lclm->ifc[i].RMS.state.known == 1)  {
      sprintf(output,"%.1f",lclm->ifc[i].RMS.RMS);
      m5state_encode(output,&lclm->ifc[i].RMS.state);
    }
    break;
  default:
    *count=-1;
  }
  
  if(*count>0) *count++;
  return;
}
rdbe_atten_2_rdbe(ptr,lcl)
char *ptr;
struct rdbe_atten_cmd *lcl;
{
  strcpy(ptr,"dbe_atten = ");

  if(lcl->ifc.ifc >= 0 && lcl->ifc.ifc <NIF_KEY) {
      strcat(ptr,if_key[lcl->ifc.ifc]);
  }

  strcat(ptr," : ");
  if(lcl->atten.atten >= 0 && lcl->atten.atten <NATTEN_KEY) {
    strcat(ptr,atten_key[lcl->atten.atten]);
    strcat(ptr," : ");
  } else {
    strcat(ptr," : ");
    sprintf(ptr+strlen(ptr),"%.01f",lcl->target.target);
  }

  strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_atten(ptr_in,lclm,ip) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_atten_mon *lclm;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, i, ifc;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL)
    ptr=strchr(ptr_in,'=');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }
  /* no monitor response */
  m5state_init(&lclm->ifc[0].ifc.state);
  m5state_init(&lclm->ifc[0].atten.state);
  m5state_init(&lclm->ifc[0].RMS.state);
  m5state_init(&lclm->ifc[1].ifc.state);
  m5state_init(&lclm->ifc[1].atten.state);
  m5state_init(&lclm->ifc[1].RMS.state);

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logit(NULL,errno,"un");
      ierr=-902;
      goto error;
    }

    ptr2=strchr(ptr,';'); /* terminate the string at the ; */
    if(ptr2!=NULL)
      *ptr2=0;
    
    count=0;
    ptr_save=ptr;
    ptr=strsep(&ptr_save,":");

    while (ptr!=NULL) {
      switch (++count) {
      case 1:
      case 4:
	if(m5key_decode(ptr,&lclm->ifc[(count-1)/3].ifc.ifc,if_key,NIF_KEY,
			&lclm->ifc[(count-1)/3].ifc.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 2:
      case 5:
	if(m5key_decode(ptr,&lclm->ifc[(count-1)/3].atten.atten,
			atten_key,NATTEN_KEY,
			&lclm->ifc[(count-1)/3].atten.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      case 3:
      case 6:
	if(m5sscanf(ptr,"%f",&lclm->ifc[(count-1)/3].RMS.RMS,
		       &lclm->ifc[(count-1)/3].RMS.state)) {
	  ierr=-500-count;
	  goto error2;
	}
	break;
      default:
	goto done;
	break;
      }
      ptr=strsep(&ptr_save,":");
    }
  done:
    free(new_str);
  }

  return 0;

error2:
  free(new_str);
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2b",2);
  return -1;
}
