/* argument parsing utilites */

#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include "../include/cmd_ds.h"

int cmd_parse(buf,command)    /* parse command into data structure */
char *buf;                    /* input command STRING */
struct cmd_ds *command;       /* command ds */

/* parse string buffer into command ds */
/* return 0 if no error, -1 if argv overrun */

{
     int argc;
     char *equal_ptr, *old_ptr, *ptr;

/*command may be followed by an '=' and parameters */

     command->name=buf;

     equal_ptr=strchr(buf,'=');
     if(equal_ptr == NULL) { 
       command->equal='\0';
       command->argv[ 0]=NULL;
       return 0; /*only the name so return */
     }

     *equal_ptr='\0';
     command->equal= '=';

/* get the remaining arguments delimited by commas */

     argc=0;
     old_ptr=equal_ptr+1;
     ptr=strchr(old_ptr,',');
     while(ptr!=NULL&& argc < MAX_ARGS) {
       command->argv[argc++]=old_ptr;
       *ptr='\0';
       old_ptr=ptr+1;
       ptr=strchr(old_ptr,',');
     }

     if(ptr==NULL && strlen(old_ptr) > 0 && argc<MAX_ARGS) /* last argument */
       command->argv[argc++]=old_ptr;

     if(argc >= MAX_ARGS) {   /* ungracefully handle too many argument */
       command->argv[argc-1]=NULL;
       return -1;
     } else {
       command->argv[argc]=NULL;       /* terminate list */
       return 0;
     }
}

char *arg_next(command,ilast)      /* traverse argv array */
struct cmd_ds *command;
int *ilast;       /* input: next argv to use */
                  /* output: incremented by 1 unless argv[*ilast]==NULL */

/* basically this rouitine returns the next argv element until it */
/* encounters a NULL, then it only returns NULLs                  */
/* after setting-up cmd_ds intialize argc to 0, first call returns first */
/* argv, second returns second, ..., until end of arguments (NULL) */
/* *ilast is used for book-keeping by this routine */
{
    if(command->argv[*ilast]==NULL) return NULL;

    return command->argv[(*ilast)++];
}

int arg_int(ptr,iptr,dflt,flag)   /* parse arg string for int */
char *ptr;                           /* ptr to string */
int *iptr;                           /* ptr to store result */
int dflt;                            /* default result value */
int flag;                            /* TRUE if default is okay */

/* this routine handles SNAP argument interpretation for int arguments */
/* "*" use current value (already stored in *iptr) on entry */
/* ""  (empty string) use default if flag is TRUE, if FALSE, error */
/* other strings are decoded as int */
/* return value: 0 no errror, -100 no default allowed and arg was "" */
/*                            -200 wouldn't decode                   */
{
    int ierr;

    ierr=0;

    if(ptr == NULL || *ptr == '\0') {
      if (flag)
        *iptr=dflt;
      else
        ierr=-100;
      return ierr;
    }
    if(0==strcmp(ptr,"*")) return ierr;

    if(1 != sscanf(ptr,"%d",iptr)) ierr=-200;

    return ierr;
}

int arg_float(ptr,fptr,dflt,flag)  /* parse arg string for float */
char *ptr;                         /* ptr to string */
float *fptr;                       /* ptr to store result */
float dflt;                        /* default result value */
int flag;                          /* TRUE if default is okay */

/* this routine handles SNAP argument interpretation for flt arguments */
/* "*" use current value (already stored in *fptr) on entry */
/* ""  (empty string) use default if flag is TRUE, if FALSE, error */
/* other strings are decoded as float */
/* return value: 0 no errror, -100 no default allowed and arg was "" */
/*                            -200 wouldn't decode                   */
{
    int ierr;

    ierr=0;

    if(ptr == NULL || *ptr == '\0') {
      if (flag)
        *fptr=dflt;
      else
        ierr=-100;
      return ierr;
    }
    if(0==strcmp(ptr,"*")) return ierr;

    if(1 != sscanf(ptr,"%f",fptr)) ierr=-200;

    return ierr;
}
int arg_dble(ptr,dptr,dflt,flag)  /* parse arg string for dble */
char *ptr;                         /* ptr to string */
double *dptr;                      /* ptr to store result */
double dflt;                       /* default result value */
int flag;                          /* TRUE if default is okay */

/* this routine handles SNAP argument interpretation for flt arguments */
/* "*" use current value (already stored in *dptr) on entry */
/* ""  (empty string) use default if flag is TRUE, if FALSE, error */
/* other strings are decoded as double */
/* return value: 0 no errror, -100 no default allowed and arg was "" */
/*                            -200 wouldn't decode                   */
{
    int ierr;

    ierr=0;

    if(ptr == NULL || *ptr == '\0') {
      if (flag)
        *dptr=dflt;
      else
        ierr=-100;
      return ierr;
    }
    if(0==strcmp(ptr,"*")) return ierr;

    if(1 != sscanf(ptr,"%lf",dptr)) ierr=-200;

    return ierr;
}

int arg_key(ptr,key,nkey,iptr,dflt,flag)   /* parse arg string for keyword */
char *ptr;                           /* ptr to string */
char **key;                          /* array of pointers to keyword STRINGS */
int nkey;                            /* number of keyword strings */
int *iptr;                           /* ptr to store result */
int dflt;                            /* default result value */
int flag;                            /* TRUE if default is okay */

/* this routine handles SNAP argument interpretation for int arguments */
/* "*" use current value (already stored in *iptr) on entry */
/* ""  (empty string) use default if flag is TRUE, if FALSE, error */
/* other strings are compared to keywords */
/* return value: 0 no errror, -100 no default allowed and arg was "" */
/*                            -200 wouldn't decode                   */
/* a "*" can be matched in a key list because the key list is checked */
/* before the "*" use current value check is made */
{
    int ierr, icount;

    ierr=0;

    if(ptr == NULL || *ptr == '\0') {
      if (flag)
        *iptr=dflt;
      else
        ierr=-100;
      return ierr;
    }

    icount=0;
    while (icount < nkey)
       if(0==strcmp(ptr,key[icount++])) {
          *iptr=icount-1;
          return 0;
       }

    if(0==strcmp(ptr,"*")) return ierr;


    return -200;
}

int arg_key_flt(ptr,key,nkey,iptr,dflt,flag) /* parse arg string for key flt */
char *ptr;                           /* ptr to string */
char **key;                          /* array of pointers to keyword STRINGS */
int nkey;                            /* number of keyword strings */
int *iptr;                           /* ptr to store result */
int dflt;                            /* default result value */
int flag;                            /* TRUE if default is okay */

/* this routine handles SNAP argument interpretation for keyword arguments */
/* that are expressed and floats and we want all legitamite floats */
/* "*" use current value (already stored in *iptr) on entry */
/* ""  (empty string) use default if flag is TRUE, if FALSE, error */
/* other strings are compared as floats to keywords */
/* return value: 0 no errror, -100 no default allowed and arg was "" */
/*                            -200 wouldn't decode                   */
{
    int ierr, icount;
    float fltarg, fltkey;

    ierr=0;

    if(ptr == NULL || *ptr == '\0') {
      if (flag)
        *iptr=dflt;
      else
        ierr=-100;
      return ierr;
    }

    if(0==strcmp(ptr,"*")) return ierr;

    sscanf(ptr,"%f",&fltarg);

    icount=0;
    while (icount < nkey) {
       sscanf(key[icount++],"%f",&fltkey);
       if(fabs( (double)(fltkey-fltarg))<=1e-5*fabs((double)fltarg)) {
          *iptr=icount-1;
          return 0;
       }
    }

    return -200;
}
