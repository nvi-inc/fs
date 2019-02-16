/* vlba formatter version number */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void vform_ver(version,ip)
int *version;
int ip[5];
{
  struct vform_mon lclm;
  struct req_rec request;
  struct req_buf buffer;
  struct res_buf buff_out;
  struct res_rec response;
  void get_res(), ini_req(), add_req(), end_req();
  void skd_run(), skd_par(), mc60vform();

  ini_req(&buffer);

  memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

  request.type=1; 
  request.addr=0x60; add_req(&buffer,&request); /* version */
  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0)
    return;

  opn_res(&buff_out,ip);
  get_res(&response,&buff_out); mc60vform(&lclm,response.data);

  if(response.state == -1) {
     clr_res(&buff_out);
     ip[2]=-401;
     return;
  }
  clr_res(&buff_out);

  *version=lclm.version;

  return;

}
