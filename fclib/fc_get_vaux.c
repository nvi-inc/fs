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
void fc_set_vrptrk__(itrk, ip,indxtp)
int itrk[2];
int ip[5];
int *indxtp;
{
  void set_vrptrk();

  set_vrptrk( itrk, ip, *indxtp);

  return;
}
void fc_get_verate__(jperr,jsync,jbits,itrk,itper,ip)
int jperr[2];
int jsync[2];
int jbits[2];
int itrk[2];
int *itper;
int ip[5];
{
  void get_verate();

  get_verate(jperr,jsync,jbits,itrk,*itper,ip);

  return;
}
void fc_get_vaux__(iaux,itrk,ip)
int iaux[2];
int itrk[2];
int ip[5];
{
  void get_vaux();

  get_vaux(iaux,itrk,ip);

  return;
}
