#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int get_rxgain();

get_rxgain_files(ierr)
     int *ierr;
{
  char outbuf[513];
  int freq, icount, i;
  FILE *idum;

  strcpy(outbuf,"ls ");
  strcat(outbuf,FS_ROOT);
  strcat(outbuf,"/control/rxg_files/*.rxg");

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
    /* test code
    printf(" file %s\n",outbuf);
    printf(" gain curve: count %d\n", shm_addr->rxgain[icount].gain.ncoeff);
    printf(" gain curve: opacity corrected %c\n",
	   shm_addr->rxgain[icount].gain.opacity);
    for (i=0;i<shm_addr->rxgain[icount].gain.ncoeff;i++)
      printf(" %f ",shm_addr->rxgain[icount].gain.coeff[i]);
    printf(" \n");
    printf(" tcal table: count %d\n", shm_addr->rxgain[icount].tcal_ntable);
    for (i=0;i<shm_addr->rxgain[icount].tcal_ntable;i++)
      printf(" %c %f %f\n ",
	     shm_addr->rxgain[icount].tcal[i].pol,
	     shm_addr->rxgain[icount].tcal[i].freq,
	     shm_addr->rxgain[icount].tcal[i].tcal);
    printf(" trec %f\n",shm_addr->rxgain[icount].trec);
    printf(" spill table: count %d\n", shm_addr->rxgain[icount].spill_ntable);
    for (i=0;i<shm_addr->rxgain[icount].spill_ntable;i++)
      printf("%f %f\n ",
	     shm_addr->rxgain[icount].spill[i].el,
	     shm_addr->rxgain[icount].spill[i].tk);

    printf(" \n");
    *ierr=-999;
    return;
*/
  }
  *ierr=0;
  return;

}









