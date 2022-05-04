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
      integer function igetstatnum(c1)
! Check 1 character station ID, and return station #, or 0 if not found.
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'

      character*1 c1    !one character station name

      integer iwhere_in_string_list

      igetstatnum=iwhere_in_string_list(cstcod,nstatn,c1)
      return
      end
