      subroutine proc_lba_ifp(icode,ic,ib,ichan)

!  2012Sep12  JMGipson. First version. Split off of old routine proc_vc. 
!
! Write out VC commands.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'

! Write out the IFP commands for channel ic for LBA racks.
      integer icode, ic,ib,ichan        !channel anb BBC number we are considering. 

!functions    
      integer ir2as
      integer mcoma
      integer ichmv_ch
   
! local variables.       
      real*8 DRF                !RF frequency       
      integer nch    
     
      integer icx         !BBC#, Channel#, alternate channel#
      integer ic_hi             !channel # of hiband  
      
! Start of code....
      DRF = FREQRF(ic,istn,ICODE)
      ic_hi=ic
      do icx=ichan+1,nchan(istn,icode)
         if (ibbcx(invcx(icx,istn,icode),istn,icode).eq.ib)
     >            ic_hi=invcx(icx,istn,icode)
      enddo
      if (FREQRF(ic,istn,ICODE).gt.FREQRF(ic_hi,istn,ICODE))then
        icx = ic
        ic = ic_hi
        ic_hi = icx
      endif

      if (ic.eq.ic_hi) then     
!Use centreband filters where possible
        if (cnetsb(ic,istn,ICODE).eq."L") then                    
          DRF = FREQRF(ic,istn,ICODE)- VCBAND(ic,istn,ICODE)/2.0
        else
          DRF = FREQRF(ic,istn,ICODE)+ VCBAND(ic,istn,ICODE)/2.0
        endif
      else if (FREQRF(ic,istn,ICODE).eq.FREQRF(ic_hi,istn,ICODE)) then
!Must be simple double sideband ie. L+U
        if (cnetsb(ic,istn,ICODE).ne.cnetsb(ic_hi,istn,ICODE)) then
          write(luscn,9900) ic,ic_hi
9900               format(/'PROCS00 - WARNING! Sideband  definitions '
     <                'for channels ',i2,' and ',  i2,' conflict!')
        endif 
      else
!Different frequencies must differ by bandwidth
        if ((FREQRF(ic_hi,istn,ICODE)-FREQRF(ic,istn,ICODE))
     >             .ne.VCBAND(ic,istn,ICODE))  then
           write(luscn,9901) ic,ic_hi,ib
9901      format (/'PROCS01 - WARNING! Channels ',i2,' and ',
     >          i2,' define IFP ',i2,' differently!')
        endif 
!       and one or other sideband must be flipped ie L+L or U+U
        if (cnetsb(ic,istn,ICODE).ne.cnetsb(ic_hi,istn,ICODE)) then
           write(luscn,9900) ic,ic_hi
        endif
        if (cnetsb(ic,istn,icode) .eq. 'L') then
C            L+L is produced via L + flipped U
            DRF = FREQRF(ic,istn,ICODE)
        else
C          U+U is produced via flipped L + U
           DRF = FREQRF(ic_hi,istn,ICODE)
        endif
      endif
      
      flo(ib) = FREQLO(ic,ISTN,ICODE)
      if (flo(ib).lt.0.d0) then ! missing LO
        fvc(ib)=-1.0     !set to invalid number.
      else
        fvc(ib) = abs(DRF-flo(ib))   ! BBCfreq = RFfreq - LOfreq                
      endif
     
      write(cbuf,'("ifp",i2.2,"=")') ib
      nch=7   
      cbbc=cbuf(1:5) 
   
      if(.not.(cifinp(ic,istn,icode)(1:1) .ge. "1" .or.
     >    cifinp(ic,istn,icode)(1:1) .le. "4")) then     
       call invalid_if(cbbc,cifinp(ic,istn,icode), cstrack(istn))      
      endif

      rfmin=0.0
      rfmax=192.0
      if(fvc(ib) .lt. rfmin .or. fvc(ib) .gt. rfmax) then     
        call invalid_bbc_freq(cbbc,fvc(ib),rfmin,rfmax)
      endif       
   
      NCH = nch + IR2AS(real(fvc(ib)),IBUF,nch,7,2) ! converter freq
      NCH = MCOMA(IBUF,NCH)
      NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
    
      if (ic.eq.ic_hi) then
        nch = ichmv_ch(ibuf,nch,',SCB,') ! for single centreband filter
      else
        nch = ichmv_ch(ibuf,nch,',DSB,') ! for double sideband filter
      endif
      if(cnetsb(ic_hi,istn,ICODE).ne.'L'.and..not.klsblo.or.
     >    cnetsb(ic_hi,istn,ICODE).eq.'L'.and.klsblo) then
          nch = ichmv_ch(ibuf,nch,'NAT,')
      else
          nch = ichmv_ch(ibuf,nch,'FLIP,')
      endif
      if(ic.ne.ic_hi) then
C              Normally LSB so login inverts
        if(cnetsb(ic,istn,ICODE).eq.'L'.and..not.klsblo .or.
     >     cnetsb(ic,istn,ICODE).eq.'L'.and.klsblo) then
           nch = ichmv_ch(ibuf,nch,'NAT')
        else
          nch = ichmv_ch(ibuf,nch,'FLIP')
        endif
      endif
      NCH = MCOMA(IBUF,NCH)
      cbuf(nch:nch+7)=cs2data(istn,icode)    
      call lowercase_and_write(lu_outfile,cbuf)
      return
      end

      

