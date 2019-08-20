/* S2 rcl SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 512+1+sizeof("k4ib/")
#define MAX_BUF 512

void k4ib_dis(command,ip,ireq)
struct cmd_ds *command;
int ip[5];
int ireq;
{
  int ierr, i, nch, max;
  char output[MAX_OUT];
  int class, nrecs;
  
  if(ip[0] == 0 || ip[1] == 0) {
    if(ip[1] == 0 && ip[0] != 0) {
      cls_clr(ip[0]);
      ip[0]=0;
    }
    ip[1]=0;
    return;
  }

  strcpy(output,command->name);
  strcat(output,"/");

  if(ireq==5||ireq==7) {
    max=sizeof(output)-strlen(output)-1;
    ib_res_ascii(output+strlen(output),&max,ip);
    if(max<0) {
      ierr=-303;
      goto error;
    }
  } else if (ireq==6 || ireq==8) {
    unsigned char data[MAX_BUF];
    max=sizeof(data);
    ib_res_bin(data,&max,ip);
    if(max<0) {
      ierr=-303;
      goto error;
    }
    max=sizeof(data)>max? max: sizeof(data);
    for(i=0;i<max;i++) {
      if(i!=0)
	strcat(output,",");
      sprintf(output+strlen(output),"0x%x",data[i]);
    }
  } else if (ireq==9 || ireq==10) {
    int data[MAX_BUF/sizeof(int)];

    max=sizeof(data)>max? max: sizeof(data);
    ib_res_bin((unsigned char *)&data,&max,ip);
    if(max<0) {
      ierr=-303;
      goto error;
    }
    max=sizeof(data)>max? max: sizeof(data);
    for (i=0;i<max/sizeof(int);i++){
      if(i!=0)
	strcat(output,",");
      if(data[i] >= 0)
	 sprintf(output+strlen(output),"0x%x",data[i]);
      else
	 sprintf(output+strlen(output),"%d",data[i]);
    }
  } else {
    ierr = -302;
    goto error;
  }

done:     
  for (i=0;i<5;i++)
    ip[i]=0;
  cls_snd(ip+0,output,strlen(output),0,0);
  ip[1]=1;
  return;
  
error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"k4",2);
  
  return;
}
