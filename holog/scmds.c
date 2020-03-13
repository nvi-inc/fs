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
#include <signal.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

void scmds(mess,azo,elo)
     char *mess;
     double azo,elo;
{
  int ip[5];
  char buff[512];
  int ic;


  ic=snprintf(buff,sizeof(buff),"%sp=%+.3f_%+.3f",
	      mess,azo*RAD2DEG,elo*RAD2DEG);
  if(ic>=(int)sizeof(buff)) {
    buff[sizeof(buff)-1]=0;
    ip[0]=0;
    ip[1]=0;
    ip[2]=-6;
    memcpy(ip+3,"hl",2);
    ip[4]=0;
    logita(NULL,ip[2],ip+3,ip+4);
  } else if (ic < 0) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=-5;
    memcpy(ip+3,"hl",2);
    ip[4]=0;
    logit(NULL,errno,"un");
    logita(NULL,ip[2],ip+3,ip+4);
  } else {

    scmd(buff);

  }

  return;
}
