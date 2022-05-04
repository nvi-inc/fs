*
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
*
c fscom.i
c
c  This include file includes all the sections of fscom.
c  By convention each section is a named common block with a name of the
c  form 'fscom_x' where 'x' is the name of the section, e.g. 'fscom_init'
c  for the initialization section.
c
c  Each part must have as its first and last variables, integers (no *)
c  with names of the form 'b_x' and 'e_x' respectively (b for begin,
c  e for end), where 'x' again is the name of the section.
c
c  See fscom_init.i for an example.
c
      include 'params.i'
      include 'fscom_init.i'
      include 'fscom_quik.i'
      include 'fscom_dum.i'
