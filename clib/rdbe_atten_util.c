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
        ierr=arg_key(ptr,auto_key,NAUTO_KEY,&lcl->if0.if0,0,FALSE);
	if(ierr==0) {
	  lcl->if0.if0=-2;
	  m5state_init(&lcl->if0.state);
	  lcl->if0.state.known=1;
	} else {
	  ierr=arg_key(ptr,atten_key,NATTEN_KEY,&lcl->if0.if0,0,FALSE);
	  if(ierr== -100) {
	    ierr=0;
	    lcl->if0.if0=-1;
	    m5state_init(&lcl->if0.state);
	    lcl->if0.state.known=1;
	  } else if(ierr==0) {
	    m5state_init(&lcl->if0.state);
	    lcl->if0.state.known=1;
	  } else {
	    m5state_init(&lcl->if0.state);
	    lcl->if0.state.error=1;
	  }
	} 
        break;
      case 2:
        ierr=arg_key(ptr,auto_key,NAUTO_KEY,&lcl->if1.if1,0,FALSE);
	if(ierr==0) {
	  lcl->if1.if1=-2;
	  m5state_init(&lcl->if1.state);
	  lcl->if1.state.known=1;
	} else {
	  ierr=arg_key(ptr,atten_key,NATTEN_KEY,&lcl->if1.if1,0,FALSE);
	  if(ierr== -100) {
	    ierr=0;
	    lcl->if1.if1=-1;
	    m5state_init(&lcl->if1.state);
	    lcl->if1.state.known=1;
	  } else if(ierr==0) {
	    m5state_init(&lcl->if1.state);
	    lcl->if1.state.known=1;
	  } else {
	    m5state_init(&lcl->if1.state);
	    lcl->if1.state.error=1;
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
    if(lclc->if0.state.known == 1) 
      if(lclc->if0.if0 >= 0 && lclc->if0.if0 <NATTEN_KEY) { 
	m5key_encode(output,atten_key,NATTEN_KEY,
		     lclc->if0.if0,&lclc->if0.state);
      } else if(lclc->if0.if0 == -2) {
	strcat(output,auto_key[0]);
      } else if(lclc->if0.if0 != -1) {
	strcat(output,BAD_VALUE);
      } else
	;
    else
      m5sprintf(output,"","",&lclc->if0.if0,&lclc->if0.state);
    break;
  case 2:
    if(lclc->if1.state.known == 1) 
      if(lclc->if1.if1 >= 0 && lclc->if1.if1 <NATTEN_KEY) { 
	m5key_encode(output,atten_key,NATTEN_KEY,
		     lclc->if1.if1,&lclc->if1.state);
      } else if(lclc->if1.if1 == -2) {
	strcat(output,auto_key[0]);
      } else if(lclc->if1.if1 != -1) {
	strcat(output,BAD_VALUE);
      } else
	;
    else
      m5sprintf(output,"","",&lclc->if1.if1,&lclc->if1.state);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0) *count++;
  return;
}
rdbe_atten0_2_rdbe(ptr,lcl)
char *ptr;
struct rdbe_atten_cmd *lcl;
{
  ptr[0]=0;

  if (lcl->if0.if0 != -1) {
    strcpy(ptr,"dbe_atten = 0");
    if(lcl->if0.if0 >-1 && lcl->if0.if0 <NATTEN_KEY) {
      strcat(ptr," : ");
      strcat(ptr,atten_key[lcl->if0.if0]);
    }
  }
  if(strlen(ptr)!=0)
    strcat(ptr," ;\n");

  return;
}
rdbe_atten1_2_rdbe(ptr,lcl)
char *ptr;
struct rdbe_atten_cmd *lcl;
{
  ptr[0]=0;

  if (lcl->if1.if1 != -1) {
    strcpy(ptr,"dbe_atten = 1");
    if(lcl->if1.if1 >-1 && lcl->if1.if1 <NATTEN_KEY) {
      strcat(ptr," : ");
      strcat(ptr,atten_key[lcl->if1.if1]);
    }
  }

  if(strlen(ptr)!=0)
    strcat(ptr," ;\n");

  return;
}
rdbe_2_rdbe_atten0(ptr_in,lclc,ip,who) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_atten_cmd *lclc;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
     char *who;
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, i, ifc;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }
  /* no monitor response */
  m5state_init(&lclc->if0.state);
  lclc->if0.if0=NATTEN_KEY;
  lclc->if0.state.known=1;

  m5state_init(&lclc->if0.state);

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logita(NULL,errno,"un",who);
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
	if(1!=sscanf(ptr,"%d",&ifc) && ifc!=0) {
	  ierr=-503;
	  goto error2;
	}
	break;
      case 2:
	if(m5key_decode(ptr,&lclc->if0.if0,atten_key,NATTEN_KEY,
			&lclc->if0.state)) {
	  ierr=-501;
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
  memcpy(ip+4,who,2);
  return -1;
}
rdbe_2_rdbe_atten1(ptr_in,lclc,ip,who) /* return values:
				  *  0 == no error
				  *  0 != error
				  */
     char *ptr_in;           /* input buffer to be parsed */

     struct rdbe_atten_cmd *lclc;  /* result structure with parameters */
     long ip[5];   /* standard parameter array */
     char *who;
{
  char *new_str, *ptr, *ptr2, *ptr_save;
  int count, ierr;
  int tvgss, i, ifc;
  char string[33];

  ptr=strchr(ptr_in,'?');
  if(ptr == NULL) {
    ierr=-901;
    goto error;
  }
  /* no monitor response */
  m5state_init(&lclc->if1.state);
  lclc->if1.if1=NATTEN_KEY;
  lclc->if1.state.known=1;

  m5state_init(&lclc->if1.state);

  ptr=strchr(ptr+1,':');
  if(ptr!=NULL) {
    ptr=new_str=strdup(ptr+1);
    if(ptr==NULL) {
      logita(NULL,errno,"un",who);
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
	if(1!=sscanf(ptr,"%d",&ifc) && ifc!=1) {
	  ierr=-504;
	  goto error2;
	}
	break;
      case 2:
	if(m5key_decode(ptr,&lclc->if1.if1,atten_key,NATTEN_KEY,
			&lclc->if1.state)) {
	  ierr=-502;
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
  memcpy(ip+4,who,2);
  return -1;
}
