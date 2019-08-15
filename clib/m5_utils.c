#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/m5state_ds.h"
#include "../include/m5time_ds.h"

/* m5trim - trim leading and trailing blanks from a M5 response parameter */
char *m5trim(ptr)
char *ptr;
{
  char *ptr2;

  while(*ptr!=0 && *ptr == ' ') /* remove leading blanks */
    ptr++;

  if(*ptr==0)   /* can't subtract 1 from a pointer, it is empty anyway */
    return ptr;

   /* now removing trailing blanks, because of previous trim of leading
    * there must be a non-blank first character
    */

  for(ptr2=strlen(ptr)-1+ptr;ptr2>ptr && *ptr2==' ';ptr2--)
    *ptr2=0;

  return ptr;
}
int m5state_init(state)
struct m5state *state;
{
  state->known=0;
  state->error=0;
}
int m5string_decode(ptr,ch,sizech,state)
char *ptr, *ch;
int sizech;
struct m5state *state;
{
  int len;

  ptr=m5trim(ptr);

  if(strlen(ptr)==0) { /* it was blank */
    if(sizech > 0)
      ch[0]=0;
    state->known=FALSE;
    state->error=FALSE;
  } else if(strcmp(ptr,"?")==0) { /* it was '?' */
    if(sizech>1)
      strcpy(ch,ptr);
    else if(sizech > 0)
      ch[0]=0;
    state->known=FALSE;
    state->error=TRUE;
  } else {                 /* a real value */ 
    len=strlen(ptr);
    state->known=TRUE;
    if(len > 2 && strcmp(ptr+len-2," ?")==0) { /* with a trailing '?' */
      state->error=TRUE;
      len-=2;
      if(len <sizech) {
	strncpy(ch,ptr,len);
	ch[len]=0;
      } else if(sizech>0){
	strncpy(ch,ptr,sizech-1);
	ch[sizech-1]=0;
	return -1;
      } else
	return -1;
    } else {                                  /* no trailing '?' */
      state->error=FALSE;
      if(len<sizech)
	strcpy(ch,ptr);
      else if(sizech > 0) {
	strncpy(ch,ptr,sizech-1);
	ch[sizech-1]=0;
	return -1;
      } else
	return -1;
    }
  }

  return 0;
}
int m5sscanf(ptr,format,value,state)
char *ptr, *format;
void *value;
struct m5state *state;
{
  int len;

  ptr=m5trim(ptr);

  if(strlen(ptr)==0) { /* it was blank */
    state->known=FALSE;
    state->error=FALSE;
  } else if(strcmp(ptr,"?")==0) { /* it was '?' */
    state->known=FALSE;
    state->error=TRUE;
  } else {                 /* a real value */ 
    len=strlen(ptr);
    state->known=TRUE;
    if(len > 2 && strcmp(ptr+len-2," ?")==0)  /* with a trailing '?' */
      state->error=TRUE;
    else
      state->error=FALSE;
    if(1!=sscanf(ptr,format,value))
      return -1;
  }

  return 0;
}
int m5time_decode(ptr,time,state)
char *ptr;
struct m5time *time;
struct m5state *state;
{
  int len;
  char *m, *dp, *s;

  ptr=m5trim(ptr);

  if(strlen(ptr)==0) { /* it was blank */
    state->known=FALSE;
    state->error=FALSE;
  } else if(strcmp(ptr,"?")==0) { /* it was '?' */
    state->known=FALSE;
    state->error=TRUE;
  } else {                 /* a real value */ 
    len=strlen(ptr);
    state->known=TRUE;
    if(len > 2 && strcmp(ptr+len-2," ?")==0)  /* with a trailing '?' */
      state->error=TRUE;
    else
      state->error=FALSE;

    time->year=-1;
    time->day=-1;
    time->hour=-1;
    time->minute=-1;
    time->seconds=-1.0;

    if(strchr(ptr,'y')!=NULL) {
      if(5!=sscanf(ptr,"%dy%dd%dh%dm%lfs",&time->year,
		   &time->day,&time->hour,&time->minute,&time->seconds))
	return -1;
    } else if(strchr(ptr,'d')!=NULL) {
      if(4!=sscanf(ptr,"%dd%dh%dm%lfs",
		   &time->day,&time->hour,&time->minute,&time->seconds))
	return -1;
    } else if(strchr(ptr,'h')!=NULL) {
      if(3!=sscanf(ptr,"%dh%dm%lfs",
		   &time->hour,&time->minute,&time->seconds))
	return -1;
    } else if(strchr(ptr,'m')!=NULL) {
      if(2!=sscanf(ptr,"%dm%lfs",
		   &time->minute,&time->seconds))
	return -1;
    } else if(strchr(ptr,'s')!=NULL) {
      if(1!=sscanf(ptr,"%lfs",
		   &time->seconds))
	return -1;

    } else
      return -1;

    m=strchr(ptr,'m');
    if(m==NULL)
      m=ptr;
    dp=strchr(m,'.');
    if(dp==NULL)
      time->seconds_precision=0;
    else {
      s=strchr(ptr,'s');
      if(s!=NULL)
	time->seconds_precision=s-dp-1;
      else
	time->seconds_precision=-1;
    }
  }

  return 0;
}
m5time_encode(ptr,time,state)
char *ptr;
struct m5time *time;
struct m5state *state;
{

  if(state->known) {
    if(time->year!=-1) {
      sprintf(ptr,"%dy",time->year);
      ptr+=strlen(ptr);
    }
    if(time->day!=-1) {
      sprintf(ptr,"%dd",time->day);
      ptr+=strlen(ptr);
    }
    if(time->hour!=-1) {
      sprintf(ptr,"%dh",time->hour);
      ptr+=strlen(ptr);
    }
    if(time->minute!=-1) {
      sprintf(ptr,"%dm",time->minute);
      ptr+=strlen(ptr);
    }
    if(time->seconds>-0.1)
      if(time->seconds_precision < 0)
	sprintf(ptr,"%lfs",time->seconds);
      else
	sprintf(ptr,"%.*lfs",time->seconds_precision,time->seconds);
  }

  if(state->error) {
    if(state->known)
      strcat(ptr," ?");
    else
      strcpy(ptr,"?");
  }

}
m5sprintf(ptr,format,value,state)
char *ptr, *format;
void *value;
struct m5state *state;
{
  if(state->known)
    if(strcmp(format,"%s")==0)
      sprintf(ptr,format,(char *)value);
    else if(strcmp(format,"%f")==0)
      sprintf(ptr,format,*((float *)value));
    else if(strcmp(format,"%d")==0)
      sprintf(ptr,format,*((int *)value));
    else if(strcmp(format,"%ld")==0)
      sprintf(ptr,format,*((long *)value));
    else if(strcmp(format,"%lx")==0)
      sprintf(ptr,format,*((unsigned long *)value));
    else if(strcmp(format,"%Ld")==0)
      sprintf(ptr,format,*((long long *)value));
    else if(strcmp(format,"%llx")==0)
      sprintf(ptr,format,*((long long unsigned *)value));

  if(state->error) {
    if(state->known)
      strcat(ptr," ?");
    else
      strcpy(ptr,"?");
  }

}

m5key_encode(ptr,keys,nkeys,value,state)
char *ptr;
char *keys[ ];
int nkeys;
int value;
struct m5state *state;
{      

  if(state->known)
    if (value >=0 && value < nkeys)
      strcpy(ptr,keys[value]);
    else
      strcpy(ptr,BAD_VALUE);

  if(state->error) {
    if(state->known)
      strcat(ptr," ?");
    else
      strcpy(ptr,"?");
  }
}

m5state_encode(ptr,state)
char *ptr;
struct m5state *state;
{      
  if(state->error) {
    if(state->known)
      strcat(ptr," ?");
    else
      strcpy(ptr,"?");
  }
}
m5key_decode(ptr,value,keys,nkeys,state)
char *ptr;
char *keys[ ];
int nkeys;
int *value;
struct m5state *state;
{
  int icount, len;

  ptr=m5trim(ptr);

  if(strlen(ptr)==0) { /* it was blank */
    state->known=FALSE;
    state->error=FALSE;
  } else if(strcmp(ptr,"?")==0) { /* it was '?' */
    state->known=FALSE;
    state->error=TRUE;
  } else {                 /* a real value */ 
    len=strlen(ptr);
    state->known=TRUE;
    if(len > 2 && strcmp(ptr+len-2," ?")==0){  /* with a trailing '?' */
      state->error=TRUE;
      ptr[len-2]=0;
    } else
      state->error=FALSE;
    icount=0;
    while (icount < nkeys) {
      if(0==strcmp(ptr,keys[icount++])) {
	*value=icount-1;
	return 0;
      }
    }
    return -1;
  }
  return 0;
}
