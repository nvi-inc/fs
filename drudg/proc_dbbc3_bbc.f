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
      subroutine proc_dbbc3_bbc(icode,ic,ib,ichan)
! Write out the BBC commands for channel ic for the DBBC racks
      implicit none  !2020Jun15 JMGipson automatically inserted.

! Note: Also calculate and store in common BBC freqs, lo freqs.
! History
!  2020-12-31 JMG Based on proc_dbbc_bbc 

! Write out VC commands.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'
      integer icode, ic, ib,ichan              !channel and BBC number we are considering.
                                               !NOTE: Does not use ichan at all.
!functions
      integer iwhere_in_string_list
     
! local
      character*1 lq
      character*12 lbbc_freq
      character*12 lbandwidth 
      integer nch,nch2 
      integer ierr 
      integer ind 
   
      integer iwhere
      integer max_if_valid
      parameter (max_if_valid=2*max_ifd)
      character*2 cif_valid(max_if_valid)
      character*2 cif

      data cif_valid/"a1","b1","c1","d1","e1","f1","g1","h1",
     &               "a2","b2","c2","d2","e2","f2","g2","h2"/

      lq="'"
! Start of code.
      flo(ib) = FREQLO(ic,ISTN,ICODE)
      if (flo(ib).lt.0.d0) then ! missing LO
         fvc(ib)=-1.0           !set to invalid number.
      else
         fvc(ib) = abs(dble(freqrf(ic,istn,icode))-flo(ib))   ! BBCfreq = RFfreq - LOfreq
      endif 
 
!      Check to see if the IF is valid. Should be of the form:
!      A1...H1, A2...H2
      cif=cifinp(ic,istn,icode)(1:2)
      call lowercase(cif)   !capitalize for the check.
      iwhere= iwhere_in_string_list(cif_valid,max_if_valid,cif)
      if(iwhere .eq. 0) then
        call write_return_if_needed(luscn,kwrite_return)
        write(luscn,'(a,i3,a,a,a,$)')
     >   "proc_dbbc3_bbc: Warning! For BBC ",ib, " IF '", cif,
     >         "' is not valid! "
        write(luscn,'(a)') "Valid options are a1,b1...h1, a2,b2,..h2" 
        ind=index("abcdefgh",cif(1:1))
        if(ind .ne. 0 .and. ldbbc_if_inputs(ind) .ne. " ") then
           cifinp(ic,istn,icode)(1:2)=cif(1:1)//ldbbc_if_inputs(ind)
           write(*,*) "         Used DBBC_IF_INPUTS to create: ", 
     &        cifinp(ic,istn,icode)
        endif 
      endif    
 

! DBBC3 does not use filters. 
      ibbc_filter(ib)=-99
      rfmin=0.000001
      rfmax=4096  
      if(fvc(ib) .lt. rfmin .or. fvc(ib) .gt. rfmax) then  
        write(luscn,
     >  '("Invalid_BBC3_freq:! For bbc", i3.3, " frequency ", 
     >  f11.6, " is out of range.")')  ib, fvc(ib) 
        write(luscn,'("   Valid range is ", f11.6, " to ", f6.1)') 
     >    rfmin, rfmax
        write(luscn,'(a)') "   Check LO and IF in schedule. "   
      endif

      call double_2_string(fvc(ib),'(f11.6)',lbbc_freq,nch,ierr) 
      call real_2_string(vcband(ic,istn,icode),'(f11.6)', 
     > lbandwidth,nch2,ierr) 
 
50    continue      
     

! Make a string that looks like:
! bbc011=612.0000001,a,8.000
      write(cbuf,'("bbc",i3.3,"=",a,",",a1,",",a)')   
     >  ib,lbbc_freq(1:nch),cifinp(ic,istn,icode), lbandwidth(1:nch2) 
      call drudg_write(lu_outfile,cbuf)       !get rid of spaces, and write it out. 
     
      return
      end





