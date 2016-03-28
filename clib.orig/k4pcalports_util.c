/* k4 pcalports buffer parsing utilities */

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

static char device[]={"r1"};           /* device menemonics */

#define MAX_BUF 512

int k4pcalports_dec(lcl,count,ptr)
struct k4pcalports_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, arg_int();
    int type, ipos;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
    case 1:
    case 2:
      ierr=arg_int(ptr,&lcl->ports[*count-1],0,FALSE);
      if(ierr==0 && (lcl->ports[*count-1]<1 || lcl->ports[*count-1]>16))
	ierr=-200;
      break;
    default:
      *count=-1;
    }
    
    if(ierr!=0) ierr-=*count;
    if(*count>0) (*count)++;
    return ierr;
}

void k4pcalports_enc(output,count,lcl)
char *output;
int *count;
struct k4pcalports_cmd *lcl;
{
  int ivalue, type, ipos;

  output=output+strlen(output);

  switch (*count) {
  case 1:
  case 2:
    sprintf(output,"%02d",lcl->ports[*count-1]);
    break;
  default:
    *count=-1;
  }

}
void k4pcalports_mon(output,count,lclc,lclm)
char *output;
int *count;
struct k4pcalports_cmd *lclc;
struct k4pcalports_mon *lclm;
{
  int ivalue,chan;

  output=output+strlen(output);
  
  switch (*count) {
  case 1:
  case 2:
    chan=shm_addr->k4recpatch.ports[lclc->ports[*count-1]-1];
    if(shm_addr->equip.rack == K4) {
      if(shm_addr->equip.rack_type==K41 || shm_addr->equip.rack_type==K41U)
	sprintf(output,"%3s",code2rpk41(chan));
      else if(shm_addr->equip.rack_type==K42 ||
	      shm_addr->equip.rack_type==K42A ||
	      shm_addr->equip.rack_type==K42B ||
	      shm_addr->equip.rack_type==K42BU ||
	      shm_addr->equip.rack_type==K42C)
	sprintf(output,"%3s",code2rpk42(chan));
      else
	sprintf(output,"%3s",code2rp(chan));
    } else
      sprintf(output,"%3s",code2rp(chan));
    break;
  case 3:
  case 4:
    flt2str(output,lclm->amp[*count-3],-5,2);
    break;
  case 5:
  case 6:
    flt2str(output,lclm->phase[*count-5],-5,1);
    break;
  default:
    *count=-1;
  }
  
  if(*count>0)
    *count++;
  return;
}


k4pcalports_req_q(ip)
long ip[5];
{

 ib_req7(ip,device,20,"PCA?");
 ib_req7(ip,device,20,"PCB?");

}
k4pcalports_req_c(ip,lclc)
long ip[5];
struct k4pcalports_cmd *lclc;
{
  char buffer[30];
  int ipos;

  if(shm_addr->equip.drive[0]==K4 &&
     (shm_addr->equip.drive_type[0]==K41 ||
      shm_addr->equip.drive_type[0] == K41DMS) )
    sprintf(buffer,"PCA=%d",lclc->ports[0]);
  else
    sprintf(buffer,"PCA=%02d",lclc->ports[0]);
  ib_req2(ip,device,buffer);

  if(shm_addr->equip.drive[0]==K4 &&
     (shm_addr->equip.drive_type[0]==K41 ||
      shm_addr->equip.drive_type[0] == K41DMS) )
    sprintf(buffer,"PCB=%d",lclc->ports[1]);
  else
    sprintf(buffer,"PCB=%02d",lclc->ports[1]);
  ib_req2(ip,device,buffer);

}

k4pcalports_res_q(lclc,lclm,ip)
struct k4pcalports_cmd *lclc;
struct k4pcalports_mon *lclm;
long ip[5];
{
  char buffer[MAX_BUF];
  int max,i;
  int icount;

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }

  if(3!=(icount=sscanf(buffer,
		       "PCA=%f,%f,%d",
		       lclm->amp+0,
		       lclm->phase+0,
		       lclc->ports+0))) {
    ip[2]=-1;
    return;
  }

  max=sizeof(buffer);
  ib_res_ascii(buffer,&max,ip);
  if(max < 0) {
    ip[2]=-1;
    return;
  }

  if(3!=(icount=sscanf(buffer,
		       "PCB=%f,%f,%d",
		       lclm->amp+1,
		       lclm->phase+1,
		       lclc->ports+1))) {
    ip[2]=-1;
    return;
  }

}


