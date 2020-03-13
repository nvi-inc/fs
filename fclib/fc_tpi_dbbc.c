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
void fc_tpi_dbbc__(ip,itpis_dbbc)
int ip[5];
int itpis_dbbc[34];
{
    void tpi_dbbc();

    tpi_dbbc(ip,itpis_dbbc);

    return;
}
    
void fc_tpput_dbbc__(ip,itpis_dbbc,isub,ibuf,nch,ilen)
int ip[5];
int itpis_dbbc[34];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_dbbc(ip,itpis_dbbc,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_dbbc__(ip,itpis_dbbc,ibuf,nch,itask)
int ip[5];
int itpis_dbbc[34];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_dbbc();

    tsys_dbbc(ip,itpis_dbbc,ibuf,nch,*itask);

    return;
}
