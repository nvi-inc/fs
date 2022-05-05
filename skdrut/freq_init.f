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
      subroutine freq_init
! intilize the frequency part
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
! local
      integer ic,is,iv,i,ix

      NCODES = 0
      do ic=1,max_frq
        cmode_cat(ic)=" "
        do is=1,max_stn
          do iv=1,max_chan
            ibbcx(iv,is,ic)=0
            freqrf(iv,is,ic)=0.d0
          enddo
          ntrakf(is,ic)=0
          do i=1,max_band
            trkn(i,is,ic)=0.0
            ntrkn(i,is,ic)=0
            nfreq(i,is,ic)=0
          enddo
        enddo
        lcode(ic)=0
        do ix=1,max_band
          do is=1,max_stn
            wavei(ix,is,ic) = 0.0
            bwrms(ix,is,ic) = 0.0
          enddo
        enddo
      enddo
      return
      end



