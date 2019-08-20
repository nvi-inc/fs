/* set k3 formatter aux data for narrow track commands */

#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void set_k3aux(lauxfm,ip)
char lauxfm[12];
int ip[5];
{
  char buffer[20];
  int i;

  ip[0]=ip[1]=0;

  for(i=0;i<16;i++)
    lauxfm[i]=toupper(lauxfm[i]);

  strncpy(shm_addr->k3fm.aux,lauxfm,12);
  strcpy(buffer,"AUX=");
  strncat(buffer,lauxfm,12);
  buffer[16]=0;
  ib_req2(ip,"f3",buffer);

  skd_run("ibcon",'w',ip);
  skd_par(ip);

}






