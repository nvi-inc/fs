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
/* log formatting for vlba et and rw/ff commands */
#include <string.h>
#include "../include/params.h"
#include "../include/res_ds.h"

void mvdis_v(ip,ibuf,nch)
int ip[5];
char *ibuf;
int *nch;
{
      struct res_buf buffer_out;
      struct res_rec response;
      int some;                 /* did we get anything */

      ibuf[*nch-1]='\0';
      opn_res(&buffer_out,ip);
      get_res(&response, &buffer_out);
      some=FALSE;
      while( response.state != -1) {
        some=TRUE;
        strcat(ibuf,"ack,");
        *nch+=4;
        get_res(&response, &buffer_out);
      }
      if(some) (*nch)--;    /* delete trailing comma */

      clr_res(&buffer_out);
      ip[0]=ip[1]=ip[2]=0;
      return;
}
