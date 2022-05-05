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
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
  int ierr;
  char buf[512];

  setup_ids();

  putpname("lgerr");

  if (nsem_test("fs   ") != 1) {
    printf("fs isn't running\n");
    exit(-1);
  }
  if (argc <= 1) {
    sprintf(buf,"lgerr: no information provided");
    logite(buf,-1,"lg");
    exit(-1);
  }

  if(argc>=3)
    if(1!=sscanf(argv[2],"%d",&ierr)) {
      sprintf(buf,"lgerr: error decoding '%s'",argv[2]);
      logite(buf,-1,"lg");
      exit(-1);
    }

  if(argc==2)
    logit(argv[1],0,NULL);
  else if(argc==3)
    logit(NULL,ierr,argv[1]);
  else if(argc==4)
    logite(argv[3],ierr,argv[1]);

  exit(0);
    
}


