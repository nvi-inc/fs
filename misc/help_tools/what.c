#include <stdio.h>

#define has(x,y)   ((x & y)==y)
#include "../../include/params.h"

main()
{
  FILE *fptr;
  char buf[80], *ptr;
  int hex, rack, drive1, drive2;

  fptr=fopen("../../control/fscmd.ctl","r");

  if (fptr == NULL) {
    perror("opening fserr.ctl");
    exit(-1);
  }

  while (NULL!=(ptr=fgets(buf,sizeof(buf),fptr))) {
    if(buf[0]=='*')
      continue;
    /*
          1         2         3
0123456789012345678901234567890
form         qkr 0101 01 01FFFF
     */
    printf("%12.12s",buf);
    sscanf(buf+25,"%6x",&hex);
    rack=(hex>>16)&0xFF;
    drive1=(hex>>8)&0xFF;
    drive2=(hex>>0)&0xFF;
    if(rack == 0xFF &&drive1 == 0xFF && drive2 == 0xFF) {/* all */
      printf(" all");
    } else if (drive1 == 0xFF && drive2 == 0xFF) {/* rack command */
      printf(" rack");
      if(has(rack,MK3))
	printf(" mk3");
      if(has(rack,VLBA))
	printf(" vlba");
      if(has(rack,MK4))
	printf(" mk4");
      if(has(rack,VLBA4))
	printf(" vlba4");
      if(has(rack,K4))
	printf(" k4");
      if(has(rack,K4K3))
	printf(" k4k3");
      if(has(rack,K4MK4))
	printf(" k4mk4");
    } else if(rack == 0xFF && drive2 == 0xFF) { /* drive1 */
      printf(" drive1");
      if(has(drive1,MK3))
	printf(" mk3");
      if(has(drive1,VLBA))
	printf(" vlba");
      if(has(drive1,MK4))
	printf(" mk4");
      if(has(drive1,VLBA4))
	printf(" vlba4");
      if(has(drive1,S2))
	printf(" s2");
      if(has(drive1,K4))
	printf(" k4");
    } else if(rack == 0xFF && drive1 == 0xFF) { /* drive2 */
      printf(" drive2");
      if(has(drive2,MK3))
	printf(" mk3");
      if(has(drive2,VLBA))
	printf(" vlba");
      if(has(drive2,MK4))
	printf(" mk4");
      if(has(drive2,VLBA4))
	printf(" vlba4");
      if(has(drive2,S2))
	printf(" s2");
      if(has(drive2,K4))
	printf(" k4");
    }
    
    printf("\n");
  }
}
