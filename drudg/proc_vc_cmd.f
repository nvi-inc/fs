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
      subroutine proc_vc_cmd(cname_vc, icode, kk4vcab, lwhich8,ierr)     
! Write out VC commands.
      implicit none 
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'

! Passed parameters.
      character*12 cname_vc     !Name of procedure             !
      integer icode             !what code
      logical kk4vcab           !For K4 systems  
      character*1 lwhich8       ! which8 BBCs used: F=first, L=last
! Returned
      integer ierr           !<>0 is some error. 

!functions
      integer ir2as
      integer ichmv_ch
      integer trimlen 

! History:
! 2007Jul09. Split off from procs.
! 2008Feb26 JMG.  Write out comment if unused BBCs are present.
! 2010May11 JMG.  Changed DRF and DRLO to double precision. In computing rfvc was losing precision.
! 2016Jan18 JMG. Only write out name if cname_vc <> " "   

! local variables.
      character*80 cbuf2        !temporary text buffer.
      real*8 rfvc_max  		!maximum frequency           

      integer nch
      logical kinclude_chan     !Write out this channel?
      integer i 
   
      integer ichan             !Channel Counters
      integer ib,ic             !BBC#, Channel#, alternate channel#    
      logical kdone_bbc(max_bbc)  !flag indicating that we have this BBC     
      logical kfirst
      integer nlast  
            
      kwrite_return = .true.   
!If true, then need to write a <CR> before outputting error or warning info.     
      do irec=1,nrecst(istn) ! loop on recorders
C       If both recorders are in use then do the check to see if
C       we should do one or both procs
        
        if((kuse(1).neqv.kuse(2).and.kuse(irec)).or.
     .     ((kuse(1).and.kuse(2)).and.(irec.eq.1.or.
     .                (irec.eq.2.and.kk4vcab)))) then ! do this

          if(cname_vc .ne. " ") 
     &       call proc_write_define(lu_outfile,luscn,cname_vc)

C         Initialize the bbc array to "not written yet"
          do ib=1,max_bbc
            kdone_bbc(ib)=.false. 
          enddo
        
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
            ib=ibbcx(ic,istn,icode)    ! BBC number
      
! Check for some quick exits...
            if(kdone_bbc(ib)) goto 500
            if(freqrf(ic,istn,icode) .lt. 0) goto 500
            if (k8bbc) then
C             For 8-BBC stations use the loop index number to get 1-7
              call proc_check8bbc(km3be,km3ac,lwhich8,ichan,
     >                   ib,kinclude_chan)
              if(.not. kinclude_chan) goto 500 
            endif
            kdone_bbc(ib) = .true.               
      
           if (FREQLO(ic,istn,icode) .lt. 0) then
             write(luscn,9910) ic
9910     format(/,'proc_vc:  WARNING! LO frequency forchannel ',i2,
     >       ' is missing!',/,
     >       '  BBC or VC frequency procedure will not be correct, ',
     >        'nor will IFD procedure.')
            endif 

            if(klrack) then
              call proc_lba_ifp(icode,ic,ib,ichan) 
            else if(kvracks) then
              call proc_vracks_bbc(icode,ic,ib,ichan)
            else if(kmracks .or. kk41rack.or.kk42rack) then 
              call proc_mracks_vc(icode,ic,ib,ichan) 
            else if(kdbbc_rack) then
              call proc_dbbc_bbc(icode,ic,ib,ichan) 
            endif 

            if(rfvc_max .lt. fvc(ib)) then
             cbuf2=cbuf         !this makes a copy of this which we will output later. 
             rfvc_max=fvc(ib)
            endif      

500       continue              !fast exit                    
          ENDDO !loop on channels

! Here we do some checking for DBBC racks to make sure that BBCs 
! 1-4 are in the same frequency band, 
! 5-8 are in the same frequency band... etc.

       if(kdbbc_rack) then
         if(cstrack_orig(istn) .eq. "DBBC" .or. 
     >      cstrack_orig(istn) .eq. "NONE") then      
           continue
         else
! But only check if the original rack is NOT  DBBC or NONE
           call check_dbbc_setup(icode,ierr)
           if(ierr .ne. 0) return 
         endif 
       endif     

       if(kvracks .or. kmracks) then
! Here we pick up the BBCs that are present, but not used. Put in for RDVs. 
          if(kmracks) then    ! "VC" command.
            nch=3   
          else
            nch=4              ! "BBC" command.   
          endif 
            nlast=trimlen(cbuf2) 
            kfirst=.true.
            do ib=1,max_bbc
              if(ibbc_present(ib,istn,icode) .eq. -1) then  !present but not used.
                if(kfirst) then
                  kfirst=.false.
                  write(lu_outfile,'(a)') 
     >           '" NOTE: following BBCs/VCs are present but not used'
                endif
! Effectively this just overwritest the number in the BBC command with highest frequency. 
                write(lu_outfile, '(a,i2.2,a)') cbuf2(1:nch-1),ib,
     >            cbuf2(nch+2:nlast)
              endif
            end do
         endif        

         if (kmracks) then
           write(lu_outfile,"('!+1s')")
           write(lu_outfile,'(a)') 'valarm'
         endif

C         For K4, use bandwidth of channel 1
          if (kk41rack) then ! k4-1
            cbuf="vcbw="
            nch=6
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'4.0')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)
          endif ! k4-1
          if (kk42rack) then ! k4-2  !Go through twice, once with "vabw", once with "vbbw" 
            do i=1,2
              if(i .eq. 1) then
                cbuf="vabw="
              else
                cbuf="vbbw="
              endif           
              nch=6
              if (kk42rec(irec)) then
                nch = ichmv_ch(ibuf,nch,'wide')
              else
                NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
              endif
              write(lu_outfile,'(a)') cbuf(1:nch)
            end do
          endif 
          if(cname_vc .ne. " ") 
     &        write(lu_outfile,"(a)") 'enddef'
        endif ! do this
      enddo ! loop on recorders
      end
! **************************************************************
      subroutine invalid_if(luscn,cbbc, cif, crack)
! 2020Feb20 JMG. Added implicit none, changed argument list
      implicit none
      integer luscn
      character*(*) cbbc
      character*(*) cif
      character*(*) crack        
      write(*,*) " " 
         write(luscn,'("Invalid_IF: Error! For ",a, " IF=",a,
     >  " is inconsistent with rack ", a)') cbbc,  cif, crack
  
      return
      end 
! ****************************************************************
      subroutine invalid_bbc_freq(luscn,cbbc,rfvc,rfmin,rfmax)
! 2020Feb20 JMG. Added implicit none, changed argument list. 
      implicit none 
      integer luscn 
      character*(*) cbbc
      real*8 rfvc,rfmin,rfmax
            
      write(*,*) " " 
      write(luscn,'("Invalid_BBC_freq:! For ", a, " frequency ", f7.2,
     >  " is out of range.")')  cbbc, rfvc 
      write(luscn,'("   Valid range is ", f8.2, " to ", f8.2)') 
     >    rfmin, rfmax
      write(luscn,'(a)') "   Check LO and IF in schedule. "
   
      return
      end 



