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
      subroutine proc_mk5_init1(ntrack_obs,ntrack_rec_mk5,luscn,ierr)
      include 'hardware.ftni'
! passed
      integer ntrack_obs       !number of tracks we normally record on
      integer ntrack_rec_mk5   !number we actually used  in mk5 (must be 8,16,32 or 64
      integer luscn            !LU to output error messages (normally the screen).
! returned
      integer ierr             !some error
! history
! 2007Dec11 JMGipson.  Fixed  bug in format statement
! 2014Jan30 JMGipson.  Removed some piggyback stuff. 
! 2014Dec06 JMGipson. Support Mark5C
! 2018Sep05 JMGipson. Got rid of trailing '"' on comments. 

      ierr=0  

! Put some instructions out for MK5 recorders.
      if(km5B.or. km5c) then
        continue  
      else if(km5A .or. knorec(1)) then 
! setup for number of tracks observed and recorded.
        if(ntrack_obs .lt. 4) then
           write(luscn,'(/,a)')
     >       "PROC_MK5_INIT1: Too few tracks in Mk5 mode!"
           write(luscn,*) "Minimum number is 4. We have ",ntrack_obs
           ierr=102
           return
        else if(ntrack_rec_mk5 .gt. 32 .and. kvrack) then
         write(luscn,'(/,a)')"PROC_MK5_INIT1: Too many tracks for VLBA!"
         write(luscn,'(a,i4)') "Maximum is 32. We have ",ntrack_rec_mk5
         ierr=103
        endif
! put commands in setup.
        if(km4form) then
          if(knorec(1))
     >    write(lufile, 90) "If you have a Mark5A recorder" 
          write(lufile,90) "Connect the Set 1 Mark5A recorder input to"          
          write(lufile,90) "the headstack 1 output of the formatter"          
          if(ntrack_rec_mk5 .gt. 32) then
             write(lufile,90)
     >          "Connect the Set 2 Mark 5A recorder input to"
             write(lufile,90)
     >          "the headstack 2 output of the formatter"
          endif
        else if(kvrack) then
           write(lufile,90)"Connect the Set 1 Mark5A recorder input to"          
           write(lufile,90)"the first recorder output of the formatter"           
        endif
      endif
      return
90    format('"',a)
      end
