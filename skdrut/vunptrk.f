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
      SUBROUTINE vunptrk(modef,stdef,km5rec,ivexnum,iret,ierr,lu,
     &     cm,cp,cchref,csm,itrk,nfandefs,ihdn,ifanfac,modu)
      implicit none
C
C     VUNPTRK gets the track assignments and fanout information
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
! Updates newest most recent
! 2021-09-29 JMG Check if LBA station. Has "S2_data_source". If source offset track # by 1
! 2021-05-17 JMG If no track format trudge on and track frame format as "N/A"
! 2021-02-12 JMG Changed limit to 2*max_track.  
! 2021-01-05 JMG replaced variable 'in' with icnt. 'IN' is fortran 90 keyword. 
! 2021-01-05 JMG Changed limit from max_pass to max_track 
! 2019-09-03 JMG. 1) Added implicit none.  Truncate track-frame format to 8 characters
! 2016-01-19 JMG.  Doubled dimension of several variables that had max_track to 2*max_track because now sign& magnitude can be on same track 

C 960520 nrv New.
C 961122 nrv Change fget_mode_lowl to fget_all_lowl
C 970124 nrv Move initialization to start.
C 970206 nrv Change max_pass to max_track as size of arrays in fandefs
C 020327 nrv Get data_modulation.
C 021111 jfq Don't allow track 0 or headstack 0
! 2004Dec8. Changed lm from holerrith to ASCII


!
C
C  INPUT:
      character*128 stdef ! station def to get
      logical km5rec      ! Mark5 recorder?
      character*128 modef ! mode def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
!      integer*2 lm(4) ! recording format      
      character*8 cm
      character*1 cp(max_fandef)      ! subpass
      character*6 cchref(max_fandef)  ! channel ID ref
      character*1 csm(max_fandef)     ! sign/mag
      integer ihdn(max_fandef)        ! headstack number
      integer itrk(max_fandef)        ! first track of the fanout assignment
      integer nfandefs                ! number of def statements
      integer ifanfac                 ! fanout factor determined from list of tracks
      character*3 modu                ! data modulation, on or off
C
C  LOCAL:
      character*128 cout
      integer it(4),j,nn,icnt,i,nch
      integer fvex_len,fvex_int,fvex_field,fget_all_lowl,ptr_ch
      integer is
      integer itrk_off             !add this to track# to make sure >0
      
     
C
C  Initialize
      do icnt=1,max_fandef 
        cp(icnt)=' '
        cchref(icnt)=''
        csm(icnt)=' '
        itrk(icnt)=0
        ihdn(icnt)=0
      enddo
      nfandefs=0
      ifanfac=0

C  1. The recording format
C    
      itrk_off=0 
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     >   ptr_ch('track_frame_format'//char(0)),
     >   ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) then
        is=fvex_len(stdef)
        write(lu,'(a)') 
     >  "VUNPTRK00: Warning no track_frame_format for station "//
     >  stdef(1:is)//" setting to N/A" 
        cm="N/A"  
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     >   ptr_ch('S2_data_source'//char(0)),
     >   ptr_ch('TRACKS'//char(0)),ivexnum)
        if(iret .ne. 0) return
        write(*,*) "Passed 'S2_data_source' check for LBA"
        itrk_off=1            
      endif
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.16) THEN  !
        is=fvex_len(stdef)
        write(lu,'("VUNPTRK01 -  for station ", a,
     >   " track format name too long: ",a, " Using first 16 chars")') 
     >    stdef(1:is), cout(1:nch)
        cm=cout(1:8)       
      else
         cm=cout(1:nch)
      END IF  !

C  1.5 Data modulation
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('data_modulation'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) then ! not there
        modu = "n/a"
      else ! got one
        iret = fvex_field(1,ptr_ch(cout),len(cout))
        NCH = fvex_len(cout)
        IF  (NCH.GT.3.or.NCH.le.0) THEN  !
          write(lu,'("VUNPTRK15 - Data modulation wrong length")')
          iret=-1
        else
          modu = cout(1:nch)
        END IF  !
      endif ! not there/got one
C
C  2. Fanout def statements
C
      ierr = 2
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('fanout_def'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      icnt=0
      do while (icnt.le.max_fandef.and.iret.eq.0) ! get all fanout defs
!      do while (icnt.lt.max_pass.and.iret.eq.0) ! get all fanout defs
        icnt=icnt+1 ! number of fanout defs        
C  2.1 Subpass
        ierr = 21
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get subpass
        if (iret.ne.0) return
        if(icnt .gt. max_fandef) then
           write(*,*) "Vunptrk:  No more space for fanout_def. Max is ",
     &       max_fandef      
           stop
        endif 
        NCH = fvex_len(cout)
        if (nch.ne.1) then
          if(km5rec) then
             cp(icnt)='A'
          else
            ierr = -2
            write(lu,'("VUNPTRK02 - Subpass must be 1 character.")')
          endif
        else
          cp(icnt) = cout(1:1)
        endif
C
C  2.2 Chan ref

        ierr = 22
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get channel ref
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.len(cchref(1)).or.NCH.le.0) THEN  !
          write(lu,'("VUNPTRK03 - Channel ref name too long")')
          ierr=-3
        else
          cchref(icnt) = cout(1:nch)
        ENDIF   

C  2.3 Sign/magnitude

        ierr = 23
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get sign/mag
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        if (cout(1:1).ne.'s'.and.cout(1:1).ne.'m') then
          ierr = -4
          write(lu,'("VUNPTRK04 - Invalid sign/magnitude field.")')
        else
          csm(icnt) = cout(1:1)
        endif

C  2.4 Headstack number
        ierr = 24
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get headstack number
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i) ! convert to binary
        if (i.le.0.or.i.gt.max_headstack) then
          ierr = -5
          write(lu,'("VUNPTRK05 - Invalid headstack number, must be",
     .    "between 1 and ",i3)') max_headstack
        else
          ihdn(icnt) = i
        endif

C  2.5 Track list

        ierr = 25
        do i=1,4
          it(i)=-99
        enddo
        i=5 ! fields 5 through 8 may have tracks
        do while (i.le.9.and.iret.eq.0) ! get tracks
          iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get track
          if (iret.eq.0) then ! a track
            iret = fvex_int(ptr_ch(cout),j) ! convert to binary
            j=j+itrk_off
            if (j.le.0.or.j.gt.max_track) then
              ierr = -6
              write(lu,'("VUNPTRK06 - Invalid track number ",i3,
     .        " must be between 1 and ",i3)') j,max_track
            else
              it(i-4)=j
              if (i.eq.5) itrk(icnt)=j ! save the first one only
            endif
          endif ! a track
          i=i+1
        enddo
        iret = fvex_field(10,ptr_ch(cout),len(cout)) ! get track
        if (iret.eq.0) 
     .  write(lu,'("VUNPTRK16 - Too many fanout tracks, max is 4")')

C       Check for consistent fanout
        nn=0
        do j=1,4
          if (it(j).ne.-99) nn=nn+1 ! count the fanned tracks
        enddo
        if (icnt.eq.1) then 
          ifanfac=nn ! save first fanout value
        else ! check subsequent ones
          if (nn.ne.ifanfac) then
            ierr = -7
            write(lu,'("VUNPTRK07 - Inconsistent fanout defs.")')
          endif
        endif ! save first/check subsequent defs
        
C       Get next fanout def statement
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('fanout_def'//char(0)),
     .  ptr_ch('TRACKS'//char(0)),0)
      enddo ! get all fanout defs
      nfandefs = icnt

      if (ierr.gt.0) ierr=0
      return
      end
