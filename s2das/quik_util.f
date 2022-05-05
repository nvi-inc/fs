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
      subroutine get_quik_parnf( rep , intp , cutoff , step )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      integer rep, intp
      real*8  cutoff, step
c
      rep  = nrepnf
      intp = intpnf
c
      cutoff = ctofnf
      step   = stepnf
c
      return
      end
      subroutine get_quik_devnf( dev )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      integer*2 dev(1)
c
      dev(1) = ldv1nf
      dev(2) = ldv2nf
c
      return
      end
      subroutine get_quik_bwsnf( beamwidth )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 beamwidth(1)
c
      beamwidth(1) = bm1nf_fs
      beamwidth(2) = bm2nf_fs
c
      return
      end
      subroutine get_quik_calnf( caltemp )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 caltemp(1)
c
      caltemp(1) = cal1nf
      caltemp(2) = cal2nf
c
      return
      end
      subroutine get_quik_caltmp( caltemp , index )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 caltemp
      integer index
c
      caltemp = caltmp(index)
c
      return
      end
      subroutine get_quik_flxnf( flux )
c
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
      real*8 flux(1)
c
      flux(1) = fx1nf_fs
      flux(2) = fx2nf_fs
c
      return
      end







