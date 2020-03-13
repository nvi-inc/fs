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
      integer FUNCTION IGTBA(cband_in)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     Check through all bands for a match with the first character of cband_in
C     RETURN INDEX IN igtba, else a 0.
      character*(*) cband_in

      DO Igtba=1,NBAND
        if(cband_in(1:1) .eq. cband(igtba)(1:1)) return
      end do
      igtba=0
      RETURN
      END
