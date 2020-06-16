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
      subroutine find_num_chans_rec(ipass,istn,icode,
     > ifan,nchan_obs,nchan_rec_mk5)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include '../skdrincl/skparm.ftni'

      integer itras

C  INPUT:
      integer ipass,istn,icode
      integer ifan                                 ! fan out factor.
! returned.
      integer nchan_obs,nchan_rec_mk5
! local
      integer isb,ibit,ihd,ichan,it
      integer i

      nchan_obs=0
      do isb=1,2
        do ibit=1,2
          do ihd=1,max_headstack
            do ichan=1,max_chan
              it = itras(isb,ibit,ihd,ichan,ipass,istn,icode)
              if (it.ne.-99) then
                 nchan_obs=nchan_obs+1
              endif
            enddo
          enddo
        enddo
      enddo
! At this point have the number of tracks observed
      nchan_rec_mk5=8                 !can only record in units of 8,16, 32,64
      do i=1,4
         if(nchan_obs*ifan .le.nchan_rec_mk5) goto 5
         nchan_rec_mk5=nchan_rec_mk5*2
      end do
5     continue

      end

