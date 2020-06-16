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
      double precision function dsecdif(mjd1,ut1,mjd2,ut2)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C  ISECDIF coputes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).

C 970317 nrv New utility for sked.
C 2003Jun20 JMGipson. Simplified. Version made for double precision.

C Input:
      integer mjd1,mjd2
      double precision ut1,ut2
C Local:
!     integer ihr1,min1,isc1,ihr2,min2,isc2
!     integer nd,nh,nm,ns,nsdif

      dsecdif=(mjd1-mjd2)*86400.+(ut1-ut2)
      return
      end
