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
      SUBROUTINE vunphp(modef,stdef,ivexnum,iret,ierr,lu,
     .index,posh,nhdpos,nheads,cpassl,indexl,csubl,npassl)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     VUNPHP gets the head positions and pass information
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
C 960520 nrv New.
C 961122 nrv Change fget_mode_lowl to fget_all_lowl
C 970124 nrv Move initialization to start.
C 970206 nrv Remove pos2 and add head index position. Add number
C            of headstacks found to the call.
C 000907 nrv Get headstack positions up to a max of 4. Check this
C            against the number compiled in.
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
      integer index(max_index) ! list of index positions
      double precision posh(max_index,max_headstack) ! head offsets
      integer nhdpos ! number of head positions found
      integer nheads ! number of headstacks found
      integer indexl(max_pass) ! list of index positions
      character*1 csubl(max_pass) ! list of subpasses
      character*3 cpassl(max_pass) ! list of passes
      integer npassl ! number of passes found
C
! functions
      integer fvex_len,fvex_double,fvex_int,fvex_field,fget_all_lowl,
     .fvex_units,ptr_ch

C  LOCAL:
      character*128 cout,cunit
      double precision d
      integer il,ip,i,j,ih,ih1
C
C  Initialize.
      nhdpos=0
      do ip=1,max_index
        index(ip)=0
        do ih=1,max_headstack
          posh(ip,ih)=0.0
        enddo
      enddo
      npassl=0
      do i=1,max_pass
        cpassl(i)=''
        csubl(i)=''
        indexl(i)=0
      enddo
C
C  1. Headstack positions
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('headstack_pos'//char(0)),
     .ptr_ch('HEAD_POS'//char(0)),ivexnum)
      ip=1
      do while (ip.le.max_index.and.iret.eq.0) ! get all head pos

C  1.1 Index number

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get index
        if (iret.ne.0) return
        iret = fvex_int(ptr_ch(cout),i)
        if (iret.ne.0) return
        if (i.le.0.or.i.gt.max_index) then
          ierr = -1
          write(lu,'("VUNPHP02 - Invalid index value ",i5,
     .    "must be 1 to ",i3)') i,max_index
        else
          index(ip)=i
        endif
C
C  1.2 List of head positions per headstack

        ierr = 12
        ih=1
        iret = fvex_field(ih+1,ptr_ch(cout),len(cout)) ! get position
        do while (ih.le.4.and.iret.eq.0)
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
          if (iret.eq.0.and.ih.le.max_headstack) posh(ip,ih) = d*1.d06
          ih=ih+1
          iret = fvex_field(ih+1,ptr_ch(cout),len(cout)) ! get next position
        enddo
        ih=ih-1
        if (ih.gt.max_headstack) then
          write(lu,'("VUNPHP05 - Too many headstack positionss, ",
     .    "max is ",i5)') max_headstack
          ih=max_headstack
        endif

        if (ip.eq.1) then
          ih1=ih
        else
          if (ih.ne.ih1) then
            write(lu,'("VUNPHP04 - Inconsistent number of headstacks. ",
     .      i5," in first set,",i5," in next.")') ih1,ih
          endif
        endif
        iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('headstack_pos'//char(0)),
     .  ptr_ch('HEAD_POS'//char(0)),0)
        ip=ip+1
      enddo

      nheads = ih1
      nhdpos = ip-1
      if (nhdpos.gt.max_index) then ! too many
        write(lu,'("VUNPHP01 - Too many head index positions, max is ",
     .  i5)') max_index
        nhdpos=max_index
      endif

C  2. Pass order list
C
      ierr = 2
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('pass_order'//char(0)),
     .ptr_ch('PASS_ORDER'//char(0)),ivexnum)
      if (iret.ne.0) return

C  2.1 <index><subpass>

      ierr = 21
      i=1
      do while (i.le.max_pass.and.iret.eq.0)
        iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get field
        if (iret.eq.0) then
          il=fvex_len(cout)
          cpassl(i)=cout(1:il) ! save the pass-order list
          csubl(i)=cout(il:il) ! one-character subpass is the last char
          read(cout(1:il-1),*,err=500) j

          if (j.lt.0.or.j.gt.nhdpos) then
            ierr=-3
            write(lu,'("VUNPHP03 - Invalid index in pass list",i5)') j
          else
            indexl(i)=j
          endif
          i=i+1
        endif
      enddo
      npassl = i-1

      if (ierr.gt.0) ierr=0
      return
500   continue
      write(*,*) "VUNPH04: Error reading pass ",cout(1:il-1)
      ierr=-3
      return
      end
