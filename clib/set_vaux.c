/* set vlba formatter aux data for narrow track commands */

#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void set_vaux(lauxfm,ip)
char lauxfm[12];
long ip[5];
{
  int i,j;
  struct req_rec request;        /* mcbcn request record */
  struct req_buf buffer;         /* mcbcn request buffer */

  for (i=0;i<3;i++)
     sscanf(lauxfm+4*i,"%4x",shm_addr->vform.aux[0]+i);

  for (j=0;j<28;j++)
     for (i=0;i<3;i++)
        shm_addr->vform.aux[j][i]=shm_addr->vform.aux[0][i];

  for(i=0;i<5;i++)
    ip[i]=0;

  ini_req(&buffer);
  memcpy(request.device,DEV_VFM,2);    /* device mnemonic */
  
  request.type=0;
  request.addr=0x84;  request.data=0x8002;  add_req(&buffer,&request); 

  request.addr=0xd4;  request.data=0;       add_req(&buffer,&request); 

  for (j=0;j<32;j++) {
    request.addr=0xd5;  request.data=j*16;  add_req(&buffer,&request); 
    for (i=0;i<3;i++) {
      request.addr=0xd6;
      request.data=shm_addr->vform.aux[0][i];
      add_req(&buffer,&request);
    }
  }

  request.addr=0x83;  request.data=0x8001;  add_req(&buffer,&request); 

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;
  cls_clr(ip[0]);
  rte_sleep(300);

  ini_req(&buffer);

  request.type=0;
  request.addr=0x84;  request.data=0x8001;  add_req(&buffer,&request); 
  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
    
}

