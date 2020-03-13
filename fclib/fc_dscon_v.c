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
void fc_dscon_d__(device,ierr,ip)
char device[2];
int *ierr;
int ip[5];
{
    void dscon_d();

    dscon_d(device,ierr,ip);
    return;
}
void fc_dscon_v__(dtpi,ip)
double *dtpi;
int ip[5];
{
    void dscon_v();

    dscon_v(dtpi,ip);
    return;
}
