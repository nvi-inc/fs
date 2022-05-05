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
void fc_tpi_norack__(ip,itpis_norack)
int ip[5];
int itpis_norack[2];
{
    void tpi_norack();

    tpi_norack(ip,itpis_norack);

    return;
}
    
void fc_tpput_norack__(ip,itpis_norack,isub,ibuf,nch,ilen)
int ip[5];
int itpis_norack[2];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_norack(ip,itpis_norack,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_norack__(ip,itpis_norack,ibuf,nch,itask)
int ip[5];
int itpis_norack[2];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_norack();

    tsys_norack(ip,itpis_norack,ibuf,nch,*itask);

    return;
}
