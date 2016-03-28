/* detector lookup for radiometry, returns request buffer to sample detector */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"

static char nums[ ] = {"123456789abcdefg"}; /* possible bbc's */

void dtlkup(request,device, ierr)
struct req_rec *request;               /* request record to set-up */
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
{
    char *ptr;
    int found;

    request->type=1;
    found=FALSE;
                                       /* with a real 16 bit address */

    if(0==strncmp(device,"ia",2)) {    /* check for each possible if detector */
      memcpy(request->device,"ia",2);
      request->addr=0x06;
      found=TRUE;
    } else if(0==strncmp(device,"ib",2)) {
      memcpy(request->device,"ia",2);
      request->addr=0x07;
      found=TRUE;
    } else if(0==strncmp(device,"ic",2)) {
      memcpy(request->device,"ic",2);
      request->addr=0x06;
      found=TRUE;
    } else if(0==strncmp(device,"id",2)) {
      memcpy(request->device,"id",2);
      request->addr=0x07;
      found=TRUE;
    } else {                             /* maybe it's a bbc */
      ptr=strchr(nums,device[0]);
      if(ptr!=NULL && *ptr != '\0') {
        request->device[0]='b';
        request->device[1]=device[0];
        if(device[1] == 'u') {          /* (u)pper and (l)ower SB detectors */
           request->addr=0x06;
           found=TRUE;
        } else if(device[1] == 'l') {
           request->addr=0x07;
           found=TRUE;
        }
      }
    }

    if(! found) {
      *ierr=-1;            /* no such device */
      return;
    }
    *ierr=0;               /* okay */
    return;
}
