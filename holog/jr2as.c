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
#include <stdlib.h>
#include <string.h>

void jr2as(re,lbuf,it,id,isbuf)
     float re;
     char lbuf[];
     int it,id,isbuf;
{
  int ita, icn;

  icn=strlen(lbuf);
  flt2str(lbuf,re,it,id);
  if(lbuf[icn]!='$')
    return;
  ita=abs(it)+abs(id)+1;
  ita=ita<isbuf-(icn+1)?ita:isbuf-(icn+1);
  lbuf[icn]=0;
  flt2str(lbuf,re,ita,id);
  lbuf[icn+abs(it)]=0;
}     
