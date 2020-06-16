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
      SUBROUTINE vunproll(modef,stdef,ivexnum,iret,ierr,lu,
     .croll,itrk,inc_period,reinit_period,ndefs,nsteps)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     VUNPROLL gets the barrel roll definitions
C     for station STDEF and mode MODEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 961020 nrv New.
C 970128 nrv Cleanup on initialization. Add max_headstack.
C 020111 nrv Read inc_period and reinit_period. Return more
C            parameters including the tracks.
C
C  INPUT:
      character*128 stdef ! station def to get
      character*128 modef ! mode def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
      character*4 croll ! either 8:1 or 16:1 or off
      integer inc_period,reinit_period
      integer itrk(18,max_roll_def),ndefs,nsteps
C
C  LOCAL:
      character*128 cout
      integer i,it(max_track),j,nn,ifield
      integer fvex_len,fvex_int,fvex_field,fget_all_lowl,ptr_ch
C

C  1. Roll on or off -- not there in version 1.3

      ierr = 1
      croll = '    '
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get roll
      if (fvex_len(cout).gt.4) then
        ierr = -1
        write(lu,'("VUNPROLL01 - Roll must be on or off.")')
      else
        croll = cout(1:fvex_len(cout))
      endif
      if (ierr.gt.0) ierr=0
      if (croll.eq.'off') return ! no more to do
C
C  2. roll_inc_period statement.
C
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll_inc_period'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get period
      ierr = 3
      if (iret.ne.0) return
      iret = fvex_int(ptr_ch(cout),j) ! convert to binary
      if (j.lt.0) then
        ierr=-1
        write(lu,'("VUNPROLL03 - Invalid value for roll_inc_period.")')
      else
        inc_period = j
      endif
C
C  3. roll_reinit_period
C
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll_reinit_period'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get period
      ierr = 3
      if (iret.ne.0) return
      iret = fvex_int(ptr_ch(cout),j) ! convert to binary
      if (j.lt.0) then
        ierr=-1
        write(lu,'("VUNPROLL03 - Invalid value for ",
     .           "roll_reinit_period.")')
      else
        reinit_period = j
      endif
C
C  2. Roll_def statements. Was "roll" statements in version 1.3
C
      ierr = 2
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('roll_def'//char(0)),
     .ptr_ch('ROLL'//char(0)),ivexnum)
      ndefs=0
      do while (ndefs.lt.max_roll_def.and.iret.eq.0) ! get all roll defs
        ndefs=ndefs+1 ! number of roll defs

C  2.1 Headstack. Checked and saved.

        ierr = 21
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get headstack
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),j) ! convert to binary
        if (j.lt.0.or.j.gt.max_headstack) then
          ierr = -1
          write(lu,'("VUNPROLL01 - Only ",i2," headstacks supported.")')
        endif
        itrk(1,ndefs) = j
C
C  2.2 Home track. Checked and saved.

        ierr = 22
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get home track
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),j) ! convert to binary
        IF  (j.lt.0.or.j.gt.max_track) then
          write(lu,'("VUNPROLL03 - Invalid home track.")')
          ierr=-3
        else
          itrk(2,ndefs) = j
        ENDIF

C  2.3 Track list. Checked and counted.

        ierr = 23
        do i=1,max_track
          it(i)=-99
        enddo
        ifield=3 ! fields 3 through maxtrk+2 may have tracks
        do while (ifield.le.max_track+2.and.iret.eq.0) ! get tracks
          iret = fvex_field(ifield,ptr_ch(cout),len(cout)) ! get track
          if (iret.eq.0) then ! a track
            iret = fvex_int(ptr_ch(cout),j) ! convert to binary
            if (j.lt.0.or.j.gt.max_track) then
              ierr = -6
              write(lu,'("VUNPROLL03 - Invalid roll track number ",i3,
     .        "must be between 1 and ",i3)') j,max_track
            else
              it(ifield-2)=j
            endif
          endif ! a track
          ifield=ifield+1
        enddo

C       Check for consistent fanout
        nn=0
        do j=1,max_track
          if (it(j).ne.-99) nn=nn+1 ! count the tracks in the def
        enddo
        if (ndefs.eq.1) then
          nsteps=nn ! save number of tracks in the first roll
C         if (nn.eq.8) then
C           croll='8:1 '
C         else if (nn.eq.16) then
C           croll='16:1'
C         else
C           write(lu,'("VUNPROLL07 - Only roll by 8 or 16 supported.")')
C         endif
        else ! check subsequent ones
          if (nn.ne.nsteps) then
            ierr = -7
            write(lu,'("VUNPROLL03 - Inconsistent roll defs.")')
          endif
        endif ! save first/check subsequent defs

C       Save the roll tracks for this def statement
        do i=1,nsteps
          itrk(i+2,ndefs) = it(i)
        enddo

C       Get next roll def statement
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('roll'//char(0)),
     .  ptr_ch('ROLL'//char(0)),0)
      enddo ! get all roll defs

      if (ndefs.eq.0) croll = 'off '
      if (ierr.gt.0) ierr=0
      return
      end
