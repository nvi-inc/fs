#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int get_rxgain();

get_rxgain_files(ierr)
     int *ierr;
{
  char outbuf[80];
  int freq, icount;
  FILE *idum;

  strcpy(outbuf,"ls ");
  strcat(outbuf,FS_ROOT);
  strcat(outbuf,"/control/*.rxg");

  strcat(outbuf," > /tmp/LS.NUM 2> /dev/null");

  freq = system(outbuf);
  /*  printf(" freq %d outbuf %s\n",freq,outbuf); */
  idum=fopen("/tmp/LS.NUM","r");
  unlink("/tmp/LS.NUM");

  icount=0;
  while(-1!=fscanf(idum,"%s",outbuf)){
    /*    printf(" file %s\n",outbuf); */
    if(icount++ < MAX_RXGAIN)
      *ierr=get_rxgain(outbuf,&shm_addr->rxgain[icount]);
    else
      *ierr=-999;

    if(*ierr!=0) {
      printf(" ierr = %d on %s\n",*ierr,outbuf);
      return;
    }
  }
  *ierr=0;
  return;

}









