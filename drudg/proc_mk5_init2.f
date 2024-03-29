*
* Copyright (c) 2020-2021 NVI, Inc.
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
      subroutine proc_mk5_init2(lform,
     >   ifan,samprate,ntrack_rec_mk5,luscn,ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
! History:
!  2014Dec06 JMG  Added Mark5C support
!  2015Jun05 JMG  Replaced drudg_write by drudg_write.
!  2016May07 WEH  Bank_check if only 2 Gbps or less
!  2016Sep08 JMG  For Mark5c and >2GBS output jiveab commands
!  2017Dec20 JMG  Added 'mk5=bank_set?' after bank_check.
! 2021-12-04 JMGipson removed km5_piggy stuff 
! passed
      character*5 lform        !Form descriptor
      integer ifan              !fanout
      real   samprate
      integer luscn             !LU to output error messages (normally the screen).
      integer ntrack_rec_mk5    !number of tracks recorded.
! returned
      integer ierr             !some error
! local
      integer idrate
      character*50 ldum
      integer itemp

      ierr=0
      if(ifan .gt. 1) then
         idrate=samprate/ifan   !idrate is the data rate.
      else
         idrate=samprate
      endif
      if(.not. (km5b .or. km5c)) then             !skip below for Mark5B
! Put some instructions out for MK5 recorders.
        write(ldum,'("mk5=play_rate=data:",i4,";")') idrate
        call drudg_write(lufile,ldum)

!        if(km5p_piggy) then
!           itemp=32
!        else
           itemp=ntrack_rec_mk5
!        endif
        write(ldum,'("mk5=mode=",a,":",i2,";")')lform,itemp
        call drudg_write(lufile,ldum)
      endif
      if(.not. kflexbuff .and. .not.
     &     (km5c .and. idrate*ntrack_rec_mk5.gt.2048)) then
         write(lufile,'("bank_check")')
         write(lufile,'("mk5=bank_set?")')
      endif

      if(km5c .and. .not.kflexbuff) then
!        if(idrate*ntrack_rec_mk5.gt.2048) then
          write(lufile,'("mk5=vsn?")')
          write(lufile,'("mk5=disk_serial?")')
!        endif
      endif
      end

