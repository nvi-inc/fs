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
void fc_vget_att__(lwho,ip,ichain1,ichain2)
char lwho[2];
int ip[5];
int *ichain1,*ichain2;
{
    void vget_att();

    vget_att(lwho,ip,*ichain1,*ichain2);
    return;
}
void fc_vset_zero__(lwho,ip)
char lwho[2];
int ip[5];
{
    void vset_zero();

    vset_zero(lwho,ip);
    return;
}
void fc_vrst_att__(lwho,ip)
char lwho[2];
int ip[5];
{
    void vrst_att();

    vrst_att(lwho,ip);
    return;
}
