#define xstr(a) str(a)
#define str(a) #a
 #define RELV xstr(RELEASE)
 strncpy(shm_addr->sVerRelease_FS,RELV,sizeof(shm_addr->sVerRelease_FS));
 j=strlen(shm_addr->sVerRelease_FS);
 for(i=j;i<sizeof(shm_addr->sVerRelease_FS)-1;i++)
   shm_addr->sVerRelease_FS[i]=' ';
 shm_addr->sVerRelease_FS[sizeof(shm_addr->sVerRelease_FS
