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
      integer function iroll_def(istep,idef,istn,icode)
      implicit none  !2020Jun15 JMGipson automatically inserted.

      include '../skdrincl/iroll_def_cmn.ftni'

! passed variables.
      integer istep
      integer idef
      integer icode
      integer istn

! local
      if(iroll_type(istn,icode) .eq. 0) then
        iroll_def=-99
      else
        iroll_def=ibrl_roll(istep,idef,iroll_type(istn,icode))
      endif

      return
      end
! *********************************************************
      subroutine init_iroll_def()
      include '../skdrincl/iroll_def_cmn.ftni'
      integer istn,icode
      num_rolls=0

      do istn=1,max_stn
      do icode=1,max_frq
         iroll_type(istn,icode)=0
      end do
      end do

      return
      end
! ************************************************************
      subroutine init_roll_type(istn,icode,ndefs,nsteps,irtrk)
      include '../skdrincl/iroll_def_cmn.ftni'

! passed
      integer istn,icode,ndefs,nsteps
      integer irtrk(18,32)

! local
      integer iroll
      integer i,j

! see if matches any of the previous rolls.
      do iroll=1,num_rolls
        if(ndefs  .eq. nbrl_defs(iroll) .and.
     >     nsteps .eq. nbrl_steps(iroll)) then
! Possible match. See if all the entries match!
          do i=1,ndefs
            do j=1,2+nsteps
              if (irtrk(j,i).ne.ibrl_roll(j,i,iroll)) goto 100
            end do
          end do
          iroll_type(istn,icode)=iroll
          return
        endif
100     continue                   !no match for this roll type.
      end do

! No match for any of the roll types. Must be a new type.
500   continue
      if(num_rolls .eq. max_rolls) then
        write(*,*)
     >    "Init_roll_type: Exhausted number of allowed barrel rolls!"
        write(*,*) "Current maximum is: ", max_rolls
        write(*,*)
     >    "Change max_rolls in skdrincl/iroll_def_cmn.ftni"
        stop
       endif

      num_rolls=num_rolls+1
      iroll_type(istn,icode)=num_rolls

      nbrl_defs(num_rolls)=ndefs
      nbrl_steps(num_rolls)=nsteps
      do i=1,ndefs
        do j=1,2+nsteps
            ibrl_roll(j,i,num_rolls)=irtrk(j,i)
        end do
      end do
      return
      end
