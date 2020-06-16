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
      integer function isecdif(idayr1,ihr1,min1,isc1,
     .                         idayr2,ihr2,min2,isc2)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C  ISECDIF computes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).
      include '../skdrincl/skparm.ftni'

C 960810 nrv New utility for snap.f
C 990326 nrv Allow for year rollover by checking whether nd<0.
C 990716 nrv Implement the change!
C 990924 nrv Utility for sked's vscout.f. Add skparm.ftni and
C            make t1,t2 double.

C Input:
      integer idayr1,ihr1,min1,isc1,idayr2,ihr2,min2,isc2
C Local:
      integer idt,idd
      double precision t1,t2

      t1 = ihr1*3600.d0 + min1*60.d0 + isc1*1.d0
      t2 = ihr2*3600.d0 + min2*60.d0 + isc2*1.d0
      idd = idayr1-idayr2
      idt = t1-t2 + idd*3600.d0*24.0
      isecdif = idt

      return
      end
