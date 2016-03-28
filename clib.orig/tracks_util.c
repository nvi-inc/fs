/* tracks_util.c vlba tracks parsing utilities */

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>
#include "../include/macro.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

int tracks_dec(lcl,count,ptr)
struct vform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(), code;
    static int itrk;

    ierr = 0;
    if(*count==1) {
      lcl->enable.high = 0;
      lcl->enable.low  = 0;
    }

    if(ptr == NULL) {
      *count=-1;
      return ierr;
    }

    if (strcmp(ptr,"v0")==0)
      lcl->enable.high|= 0x00FF;
    else if (strcmp(ptr,"v1")==0)
      lcl->enable.low|= 0x00FF;
    else if (strcmp(ptr,"v2")==0)
      lcl->enable.high|= 0xFF00;
    else if (strcmp(ptr,"v3")==0)
      lcl->enable.low|= 0xFF00;
    else if (strcmp(ptr,"m0")==0)
      lcl->enable.high|= 0x00FE;
    else if (strcmp(ptr,"m1")==0)
      lcl->enable.low|= 0x00FE;
    else if (strcmp(ptr,"m2")==0)
      lcl->enable.high|= 0x7F00;
    else if (strcmp(ptr,"m3")==0)
      lcl->enable.low|= 0x7F00;
    else if (strcmp(ptr,"all")==0) {
      lcl->enable.low = 0xFFFF;
      lcl->enable.high= 0xFFFF;
    } else {
      ierr=arg_int(ptr,&itrk,1,FALSE);
      if(ierr == 0 && (itrk < 2 || itrk > 33))
	ierr = -200;
      if(ierr == 0) {
	if (itrk%2 == 0)
	  lcl->enable.high|= 1 << ((itrk/2)-1);
	else
	  lcl->enable.low|= 1 << ((itrk/2)-1);
      }
    }

   if(*count>0)
     (*count)++;

   return ierr;
}

void tracks_enc(output,count,lcl)
char *output;
int *count;
struct vform_cmd *lcl;
{
    int i;
    static unsigned high, low;

    if (*count == 1) {
      high=lcl->enable.high;
      low=lcl->enable.low;
    }

    output=output+strlen(output);

    for (i=0;i<16;i++)
      if (0 != (high & (1<<i))) {
	sprintf(output,"%d",(i+1)*2);
	high &= ~(1<<i);
	goto done;
      } else if (0 != (low & (1<<i))) {
	sprintf(output,"%d",(i+1)*2+1);
	low &= ~(1<<i);
	goto done;
      }
    
    *count = -1;
  done:
   if(*count>0)
     *count++;

   return;
}
