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
      program boss
cxx      implicit none
c
      include '../include/fscom.i'
c
      integer ifsnum
      parameter (ifsnum=1024)
      integer*4 ip(5)
      dimension lnames(13,ifsnum)
      integer*4 lproc1(10,MAX_PROC1),lproc2(10,MAX_PROC2)
      integer*4 itscb(13,15)
      integer idcbsk(2)
      integer ntscb,maxpr1,maxpr2,nnames,ierr,idum,fc_rte_prior
      data ntscb/15/
C                     Number of available entries in ITSCB
      data maxpr1/MAX_PROC1/, maxpr2/MAX_PROC2/
C                     Number of entries in each proc list
      data nnames/ifsnum/
C                     Maximum number of entries available in LNAMES
C
      call setup_fscom
      call read_fscom
      call fmperror_standalone_set(0)
      call wait_prog('boss ',ip)
      idum=fc_rte_prior(FS_PRIOR)
C
      call binit(ip,lnames,nnames,itscb,ntscb,idcbsk,ierr)
      if (ierr.ne.0) goto 900
      call bwork(ip,lnames,nnames,lproc1,maxpr1,lproc2,maxpr2,
     .           itscb,ntscb,idcbsk)
900   continue

C  HARI-KIRI

      call fs_set_abend_normal_end(1)
      call fc_exit( 0)
      end
