/*
 * Copyright (c) 2020-2021 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <errno.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

static int get_float(fvalue,error1,error2,ierr)
     float *fvalue;
     int error1,error2, *ierr;
{
  char *cptr,ch;

  cptr=strtok(NULL," \n\t");
  if(cptr==NULL) {
    *ierr=error1;
    return -1;
  }
  
  if(1!=sscanf(cptr,"%f%c",fvalue,&ch)) {
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
  char buff2[256];
  int line;
  struct flux_ds *flux_p;

  if( (fp= fopen(file,"r"))==NULL ) {
    logit(NULL,errno,"un");
    return -1;
  }

  icount=0;
  buff2[0]=0;
  line=0;
  while(TRUE){
    
    line++;
    ierr=find_next_noncomment(fp,buff,sizeof(buff));
    if(ierr<=-4) {
      strcpy(buff2,buff);
      goto error;
    } else if (ierr<=-2) {
      logit(NULL,errno,"un");
      goto error2;
    } else if (ierr==-1) {
      logit(NULL,errno,"un");
      ierr=-42;
      goto error2;
    } else if(ierr==1)
      goto end;

    strcpy(buff2,buff);
    if(strlen(buff2)>0)
      buff2[strlen(buff2)-1]=0;

    for (i=0;i<strlen(buff);i++)
      if(isupper(buff[i]))
	buff[i]=tolower(buff[i]);
  
    /* is it blank? */
    
    cptr=strtok(buff," \n\t");
    if(cptr==NULL)
      continue;

    if(++icount >MAX_FLUX) {
      ierr=-5;
      goto error;
    }

    /* source name */

    if(strlen(cptr)>sizeof(flux->name)-1) {
      ierr=-6;
      goto error;
    } else
      strcpy((flux+icount-1)->name,cptr);

    /* type */

    cptr=strtok(NULL," \n\t");
    if(cptr==NULL) {
      ierr=-7;
      goto error;
    }

    if(strlen(cptr)!=1||strchr("cp",*cptr)==NULL) {
      ierr=-8;
      goto error;
    }

    (flux+icount-1)->type=*cptr;

    /* freq min */

    if(get_float(&(flux+icount-1)->fmin,-10,-11,&ierr))
      goto error;

    /* freq max */

    if(get_float(&(flux+icount-1)->fmax,-12,-13,&ierr))
      goto error;

    /* flux coeff 0: 10**log */

    if(get_float(&(flux+icount-1)->fcoeff[0],-14,-15,&ierr))
      goto error;

    /* flux coeff 0: 10**log(f) */
    
    if(get_float(&(flux+icount-1)->fcoeff[1],-16,-17,&ierr))
      goto error;

    /* flux coeff 0: 10**2log(f) */

    if(get_float(&(flux+icount-1)->fcoeff[2],-18,-19,&ierr))
      goto error;

    /* size */

    if(get_float(&(flux+icount-1)->size,-20,-21,&ierr))
      goto error;

    (flux+icount-1)->size*=(DEG2RAD/3600.);
    /* model */
    
    cptr=strtok(NULL," \n\t");
    if(cptr==NULL) {
      ierr=-22;
      goto error;
    }

    if(strcmp(cptr,"gauss")==0) {
      (flux+icount-1)->model='g';
      if(get_gauss(&(flux+icount-1)->mcoeff,-23,&ierr))
        goto error;
    } else if(strcmp(cptr,"2pts")==0) {
      (flux+icount-1)->model='2';
      if(get_2pts(&(flux+icount-1)->mcoeff,-35,&ierr))
        goto error;
    } else if(strcmp(cptr,"disk")==0) {
      (flux+icount-1)->model='d';
      if(get_disk(&(flux+icount-1)->mcoeff,-37,&ierr))
        goto error;
    } else {
      ierr=-39;
      goto error;
    }

    cptr=strtok(NULL," \n\t");
    if(cptr!=NULL) {
      ierr=-40;
      goto error;
    }

  }

end:
  if(fclose(fp)==EOF) {
      logit(NULL,errno,"un");
      return -41;
  }
  return 0;

error:
   printf("trying to read (non-blank) non-comment line %d, flux.ctl line that failed:\n'%s'\n",line,buff2);
   return ierr;

error2:
   printf("trying to read (non-blank) non-comment line %d, last flux.ctl line correctly read:\n'%s'\n",line,buff2);
   return ierr;
}
