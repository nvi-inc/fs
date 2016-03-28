/* rdbe dbe_tsys parsing util */

#include <stdio.h>
#include <string.h>

#include "../include/params.h"

int rdbe_2_tsysx(char *buf, int *ifc, long ip[5], long on[],long off[], char *who)
{
  char *ptr;
  long value;
  int i, ierr;

  ptr=strtok(buf,"?");
  if(NULL==ptr) {
    ierr=-501;
    goto error;
  }

  for(i=0;i<2;i++) {  /* parse return code and channel */
    ptr=strtok(NULL,":");
    if(1!=sscanf(ptr,"%d",&value)) {
      ierr=-501;
      goto error;
    }
    switch (i) {
    case 0:
      if(value!=0) {
	ierr=-502;
	goto error;
      }
      break;
    case 1:
      *ifc=value;
      break;
    default:
      ierr=-503;
      goto error;
      break;
    }
  }

  for(i=0;i<2*MAX_RDBE_CH;i++) { /*parse values: on, then off */
    ptr=strtok(NULL,":;");
    if(ptr==NULL) {
	ierr=-504;
	goto error;
    }

    if(1!=sscanf(ptr,"%d",&value)) {
      ierr=-501;
      goto error;
    }
    
    if(i<MAX_RDBE_CH)   /* diode on */
      on[i]=value;
    else          /* diode off */
      off[i-MAX_RDBE_CH]=value;
  }
  return 0;

 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"2t",2);
  memcpy(ip+4,who,2);
  return -1;

}
