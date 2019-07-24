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
   
  for (i=0;i<3;i++)
     sscanf(lauxfm+4*i,"%4x",shm_addr->vform.aux[0]+i);

  for (j=1;j<28;j++)
     for (i=0;i<3;i++)
        shm_addr->vform.aux[j][i]=shm_addr->vform.aux[0][i];
   
  for(i=0;i<5;i++) ip[i]=0;
    
}
