/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
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
0123456789012345678901234567890123
form         qkr 0101 01 001FFFFFF

     */
    printf("%12.12s",buf);
    sscanf(buf+25,"%3x",&rack);
    sscanf(buf+28,"%3x",&drive1);
    sscanf(buf+31,"%3x",&drive2);
    if(rack == 0xFFF &&drive1 == 0xFFF && drive2 == 0xFFF) {/* all */
      printf(" all");
    } else if (drive1 == 0xFFF && drive2 == 0xFFF) {/* rack command */
      printf(" rack");
      what(rack);
    } else if(rack == 0xFFF && drive2 == 0xFFF) { /* drive1 */
      printf(" drive1");
      what(drive1);
    } else if(rack == 0xFFF && drive1 == 0xFFF) { /* drive2 */
      printf(" drive2");
      what(drive2);
    }
    
    printf("\n");
  }
}
what(rack)
{
      if(has(rack,MK3))
	printf(" mk3");
      if(has(rack,S2))
	printf(" s2");
      if(has(rack,VLBA))
	printf(" vlba");
      if(has(rack,MK4))
	printf(" mk4");
      if(has(rack,MK5))
	printf(" mk5");
      if(has(rack,LBA))
	printf(" lba");
      if(has(rack,LBA4))
	printf(" lba4");
      if(has(rack,VLBA4))
	printf(" vlba4");
      if(has(rack,K4))
	printf(" k4");
      if(has(rack,K4K3))
	printf(" k4k3");
      if(has(rack,K4MK4))
	printf(" k4mk4");
}
