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

int rec_dec(ptr,request,buffer,ip)
char *ptr;
struct req_rec *request;
struct req_buf *buffer;
long ip[5];
{
  struct res_rec response;
  struct res_buf resbuf;
  struct venable_cmd lcl;

  void ini_req(), add_req(), end_req();
  void get_res();
  void skd_par(), skd_run();
  void cls_clr();
  void venable81mc();

    int ierr;
    long atoi();
    long feet;

    ierr=0;
    if(ptr == NULL) ptr="";

    if (0==strcmp(ptr,"feet")) {
      request->type=1;
      request->addr=0x32;
      add_req(buffer,request);
      end_req(ip,buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if (ip[2]<0) {
        ierr=-201;
        return;
      }

      opn_res(&resbuf,ip);
      get_res(&response,&resbuf);
      ini_req(buffer);
      request->addr=0xb8;
      request->data=response.data;
    }
    else {
      feet = atoi(ptr);
      if ((feet < 0 || feet > 65535) || (ptr[0] < '0' || ptr[0] > '9'))
        ierr = -201;
      else {
        memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
        lcl.general=0;                  /* turn off record */
        venable81mc(&request->data,&lcl);
        request->type=0;
        request->addr=0x81;
        add_req(buffer,request);
        memcpy(&shm_addr->venable,&lcl,sizeof(lcl));
        request->addr=0xb7;
        request->data= bits16on(16) & feet;
      }
    }

   return ierr;
}
