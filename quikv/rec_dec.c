/* vlba rec buffer parsing utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <limits.h>
#include <math.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/macro.h"
#include "../include/shm_addr.h"      /* shared memory pointer */

int rec_dec(ptr,request,buffer,ip,indx)
char *ptr;
struct req_rec *request;
struct req_buf *buffer;
long ip[5];
int indx;
{
  struct res_rec response;
  struct res_buf resbuf;
  struct venable_cmd lcl;

  void ini_req(), add_req(), end_req();
  void get_res();
  void skd_par(), skd_run();
  void cls_clr();
  void venable81mc();
  int vacuum();

  int ierr;
  int lerr;
  int verr;
  long atoi();
  long feet;

  ierr=0;
  if(ptr == NULL) ptr="";

  if (0==strcmp(ptr,"feet")) {
    if(shm_addr->equip.drive[indx] == VLBA &&
       shm_addr->equip.drive_type[indx] == VLBA2) {
      memcpy(ip+3,"rc",2);
      return -204;
    }
    request->type=1;
    request->addr=0x32; add_req(buffer,request);
    end_req(ip,buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if (ip[2]<0) {
      ierr=ip[2];
      return ierr;
    }

    opn_res(&resbuf,ip);
    get_res(&response,&resbuf);
    if(response.state == -1) {
       clr_res(&resbuf);
       ierr=-401;
       memcpy(ip+3,"rc",2);
       return ierr;
    }
    clr_res(&resbuf);

    ini_req(buffer);
    if(indx == 0) 
      memcpy(request->device,"r1",2);
    else 
      memcpy(request->device,"r2",2);

    request->type=0;
    request->addr=0xb8;
    request->data=response.data; 
    add_req(buffer,request);
  } else {
    feet = atoi(ptr);
    if ((feet < 0 || feet > 65535) || (ptr[0] < '0' || ptr[0] > '9'))
      ierr = -201;
    else {
      verr=0;
      lerr=0;
      verr = vacuum(&lerr,indx);
      if (verr<0) {
        /* vacuum not ready or other error */
        ierr = verr;
	memcpy(ip+3,"rc",2);
        return ierr;
      } else if (lerr!=0) { 
        /* error with trying to read recorder */
        ierr = lerr;
	memcpy(ip+3,"rc",2);
        return ierr;
      } else {
        ini_req(buffer);
	if(indx == 0) 
	  memcpy(request->device,"r1",2);
	else 
	  memcpy(request->device,"r2",2);

        memcpy(&lcl,&shm_addr->venable[indx],sizeof(lcl));
        lcl.general=0;                  /* turn off record */
        shm_addr->venable[indx].general=0;
        shm_addr->idirtp[indx]=-1;
        venable81mc(&(request->data),&lcl);
        request->type=0;
        request->addr=0x81;
        add_req(buffer,request);

        request->addr=0xb7;
        request->data= bits16on(16) & feet;
        add_req(buffer,request);
      }
    }
  }

  memcpy(ip+3,"rc",2);
  return ierr;
}
