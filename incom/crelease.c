#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void crelease_()
{
  int i,j;

#define xstr(a) str(a)
#define str(a) #a
#define RELV xstr(RELEASE)

  strncpy(shm_addr->sVerRelease_FS,RELV,sizeof(shm_addr->sVerRelease_FS));
  shm_addr->sVerRelease_FS[sizeof(shm_addr->sVerRelease_FS)-1]=0;
  j=strlen(shm_addr->sVerRelease_FS);
  for(i=j;i<sizeof(shm_addr->sVerRelease_FS)-1;i++)
    shm_addr->sVerRelease_FS[i]=' ';
}
