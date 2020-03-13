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
void fc_mcbcn_d2__(device1,device2,ierr,ip)
char device1[2],device2[2];
int *ierr;
int ip[5];
{
    void mcbcn_d2();

    mcbcn_d2(device1,device2,ierr,ip);
    return;
}
void fc_mcbcn_v2__(dtpi1,dtpi2,ip)
double *dtpi1,*dtpi2;
int ip[5];
{
    void mcbcn_v2();

    mcbcn_v2(dtpi1,dtpi2,ip);
    return;
}
void fc_mcbcn_r2__(ip)
int ip[5];
{
    void mcbcn_r2();

    mcbcn_r2(ip);
    return;
}
