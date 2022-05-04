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
      SUBROUTINE vunpif(modef,stdef,ivexnum,iret,ierr,lu,
     &   cifref,flo,cs,cin,cp,fpcal,fpcal_base,nifdefs)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     VUNPIF gets the IFD def statements
C     for station STDEF and mode MODEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
! functions
      integer iwhere_in_string_list
      character upper
      integer fvex_len,fvex_field,ptr_ch,fvex_double
      integer fvex_units,fget_all_lowl
C
C  History:
! 2021-01-31 JMG Accept more polarizations and translate them. H, X-->L,  V, Y -->R
! 2021-01-14 JMG Added in 8 valid DBBC3 IFs which were not in DBBC list.
! 2012-09-17 JMG Added in 16 vaild DBBC IFs: A1...A4, B1..B4.. D4
!            JMG Issue warning message if not recognized, but leave alone. 
C 960522 nrv New.
C 970114 nrv For Vex 1.5 get IF name from def directly instead of ref name,
C            and add polarization to call.
C 970124 nrv Move initialization to front.
C 971208 nrv Add phase cal spacing and base frequency.
C 990910 nrv Change default LO value to -1.0 meaning none.
C 991110 nrv Allow IF type 3N to be valid.
! 2004Oct19 JMGipson.  Removed warning message if LO was negative.
! 2006Oct06 JMGipson.  changed ls,lin,lp --> (ASCII) cs,cin,cp
!                      Made IF="1" a valid choice. An S2 VEX schedule had this.

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
      character*6 cifref(max_ifd) ! IFD refs
      double precision flo(max_ifd) ! LO frequencies
      double precision fpcal(max_ifd) ! pcal frequencies
      double precision fpcal_base(max_ifd) ! pcal_base frequencies
      character*2 cs(max_ifd) ! sideband of the LO
      character*2 cin(max_ifd) ! IF input channel
      character*2 cin_tmp
      character*2 cp(max_ifd) ! polarization
      integer iwhere                !where in a list.
      integer nifdefs ! number of IFDs found


      integer num_valid_if
      parameter (num_valid_if=37)
      character*2 cvalid_if(num_valid_if)

C
C  LOCAL:
      character*128 cout,cunit
      double precision d
      integer id,nch
       
      data cvalid_if/"A", "B", "C", "D", "1",     !5
     >   "1N","1A","2N","2A","3N","3A","3O","3I", !8
     >   "A1","A2","A3","A4","B1","B2","B3","B4", !8   DBBC
     >   "C1","C2","C3","C4","D1","D2","D3","D4", !8   DBBC
     >   "E1","F1","G1","H1","E2","F2","G2","H2"/ !8   DBBC3 which are not in DBBC

C
C  Initialize
      nifdefs=0
      do id=1,max_ifd
        cifref(id)=''
        flo(id)=-1.d0 ! defaults to no LO
        fpcal(id)=-1.d0 ! defaults to off
        fpcal_base(id)=0.d0
        cs(id)=" "
        cp(id)=" "
        cin(id)=" "
      enddo
C
C  1. IFD def statements
C
      ierr = 1
C ** this should work with fget_mode_lowl but doesn't seem to
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     >  ptr_ch('if_def'//char(0)),ptr_ch('IF'//char(0)),ivexnum)
      id=0
      do while (id.lt.max_ifd.and.iret.eq.0) ! get all IF defs
        id=id+1

C  1.1 IF def

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cifref(id)).or.nch.le.0) then
          ierr=-1
          write(lu,'("VUNPIF01 - IFD ref too long")')
        else
          cifref(id)=cout(1:nch)
        endif

C  1.2 IF input

        ierr = 12
        iret = fvex_field(2,ptr_ch(cout),len(cout)) ! get input
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.ne.1.and.nch.ne.2) then
          ierr=-2
          write(lu,'(a)')
     >       "VUNPIF04 - IF input must be 1 or 2 characters"
        else
          cin(id)=cout(1:nch)
          cin_tmp=cin(id)
          call capitalize(cin_tmp)
          iwhere=iwhere_in_string_list(cvalid_if,num_valid_if,cin_tmp)
          if(iwhere .eq. 0) then
            write(lu,'("VUNPIF05: Warning. Unrecognized IF ",a)')
     >        cin(id)
          endif
        endif

C  1.3 Polarization
        ierr = 13
        iret = fvex_field(3,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        cout(1:1) = upper(cout(1:1))
        cp(id)=cout(1:1) 
        If(nch .eq. 0) then 
          write(lu,'(a)') "VUNPIF05: No polarization!" 
        else if(nch .ne.1) then 
          write(lu,'(a)') "VUNPIF06: Invalid polarization "//cout(1:nch)
        else
          if(cp(id) .eq. "L" .or. cp(id) .eq. "R") then 
            continue 
          else if(cp(id) .eq. "H" .or. cp(id) .eq. "X") then   
            cp(id)="L"                          !translante to "L"
          else if(cp(id) .eq. "V" .or. cp(id) .eq. "Y") then
            cp(id)="R"                          !translate to "R"
          else 
            write(lu,'(a)') 
     &  "VUNPIF06: Invalid polarization. Valid values are L, H,V, R,V,Y"
          endif
        endif 

C  1.4 LO frequency
        ierr = 14
        iret = fvex_field(4,ptr_ch(cout),len(cout)) ! get number
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
        if (iret.ne.0.or.d.lt.0.d0) then
!          ierr=-4
!          write(lu,'("VUNPIF02 - Invalid LO frequency",d10.2)') d
        else
          flo(id) = d/1.d6
        endif

C  1.5 Sideband

        ierr = 15
        iret = fvex_field(5,ptr_ch(cout),len(cout)) ! get IFD ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        cout(1:1) = upper(cout(1:1))
        if (nch.ne.1.or.(cout(1:1).ne.'U'.and.cout(1:1).ne.'L')) then
          ierr=-5
          write(lu,'("VUNPIF03 - Sideband must be U or L")')
        else
          cs(id)=cout(1:1)
        endif

C  1.6 Phase cal spacing

        ierr = 16
        iret = fvex_field(6,ptr_ch(cout),len(cout)) ! get pcal spacing
        if (iret.eq.0) then ! got one
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-6
            write(lu,'("VUNPIF04 - Invalid phase cal frequency",
     .          d10.2)') d
          else
            fpcal(id) = d/1.d6 ! convert to MHz
          endif
        endif ! got one

C  1.7 Phase cal base

        ierr = 17
        iret = fvex_field(7,ptr_ch(cout),len(cout)) ! get pcal base
        if (iret.eq.0) then ! got one
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-7
            write(lu,'("VUNPIF05 - Invalid phase cal base frequency",
     .          d10.2)') d
          else
            fpcal_base(id) = d/1.d6 ! convert to MHz
          endif
        endif ! got one

C       Get next IFD def statement
        iret = fget_all_lowl(ptr_ch(stdef),
     .  ptr_ch(modef),ptr_ch('if_def'//char(0)),
     .  ptr_ch('IF'//char(0)),0)
      enddo ! get all BBC defs
      iret=0
      nifdefs = id

      if (iret.eq.0.and.ierr.gt.0) ierr=0
      return
      end
