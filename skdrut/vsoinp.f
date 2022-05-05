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
      SUBROUTINE VSOINP(ivexnum,lu,ierr)
C
C     This routine gets all the source information
C     and stores it in common.
C **NOTE** No satellite support yet.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'

      include '../skdrincl/sourc.ftni'
C
C History:
C 960527 nrv New.
C 970114 nrv Change 8 to max_sorlen
C 971003 nrv Suppress messages from the IAU name checker
C 990606 nrv Store IAU name.
C 2003Dec09 JMGipson replace holleriths by characcters.
! 2006Nov18.  Got rid of residual holleriths.
! 2007Jul02. Moved moved sordefnames from sourc.ftni to here (only used here).
!            Renamed to csrc_name

C
C INPUT:
      integer ivexnum ! vex file number 
      integer lu ! unit for writing error messages
C
C OUTPUT:
      integer ierr ! error number, non-zero is bad

! functions
      integer iwhere_in_string_list
      integer julda
C
C LOCAL:
      integer iret ! return from vex routines
      double precision tjd ! for APSTAR
      integer isor,ierr1,iep,j,il
      character*128 cout
      integer ptr_ch,fget_source_def,fvex_len
      character*(max_sorlen) ciau,ccom,cname
      character*128 csrc_names(max_sor)
      double precision RARAD,DECRAD,r,d
C
C     1. First get all the def names 
C
      ierr1=0
      nsourc=0
      cout=" "
      iret = fget_source_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        IF  (nsourc.eq.MAX_SOR) THEN  !
          write(lu,'("VSOINP20: Too many sources. Max is",i3)') Max_sor
          write(lu,'("          Ignored:  ",a)') cout
        else
          nsourc=nsourc+1
          csrc_names(nsourc)=cout
          cout=" "
          iret = fget_source_def(ptr_ch(cout),len(cout),0) ! get next one
        END IF 
      enddo

C     2. Now call routines to retrieve all the source information.

      nceles = 0
      nsatel = 0
      do isor=1,nsourc ! get each source information
        CALL vunpso(csrc_names(isor),ivexnum,iret,ierr,lu,
     .  ciau,ccom,RARAD,DECRAD,iep)
        if (ierr.ne.0) then 
          il=fvex_len(csrc_names(isor))
          write(lu,'("VSOINP01: Error getting $SOURCE information for ",
     >     a,"iret=",i5," ierr=",i5)')
     >       csrc_names(isor)(1:il),  iret,ierr
          call errormsg(iret,ierr,'SOURCE',lu)
          ierr1=1
        endif
C
C     3. Decide which source name to use.  If there is a common
C     name, use that, otherwise use the IAU name.  If IAU is blank,
C     then make both the same.
C
        if (ierr1.eq.0) then ! continue
        if (ciau .eq. " ") then ! use common name
          cname=ccom
        else
          cname=ciau
          if(ccom .ne. "$") cname=ccom
        endif
C
C     Then check for a duplicate name.  This should not happen
C     in the SKED environment but might as well check.
C     Check up to those source names found so far (isor-1).
        j=iwhere_in_string_list(csorna,isor,cname)
        IF  (j.ne.0) then ! duplicate source
          write(lu,9101) csorna(isor)
9101      format('VSOINP22 - Duplicate source name ',a,
     .    '. Using the position of the first one.')
        endif ! duplicate source
C
C     2. Move the new variables into place.
C
        NCELES=NCELES+1
        IF  (NCELES.GT.MAX_CEL) THEN  !"celestial overflow"
          write(lu,9201) max_cel
9201      format('SOINP02 - Too many celestial sources.  Max is 'i3)
          RETURN
        ENDIF
C
         ciauna(nceles)= ciau
         csorna(nceles)= cname

        IF  (iep.NE.2000) THEN  !"convert to J2000"
          IF  (IEP.EQ.1950) THEN ! reference frame rotation
            call prefr(rarad,decrad,1950,r,d)
            RARAD = R
            DECRAD = D
          ELSE  ! full precession
            tjd=julda(1,1,iep-1900)+2440000.d0
            call mpstar_rad(tjd,rarad,decrad)
          END IF  !
        END IF  !"convert to J2000"
        SORP50(1,NCELES) = RARAD   !J2000 position
        SORP50(2,NCELES) = DECRAD  !J2000 position
        endif ! continue
C
      enddo ! get each source information

      ierr=ierr1
      RETURN
      END
