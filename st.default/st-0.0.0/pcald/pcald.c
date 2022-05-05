/*
 *
 * This file is part of the station example code
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the public
 * domain worldwide. This software is distributed without any warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication along
 * with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 *
 */

/*
 *  HISTORY:
 *  WHO  WHEN    WHAT
 *  weh  971219  created
 */

#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../fs/include/params.h"
#include "../../fs/include/fs_types.h"
#include "../../fs/include/fscom.h"

static char *chd_key[ ]={
  "1u","2u","3u","4u","5u","6u","7u","8u",
  "9u","10u","11u","12u","13u","14u","15u","16u",
  "1l","2l","3l","4l","5l","6l","7l","8l",
  "9l","10l","11l","12l","13l","14l","15l","16l"
};

extern struct fscom *shm_addr;

main()
{
  int ip[5];
  struct pcald_cmd pcald;
  struct data_valid_cmd data_valid[2];
  int i,j,k,l,idata;
  char buff[120];

/* connect to the FS */

  putpname("pcald");
  setup_ids();
  
 loop:
#ifdef TESTX
  printf(" sleeping\n");
#endif
  skd_wait("pcald",ip,0);

#ifdef TESTX
  printf(" woke-up\n");
#endif

 wakeup_block:
  memcpy(&pcald,&shm_addr->pcald,sizeof(pcald));
  memcpy(&data_valid,&shm_addr->data_valid,sizeof(data_valid));

#ifdef TESTX
  printf(" copied structures\n");
#endif
  if(pcald.stop_request!=0)
    goto loop;
  
#ifdef TESTX
  printf(" not stopped\n");
#endif
  if(pcald.continuous==0 &&
     (data_valid[0].user_dv ==0 && data_valid[1].user_dv ==0))
    goto loop;

#ifdef TESTX
  printf(" continuous %d data_valid[0] %d data_valid[1] %d\n",
	 pcald.continuous,data_valid[0].user_dv,data_valid[1].user_dv);
#endif

  idata=0;
  for(i=0;i<32;i++)
    if(pcald.count[i/16][i%16] >0)
      idata=1;

  if (!idata)
    goto loop;
  
#ifdef TESTX
  printf(" there is data to collect\n");
#endif

  skd_end(ip);

/* extract forever until some one wakes up */

  while(TRUE) {

#ifdef TESTX
    printf(" collecting data \n");
#endif

    for(i=0;i<32;i++) {
      for (j=0;j<pcald.count[i/16][i%16];j++) {

/* if I have to wait for anything I always use skd_wait
 * the last argument is the number of centiseconds to wait 
 * the wait can be longer than 1 second, because skd_wait() will return
 * immediately if something happens
 */

	skd_wait("pcald",ip,500);

/* when I wake-up I goto the wake-up block if some one else woke me up */

	if(dad_pid()!=0) {
#ifdef TESTX
	  printf("some one woke me 1\n");
#endif
	  goto wakeup_block;
	}

/* an alternative way to check for something to do is to skd_chk()
 * this good when you are doing a lot of processing and need to
 * surface for air, remember never more than 1 second of clock time
 * without checking
 */

	for (l;l<50000;l++){
	  if(skd_chk("pcald",ip)) {
#ifdef TESTX
	    printf("some one woke me 2 l=%d\n",l);
#endif
	    goto wakeup_block;
	  }
	}
	if(pcald.freqs[i/16][i%16][j]<0.0) {
	  sprintf(buff,"states/%s,%d,%d,0,0",chd_key[i],pcald.integration,
		  pcald.bits);
	} else {
	  
	  sprintf(buff,"tone/%s,%d,%d,%lf,%lf,%lf,,%lf,%lf",chd_key[i],
		  pcald.integration,pcald.bits,pcald.freqs[i/16][i%16][j],
		  0.0,0.0,0.0,0.0); /* amp, phase, rms amp, rms phase */
	}
	logit(buff,0,NULL);
      }
    }
  }

#ifdef TESTX
  printf("can't get here\n");
#endif
  exit(-1);

}  /* end main */
