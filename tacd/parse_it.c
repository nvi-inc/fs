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
  int no_value[20],i,j,k,l;
  char tmp[20][80];
  char buff[120];

  /* 
   * The string might have a series of commas, so we need to place
   * 0's (zeros) in there place. Remember, this does not indicate a
   * 0 (zero) value it indicates that the value is not present.
   * This will make it easier for sscanf to parse the values. 
   * A bit messy.
   */
  for(i=0;i<20;i++) {
    no_value[i]=3384;
    tmp[i][0] = '\0'; 
  }
  j=k=l=0;
  no_value[0] = 1;
  for(i=0; buf2[i] != '\r' && buf2[i] != '\n'; i++) {
    if(buf2[i] == ',') {
      tmp[l][j] = '\0';
      j=0;
      l++;
	if(buf2[i+1] == ',') {
	  no_value[++k] = -1;
	} else {
	  no_value[++k] = 1;
	}
    } else { 
      tmp[l][j] = buf2[i];
      j++;
    }
  }
  tmp[l][j] = '\0';
  no_value[k] = 1;

  switch (item) {
  case 0:
    if(no_value[3]==1) sscanf(tmp[3],"%s",&shm_addr->tacd.file);
    if(no_value[4]==1) sscanf(tmp[4],"%s",&shm_addr->tacd.status);
    break;
  case 1:
    if(no_value[3]==1) sscanf(tmp[3],"%f",&shm_addr->tacd.day_frac);
    if(no_value[4]==1) sscanf(tmp[4],"%f",&shm_addr->tacd.msec_counter);
    if(no_value[5]==1) sscanf(tmp[5],"%d",&shm_addr->tacd.usec_correction);
    if(no_value[6]==1) sscanf(tmp[6],"%d",&shm_addr->tacd.nsec_accuracy);
    if(no_value[7]==1) sscanf(tmp[7],"%f",&shm_addr->tacd.usec_bias);
    if(no_value[8]==1) sscanf(tmp[8],"%f",&shm_addr->tacd.cooked_correction);
    break;
  case 2:
    if(no_value[4]==1) sscanf(tmp[4],"%d",&shm_addr->tacd.sec_average);
    if(no_value[5]==1) sscanf(tmp[5],"%f",&shm_addr->tacd.rms);
    if(no_value[6]==1) sscanf(tmp[6],"%f",&shm_addr->tacd.usec_average);
    if(no_value[7]==1) sscanf(tmp[7],"%f",&shm_addr->tacd.max);
    if(no_value[8]==1) sscanf(tmp[8],"%f",&shm_addr->tacd.min);
    break;
  default:
  }
  return(0);
}
