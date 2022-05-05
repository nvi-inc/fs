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
      subroutine proc_tape(icode,codtmp,cpmode)
! Issue TAPEF*** command

      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

! passed
      integer icode
      character*2 codtmp
      character*4 cpmode
! History
! 2007Jul19 JMGipson. Separated from procs.f

! functions
      integer mcoma     !lnfch library
      integer ib2as
      integer ichmv_ch

! local
      integer ib        !ib=0 initialize. ib>2, then some tapeform commands.
      integer nco
      character*12 cnamep
      integer nch       !number of characters
      integer ihead
      integer i



      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec) .and. (kvrec(irec).or.kv4rec(irec).or.
     >    km3rec(irec).or.km4rec(irec))) then

          call proc_tapef_name(codtmp,cpmode,cnamep)
          call proc_write_define(lu_outfile,luscn,cnamep)

          ib=0           !must initialize.
          do ihead=1,max_headstack               !2hd
            do i=1,max_pass
              if(ib .eq. 0) then
                cbuf="tapeform"
                nch=9
                if (krec_append) then
                  cbuf(nch:nch)=crec(irec)
                  nch=nch+1
                endif
                nch = ichmv_ch(ibuf,nch,'=')
                ib=1
              endif
              if (ihdpos(ihead,i,istn,icode).ne.9999) then       !2hd
                nch = nch + ib2as((i+100*(ihead-1)),ibuf,nch,3) ! pass number hd
                nch = mcoma(ibuf,nch)
                nch = nch + ib2as(ihdpos(ihead,i,istn,icode),ibuf,nch,4) ! offset hd
                nch = mcoma(ibuf,nch)
                ib=ib+1
              endif
              if (ib.gt.1.and.nch.gt.60) then ! write a line
                write(lu_outfile,'(a)') cbuf(1:nch-2)
                ib=0
              endif
            enddo
          enddo  !2hd end headstack loop
          if (ib.gt.1) then ! write last line
            write(lu_outfile,'(a)') cbuf(1:nch-2)
          endif
          write(lu_outfile,"(a)") 'enddef'

        endif ! procs for this recorder
      enddo ! loop on recorders

      return
      end


