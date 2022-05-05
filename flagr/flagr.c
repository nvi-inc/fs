/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/*
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  020509  cloned from tpicd.c
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

#define MAX_BUF 256

#define NEW_SOURCE  \
  (last_satellite!=shm_addr->satellite.satellite                        \
   || (last_satellite == 0                                              \
       && (strncmp(last_lsorna,shm_addr->lsorna,10)!=0 ||               \
           last_ra!=shm_addr->radat||last_dec!=shm_addr->decdat))       \
   || (last_satellite == 1                                              \
       && (strcmp(last_satellite_name,shm_addr->satellite.name)!=0)))

extern struct fscom *shm_addr;

main()
{
  int ip[5],ipr[5];
  int ipa[5] ={ 5, 0, 0, 0, 0};
  int new, acquired, lost;
  double last_ra, last_dec;
  char last_lsorna[10];
  int last_satellite;
  char last_satellite_name[17];
  char lskd[8];
  int suppress_antcn_errors;

/* connect to the FS */

  if(getenv("FS_FLAGR_SUPPRESS_ANTCN_ERRORS")==NULL)
    suppress_antcn_errors=0;
  else
    suppress_antcn_errors=1;
  
  putpname("flagr");
  setup_ids();
  skd_wait("flagr",ip,(unsigned) 0);

  last_ra=shm_addr->radat;
  last_dec=shm_addr->decdat;
  strncpy(last_lsorna,shm_addr->lsorna,sizeof(last_lsorna));

  last_satellite=shm_addr->satellite.satellite;
  strncpy(last_satellite_name,
	  shm_addr->satellite.name,
	  sizeof(last_satellite_name));
  
  acquired=FALSE;
  new=FALSE;

  memcpy(lskd,shm_addr->LSKD,8);

#ifdef TESTX
  printf(" iapdflg %d\n",shm_addr->iapdflg);
#endif

  skd_end(ip);

  if(shm_addr->iapdflg<=0 || strncmp(shm_addr->idevant,"/dev/null ",10)==0)
    while(TRUE)
      skd_wait("flagr",ip,0);

 loop:
#ifdef TESTX
  printf(" sleeping\n");
#endif
  while(TRUE) {
    skd_wait("flagr",ip,shm_addr->iapdflg);
    if(nsem_test("onoff") == 1 || nsem_test("fivpt") == 1
       ||nsem_test("holog") == 1)
      continue;
#ifdef TESTX
    printf(" woke-up dad_pid %d ip[0] %d\n",dad_pid(),ip[0]);
#endif
    if(dad_pid()!=0 && ip[0]!=0) {
#ifdef TESTX
      printf(" new\n");
      printf("new %d acquired %d LSKD %8.8s lskd %8.8s\n",
	     new,acquired,shm_addr->LSKD,lskd);
#endif
      if(new && !acquired && memcmp(shm_addr->LSKD,"none    ",8)!=0 &&
	 memcmp(shm_addr->LSKD,lskd,8)==0)
	logit(NULL,-1,"fl");
      
      logit("flagr/antenna,new-source",0,NULL);
      new=TRUE;
      acquired=FALSE;
      last_ra=shm_addr->radat;
      last_dec=shm_addr->decdat;
      strncpy(last_lsorna,shm_addr->lsorna,sizeof(last_lsorna));
      last_satellite=shm_addr->satellite.satellite;
      strncpy(last_satellite_name,
	      shm_addr->satellite.name,
	      sizeof(last_satellite_name));
      memcpy(lskd,shm_addr->LSKD,8);

    }
    skd_run("antcn",'w',ipa);
    skd_par(ipr);
    if(ipr[2]!=0 && !suppress_antcn_errors) {
      logit(NULL,ipr[2],ipr+3);
      logit(NULL,-2,"fl");
      continue;
    }
    if (new && !acquired) {
#ifdef TESTX
  printf(" not acquired\n");
#endif
      if(shm_addr->ionsor==1 && !NEW_SOURCE) {
	logit("flagr/antenna,acquired",0,NULL);
        acquired=TRUE;
	new=FALSE;
	lost=FALSE;
      }
    } else if(acquired &&!lost) {
#ifdef TESTX
  printf(" not lost\n");
#endif
      if(shm_addr->ionsor==0 && !NEW_SOURCE) {
	logit("flagr/antenna,off-source",0,NULL);
        lost=TRUE;
      }
    } else if(acquired && lost) {
#ifdef TESTX
  printf(" lost\n");
#endif
      if(shm_addr->ionsor==1 && !NEW_SOURCE) {
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
