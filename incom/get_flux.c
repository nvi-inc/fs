#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

static int get_float(fvalue,error1,error2,ierr)
     float *fvalue;
     int error1,error2, *ierr;
{
  char *cptr;

  cptr=strtok(NULL," \n\t");
  if(cptr==NULL) {
    *ierr=error1;
    return -1;
  }
  
  if(1!=sscanf(cptr,"%f",fvalue)) {
    *ierr=error2;
    return -1;
  }
  
  return 0;
}
static int get_angle(fvalue,error1,error2,ierr)
     float *fvalue;
     int error1,error2, *ierr;
{
  char *cptr;
  int i;

  cptr=strtok(NULL," \n\t");
  if(cptr==NULL) {
    *ierr=error1;
    return -1;
  }
  
  if(1!=sscanf(cptr,"%f",fvalue)) {
    *ierr=error2;
    return -1;
  }

  for(i=strlen(cptr)-2;i>-1;i--)
    if(NULL==strchr("+-0123456789.",cptr[i])) {
      *ierr=error2;
      return -1;
    }

  if(cptr[strlen(cptr)-1]=='s')
    *fvalue=(*fvalue/3600.0)*DEG2RAD;
  else if(cptr[strlen(cptr)-1]=='m')
    *fvalue=(*fvalue/60.0)*DEG2RAD;
  else if(cptr[strlen(cptr)-1]=='d')
    *fvalue*=DEG2RAD;
  else {
    *ierr=error2;
    return -1;
  }
  
  return 0;
}
static int get_gauss(fvalue,error_start,ierr)
     float fvalue[];
     int error_start, *ierr;
{
  int i;

  for(i=0;i<6;i++)
    fvalue[i]=0.0;

  /* percent for 1st component */

  if(get_float(fvalue+0,error_start  ,error_start-1,ierr))
    return *ierr;

  fvalue[0]/=100.0;

  if(get_angle(fvalue+1,error_start-2,error_start-3,ierr))
    return *ierr;
  
  if(get_angle(fvalue+2,            0,error_start-5,ierr)) {
    if(*ierr==0)
      fvalue[2]=fvalue[1];
    return *ierr;
  }

  /* percent for 1st component */

  if(get_float(fvalue+3,            0,error_start-7,ierr))
    return *ierr;

  fvalue[3]/=100.0;

  if(get_angle(fvalue+4,error_start-8,error_start-9,ierr))
    return *ierr;
  
  if(get_angle(fvalue+5,            0,error_start-11,ierr)) {
    if(*ierr==0)
      fvalue[5]=fvalue[4];
    return *ierr;
  }
    return *ierr;

  return 0;
}
static int get_2pts(fvalue,error_start,ierr)
     float fvalue[];
     int error_start, *ierr;
{
  int i;

  for(i=0;i<6;i++)
    fvalue[i]=0.0;

  /* separation */

  if(get_angle(fvalue+0,error_start  ,error_start-1,ierr))
    return *ierr;

  return 0;
}
static int get_disk(fvalue,error_start,ierr)
     float fvalue[];
     int error_start, *ierr;
{
  int i;

  for(i=0;i<6;i++)
    fvalue[i]=0.0;

  /* diameter */

  if(get_angle(fvalue+0,error_start  ,error_start-1,ierr))
    return *ierr;

  return 0;
}


int get_flux(file,flux)
     char file[];
     struct flux_ds flux[MAX_FLUX];
{
  FILE *fp;
  int ierr, i, icount;
  char *cptr;
  char buff[256];
  struct flux_ds *flux_p;

  if( (fp= fopen(file,"r"))==NULL )
    return -1;

  icount=0;
  while(TRUE){
    
    ierr=find_next_noncomment(fp,buff,sizeof(buff));
    if(ierr<-1)
      return ierr-100;
    else if(ierr==-1)
      return 0;

    for (i=0;i<strlen(buff);i++)
      if(isupper(buff[i]))
	buff[i]=tolower(buff[i]);
  
    /* is it blank? */
    
    cptr=strtok(buff," \n\t");
    if(cptr==NULL)
      continue;

    if(++icount >MAX_FLUX)
      return -5;

    /* source name */

    if(strlen(cptr)>sizeof(flux->name)-1)
      return -6;
    else
      strcpy((flux+icount-1)->name,cptr);

    /* type */

    cptr=strtok(NULL," \n\t");
    if(cptr==NULL)
      return -7;

    if(strlen(cptr)!=1)
      return -8;

    if(strchr("cp",*cptr)==NULL)
      return -9;

    (flux+icount-1)->type=*cptr;

    /* freq min */

    if(get_float(&(flux+icount-1)->fmin,-10,-11,&ierr))
      return ierr;

    /* freq max */

    if(get_float(&(flux+icount-1)->fmax,-12,-13,&ierr))
      return ierr;

    /* flux coeff 0: 10**log */

    if(get_float(&(flux+icount-1)->fcoeff[0],-14,-15,&ierr))
      return ierr;

    /* flux coeff 0: 10**log(f) */
    
    if(get_float(&(flux+icount-1)->fcoeff[1],-16,-17,&ierr))
      return ierr;

    /* flux coeff 0: 10**2log(f) */

    if(get_float(&(flux+icount-1)->fcoeff[2],-18,-19,&ierr))
      return ierr;

    /* size */

    if(get_float(&(flux+icount-1)->size,-20,-21,&ierr))
      return ierr;

    (flux+icount-1)->size*=(DEG2RAD/3600.);
    /* model */
    
    cptr=strtok(NULL," \n\t");
    if(cptr==NULL)
      return -22;

    if(strcmp(cptr,"gauss")==0) {
      (flux+icount-1)->model='g';
      if(get_gauss(&(flux+icount-1)->mcoeff,-23,&ierr))
	return ierr;
    } else if(strcmp(cptr,"2pts")==0) {
      (flux+icount-1)->model='2';
      if(get_2pts(&(flux+icount-1)->mcoeff,-35,&ierr))
	return ierr;
    } else if(strcmp(cptr,"disk")==0) {
      (flux+icount-1)->model='d';
      if(get_disk(&(flux+icount-1)->mcoeff,-37,&ierr))
	return ierr;
    }

    cptr=strtok(NULL," \n\t");
    if(cptr!=NULL)
      return -39;

  }

  return 0;
}
