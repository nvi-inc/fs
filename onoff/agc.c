/* tpi support utilities for VLBA rack */
/* tpi_vlba formats the buffers and runs mcbcn to get data */
/* tpput_vlba stores the result in fscom and formats the output */
/* tsys_vlba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static char ch[ ]={"123456789abcde"};

int agc(itpis_vlba,agc,ierr)                    /* sample tpi(s) */
int itpis_vlba[MAX_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc14, U: bbc1...bbc14(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int agc;              /* value to send 0=fixed,1=before fixed */
int *ierr;
{
    struct req_buf buffer;
    struct req_rec request;
    struct bbc_cmd bbc;
    static int mode[MAX_BBC];
    int i;
    long ip[5];                                     /* ipc array */

    ini_req(&buffer);
    request.type=20;
    request.addr=0x02;

    for (i=0;i<MAX_BBC;i++) {
      if(1==itpis_vlba[i]||1==itpis_vlba[i+MAX_BBC]) {
	request.device[0]='b';
	request.device[1]=ch[i%MAX_BBC];                /* '1'-'e' */
	if(agc==0) {
	  mode[i]=shm_addr->bbc[i].gain.mode;
	  shm_addr->bbc[i].gain.mode=0;
	} else
	  shm_addr->bbc[i].gain.mode=mode[i];
	
	bbc02mc(&request.data,&shm_addr->bbc[i]); add_req(&buffer,&request);
      }
    }

    end_req(ip,&buffer);                /* end request buffer and do it */
    skd_run("mcbcn",'w',ip);
    skd_par(ip);

    cls_clr(ip[0]);
    if(ip[2]<0) {
      if(ip[1]!=0)
	cls_clr(ip[0]);
      logita(NULL,ip[2],ip+3,ip+4);
      *ierr=-10;
      return -1;
    }
    return 0;
}
