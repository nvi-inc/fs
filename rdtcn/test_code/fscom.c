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
/* fscim dump utility */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;
struct fscom *fs;

int main(int argc, char *argv[])
{
  struct rdbe_tsys_cycle local[MAX_RDBE];
  int iping, i, j;

  setup_ids();
  fs = shm_addr;
  /*
  for(i=0;i<MAX_RDBE;i++)
    for(j=0;j<2;j++)
      fs->rdbe_tsys_data[i].data[j].pcal_phase[418]=0;
  */
  for(i=0;i<MAX_RDBE;i++) {
    iping=fs->rdbe_tsys_data[i].iping;
    if(iping < 0 || iping > 1)
      continue;
    
    memcpy(&local[i],
	   &fs->rdbe_tsys_data[i].data[iping],
	   sizeof(struct rdbe_tsys_cycle));      
    
    printf(" iping %d RDBE %d DOT %s IF %d ",
	   iping,i,local[i].epoch,local[i].pcal_ifx);
    for (j=415;j<421;j++) {
      int word;
      memcpy(&word,local[i].pcal_phase+j,sizeof(word));
      printf(" j %d phase %15f hex %x ",
	     j,local[i].pcal_phase[j],word);
    }
    printf("\n");
  } 
  
  return 0;
}
