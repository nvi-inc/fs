      subroutine proc_vracks_bbc(icode,ic,ib,ichan)
! Write out the BBC commands for channel ic for VLBA racks.
   
! Note: Also calculate and store in common BBC freqs, lo freqs. 
! History
!  2012Sep12  JMGipson. First version. Split off of old routine proc_vc. 
! Write out VC commands.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'
      integer icode, ic, ib,ichan              !channel anb BBC number we are considering. 
!functions        

! local variables.                   
      integer nch                
      real*8 bwu, bwl   
      
 
! Start of code.      
      flo(ib) = FREQLO(ic,ISTN,ICODE)
      if (flo(ib).lt.0.d0) then ! missing LO 
         fvc(ib)=-1.0           !set to invalid number.
      else
         fvc(ib) = abs(dble(freqrf(ic,istn,icode))-flo(ib))   ! BBCfreq = RFfreq - LOfreq                
      endif
         
      write(cbbc,'("bbc",i2.2)') ib 
      if(cifinp(ic,istn,icode)(1:1) .ge. "A" .and.
     >   cifinp(ic,istn,icode)(1:1) .le. "D") then 
        continue
      else
        call invalid_if(cbbc,cifinp(ic,istn,icode), cstrack(istn)) 
      endif

      rfmin=450.0d0
      rfmax=1050.0d0
!      if(.true.) then 
       if(fvc(ib) .lt. rfmin .or. fvc(ib) .gt. rfmax) then     
        call invalid_bbc_freq(cbbc,fvc(ib),rfmin,rfmax)
      endif  
          
      if (kk42rec(irec)) then
        if(km3rack) then
          bwu=4.0
        else
          bwu=16.0
        endif
      else
         bwu=vcband(ic,istn,icode)
      endif
    
!      NCH = MCOMA(IBUF,NCH)
      if (kk42rec(irec)) then
        bwl=16.0
      else
        bwl=vcband(ic,istn,icode)
      endif     
! Make a string that looks like:
! bbc01=612.99,a,8.000,8.000
      write(cbuf,'("bbc",i2.2,"=",f7.2,",",a1,2(",",f7.3))') 
     >        ib,fvc(ib),cifinp(ic,istn,icode)(1:1), bwu,bwl
      call squeezeleft(cbuf,nch)
      call lowercase_and_write(lu_outfile,cbuf)
      return
      end 



