/* **************************************************************
 *  This routine will parse the TAC buffer.
 ****************************************************************/
#include <sys/types.h>
#include <stdio.h>
#include <string.h>


#include "../include/fs_types.h"      /* general header file for all fs data
                                       * structure definations */
#include "../include/params.h"        /* general fs parameter header */
#include "../include/fscom.h"         /* shared memory (fscom C data 
                                       * structure) layout */
#include "../include/shm_addr.h"      /* declaration of pointer to fscom */

int
parse_it(char buf2[], int item)
{

  /*printf("%s",buf2);*/
  switch (item) {
  case 0:
    sscanf(&buf2[21],"%s,%s",
	   &shm_addr->tacd.file,
	   &shm_addr->tacd.status);
    break;
  case 1:
    sscanf(&buf2[20],"%f,%f,%d,%d,%f,%f",
	   &shm_addr->tacd.day_frac,
	   &shm_addr->tacd.msec_counter,
	   &shm_addr->tacd.usec_correction,
	   &shm_addr->tacd.nsec_accuracy,
	   &shm_addr->tacd.usec_bias,
	   &shm_addr->tacd.cooked_correction);
    break;
  case 2:
    sscanf(&buf2[36],"%d,%f,%f,%f,%f",
	   &shm_addr->tacd.sec_average,
	   &shm_addr->tacd.rms,
	   &shm_addr->tacd.usec_average,
	   &shm_addr->tacd.max,
	   &shm_addr->tacd.min);
    break;
  default:
  }
  return(0);
}
