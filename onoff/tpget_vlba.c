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

int tpget_vlba(ip,itpis_vlba,ierr,tpi) /* get results of tpi */
long ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
int *ierr;
float tpi[MAX_DET]; /* detector value array */
{
    struct res_buf buffer_out;
    struct res_rec response;
    int i;

    opn_res(&buffer_out,ip);

    for (i=0;i<MAX_DET;i++) {
      if(itpis_vlba[ i] == 1) {
	get_res(&response,&buffer_out);
	if(response.code==1)
	  tpi[i]=response.data;
	else
	  tpi[i]=response.code;
      }
    }

    if(response.state == -1) {
       clr_res(&buffer_out);
       *ierr=-11;
       return -1;
    }
    clr_res(&buffer_out);

    return 0;
}

