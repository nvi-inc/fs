/* k4ib command buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"

#define WR   0
#define RD   1
#define WRRD 2
#define PL   3
#define ST   4
#define CL   5

#define AS   0
#define BN   1

char *arg_next(struct cmd_ds *command,int *ilast);  /* traverse argv array */

int k4ib_dec(struct cmd_ds *command,long int ip[5], int *ireq)
{
  int ilast,i;
  char *ptr;
  char *device, *cmd, *mode, *format, *length;
  int imode, iformat, ilength;

  ilast=0;

  device=arg_next(command,&ilast);
  if(device == NULL || strlen(device)==0)
    device="  ";
  else if(strlen(device)!=2)
    return -201;

  cmd=arg_next(command,&ilast);
  if(cmd==NULL)
    cmd="";

  mode=arg_next(command,&ilast);
  if(mode==NULL)
    mode="";

  if(strlen(mode) == 0 || strcmp(mode,"normal")==0) {
    if(strlen(cmd)==0)
      imode=RD;
    else {
      ptr=index(cmd,'?');
      if(ptr==NULL) {
	ptr=strstr(cmd,"rd");
	if(ptr==NULL) {
	  ptr=strstr(cmd,"lc");
	  if(ptr==NULL) {
	    ptr=strstr(cmd,"lv");
	    if(ptr==NULL)
	      ptr=strstr(cmd,"stat");
	  }
	}
      }
      if(ptr!=NULL)
	imode=WRRD;
      else
	imode=WR;
    }
  } else if (strcmp(mode,"read")==0)
    imode=RD;
  else if (strcmp(mode,"write")==0)
    imode=WR;
  else if (strcmp(mode,"write/read")==0)
    imode=WRRD;
  else if (strcmp(mode,"poll")==0)
    imode=PL;
  else if (strcmp(mode,"status")==0)
    imode=ST;
  else if (strcmp(mode,"clear")==0)
    imode=CL;
  else
    return -203;
  
  format=arg_next(command,&ilast);
  if(format == NULL)
    format="";

  if(strlen(format) == 0 || strcmp(format,"normal")==0) {
    ptr=NULL;
    if(strlen(cmd)!=0) {
      ptr=strstr(cmd,"stat");
      if(ptr==NULL)
	ptr=strstr(cmd,"err?");
    }
    if(ptr!=NULL || imode==ST || imode==PL)
      iformat=BN;
    else
      iformat=AS;
  } else if(strcmp(format,"ascii")==0)
    iformat=AS;
  else if(strcmp(format,"binary")==0)
    iformat=BN;
  else
    return -204;

  length=arg_next(command,&ilast);
  if(length == NULL)
    length = "";

  if(strlen(length) == 0 || strcmp(format,"normal")==0) {
    ilength=0;
    if(strlen(cmd)!=0) {
      if(NULL!=strstr(cmd,"rd"))
	ilength=210;
      else if(NULL!=strstr(cmd,"lv"))
	ilength=143;
    }
    if(ilength == 0)
      ilength=21;
  } else if(1!=sscanf(length,"%d",&ilength) || ilength <= 0)
    return -205;

/* done now make the buffer */
  
  if(strlen(cmd) != 0) {
    int ilen=strlen(cmd);
    for(i=0;i<ilen;i++)
      cmd[i]=toupper(cmd[i]);
  }

  ip[0]=ip[1]=0;

  if(imode==WR) {
    ib_req2(ip,device,cmd);
    *ireq=2;
  } else if(imode==WRRD)
    if(iformat==BN) {
      ib_req8(ip,device,ilength,cmd);
      *ireq=8;
    } else { /* ascii */
      ib_req7(ip,device,ilength,cmd);
      *ireq=7;
    }
  else if(imode==ST) {
    ib_req9(ip,device);
    *ireq=9;
  } else if(imode==PL) {
    ib_req10(ip,device);
    *ireq=10;
  } else if(imode==CL) {
    ib_req12(ip,device);
    *ireq=12;
  } else /* RD */
    if(iformat==BN) {
      ib_req6(ip,device,ilength);
      *ireq=6;
    } else { /* ascii */
      ib_req5(ip,device,ilength);
      *ireq=5;
    }

  return 0;
}

