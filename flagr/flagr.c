/*
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  020509  cloned from tpicd.c
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_BUF 256

extern struct fscom *shm_addr;

main()
{
  long ip[5];
  long ipa[5] ={ 5, 0, 0, 0, 0};
  int new, acquired, lost;
  double last_ra, last_dec;
  char last_lsorna[10];

/* connect to the FS */

  putpname("flagr");
  setup_ids();

  last_ra=shm_addr->radat;
  last_dec=shm_addr->decdat;
  strncpy(last_lsorna,shm_addr->lsorna,sizeof(last_lsorna));
  acquired=FALSE;

#ifdef TESTX
  printf(" iapdflg %d\n",shm_addr->iapdflg);
#endif

  if(shm_addr->iapdflg<=0 || strncmp(shm_addr->idevant,"/dev/null ",10)==0)
    while(TRUE)
      skd_wait("flagr",ip,0);

 loop:
#ifdef TESTX
  printf(" sleeping\n");
#endif
  while(TRUE) {
    skd_wait("flagr",ip,shm_addr->iapdflg);
    if(nsem_test("onoff") == 1 || nsem_test("fivpt") == 1)
      continue;
#ifdef TESTX
  printf(" woke-up\n");
#endif
    new=last_ra!=shm_addr->radat||last_dec!=shm_addr->decdat;
    if(strncmp(last_lsorna,shm_addr->lsorna,10)!=0 ||new) {
#ifdef TESTX
  printf(" new\n");
#endif
      logit("flagr/antenna,new-source",0,NULL);
      new=FALSE;
      acquired=FALSE;
      last_ra=shm_addr->radat;
      last_dec=shm_addr->decdat;
      strncpy(last_lsorna,shm_addr->lsorna,sizeof(last_lsorna));
    }
    if (!acquired) {
#ifdef TESTX
  printf(" not acquired\n");
#endif
      skd_run("antcn",'w',ipa);
      if(shm_addr->ionsor==1) {
	logit("flagr/antenna,acquired",0,NULL);
        acquired=TRUE;
	lost=FALSE;
      }
    } else if(acquired &&!lost) {
#ifdef TESTX
  printf(" not lost\n");
#endif
      skd_run("antcn",'w',ipa);
      if(shm_addr->ionsor==0) {
	logit("flagr/antenna,off-source",0,NULL);
        lost=TRUE;
      }
    } else if(lost) {
#ifdef TESTX
  printf(" lost\n");
#endif
      skd_run("antcn",'w',ipa);
      if(shm_addr->ionsor==1) {
	logit("flagr/antenna,re-acquired",0,NULL);
        lost=FALSE;
      }
    }
  }

#ifdef TESTX
  printf("can't get here\n");
#endif
  exit(-1);


}  /* end main */
