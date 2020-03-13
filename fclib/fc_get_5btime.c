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
int fc_get_5btime__(centisec,fm_tim,ip,to,m5sync,m5pps,m5freq,m5clock,
		    sz_m5sync,sz_m5pps,sz_m5freq,sz_m5clock)
int centisec[6];
int fm_tim[6];
int ip[5];
int *to;
char *m5sync;
int sz_m5sync;
char *m5pps;
int sz_m5pps;
char *m5freq;
int sz_m5freq;
char *m5clock;
int sz_m5clock;
{

  return get_5btime(centisec,fm_tim,ip,*to,m5sync,sz_m5sync,m5pps,sz_m5pps,
		    m5freq,sz_m5freq,m5clock,sz_m5clock);

}
