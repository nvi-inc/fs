#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

void scmds(mess,azo,elo)
     char *mess;
     double azo,elo;
{
  int ip[5];
  char buff[512];
  int ic;


  ic=snprintf(buff,sizeof(buff),"%sp=%+.3f_%+.3f",
	      mess,azo*RAD2DEG,elo*RAD2DEG);
  if(ic>=(int)sizeof(buff)) {
    buff[sizeof(buff)-1]=0;
    ip[0]=0;
    ip[1]=0;
    ip[2]=-6;
    memcpy(ip+3,"hl",2);
    ip[4]=0;
    logita(NULL,ip[2],ip+3,ip+4);
  } else if (ic < 0) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-5;
    memcpy(ip+3,"hl",2);
    ip[4]=0;
    logit(NULL,errno,"un");
    logita(NULL,ip[2],ip+3,ip+4);
  } else {

    scmd(buff);

  }

  return;
}
