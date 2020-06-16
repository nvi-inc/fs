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
      subroutine proc_norack(icode)
! write out comments for no rack case.
      implicit none  !2020Jun15 JMGipson automatically inserted.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! 2007Jul20. First version.
! 2015Aug13  JMG. Output more info. Simplified code (don't use lnfch library.)

! passed
      integer icode

! functions
      integer itras
! local
      integer ichan
      integer ic
      character*1 lq

      double precision DRF,DLO
      integer isb_out
      integer ibit, isb
      character*2 lsb(2)
      integer ibit_out
      character*2 lvid_sb, lnet_sb

      data lsb /"U","L"/

      lq='"'

      write(lu_outfile,'(a)')
     &  '"channel  sky       lo       video   sample '
     &  //'video net  bits/'
      write(lu_outfile,'(a)')
     &  '"         freq     freq      freq     rate  '
     & //'  sb  sb  sample'

      do ichan=1,nchan(istn,icode)
        ic=invcx(ichan,istn,icode) ! channel number

        drf=freqrf(ic,istn,icode)
        dlo=freqlo(ic,istn,icode)

        ibit_out=1
        lvid_sb=" "
        lnet_sb=" "
        do isb=1,2
        do ibit=1,2
          if(itras(isb,ibit,1,ic,1,istn,icode) .ne. -99) then
            if(ibit .eq.  2) ibit_out=2
            if(drf .gt. dlo) then
              isb_out=isb
            else
              isb_out=3-isb
            endif
            lvid_sb(isb:isb)=lsb(isb)
            lnet_sb(isb:isb)=lsb(isb_out)
          endif
         end do
         end do
           write(lu_outfile,
     &  "(a,2x,i2.2,2x,  3(1x,f8.2), 1x,f7.2, 2x,2(2x,a2), 3x,i2)")
     &     lq,ic,  drf,dlo, dabs(drf-dlo), samprate(istn,icode),
     &     lvid_sb, lnet_sb, ibit_out
       end do

      end
