      subroutine proc_mracks_vc(icode,ic,ib,ichan) 
! Write out the VC commands. 
 
!  2012Sep12  JMGipson. First version. Split off of old routine proc_vc. 
!
! Write out VC commands.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'
      integer icode,ic, ib             !channel anb BBC number we are considering. 
!functions
      integer itras            !track assignment function. Returns -99 if not set 
      integer ir2as
      integer mcoma
      integer ichmv_ch     

! local variables.     
      integer nch    
      logical ku,kl             !is this channel upper or lower     
      integer ichan,ichanx      !Channel Counters
      integer icx               !alternate channel#
    
      character*1 cvc2k42(max_bbc)
      character*1 cvchan(max_bbc)
    
      data cvc2k42/'1','2','3','4','5','6','7','8',
     .             '1','2','3','4','5','6','7','8'/
      data cvchan /8*'A',8*'B'/                        
! Start of code.                     

      flo(ib) = FREQLO(ic,ISTN,ICODE)
      if (flo(ib).lt.0.d0) then ! missing LO 
         fvc(ib)=-1.0           !set to invalid number.
      else
         fvc(ib) = abs(dble(freqrf(ic,istn,icode))-flo(ib))   ! BBCfreq = RFfreq - LOfreq                
      endif
  
      if(kmracks) then
        write(cbuf,'("vc",i2.2,"=")') ib
        nch=6 
      else if (kk41rack) then ! k4-1
        write(cbuf,'("vclo=",i2.2,",")') ib
        nch=9
      else if(kk42rack) then !k4-2
        write(cbuf,'("v",a1,"lo=",a1,",")') cvchan(ib),cvc2k42(ib)
        nch=8
      endif ! k4-1/2

      write(cbbc,'("vc",i2.2)') ib 
           
! Check for valid IF input.
      if(cifinp(ic,istn,icode) .eq. "1N" .or.
     >   cifinp(ic,istn,icode) .eq. "2N" .or.
     >   cifinp(ic,istn,icode) .eq. "3N" .or.
     >   cifinp(ic,istn,icode) .eq. "3I" .or.
     >   cifinp(ic,istn,icode) .eq. "3O" .or.
     >   cifinp(ic,istn,icode) .eq. "1A" .or.
     >   cifinp(ic,istn,icode) .eq. "2A" .or.
     >   cifinp(ic,istn,icode) .eq. "3A") then
        continue
      else
        call invalid_if(cbbc,cifinp(ic,istn,icode), cstrack(istn))         
      endif 

      if(kmracks) then
        rfmin=0.0
        rfmax=500.0
        continue
      else if(kk41rack) then
        rfmin=99.99
        rfmax=511.99       
      else if(kk42rack) then 
        rfmin=499.99
        rfmax=999.99
        continue
      endif
      if(fvc(ib) .lt. rfmin .or. fvc(ib) .gt. rfmax) then     
        call invalid_bbc_freq(cbbc,fvc(ib),rfmin,rfmax)
      endif     

      if((km3rack.or. kk41rack).and. vcband(ic,istn,icode).gt.7.9) then
        write(luscn,9192) cstrack(istn)
9192    format(/'PROCS07 - WARNING! Video bandwidths greater than 4',
     .              /,'  are not supported for ',a)
      endif
      
      NCH = nch + IR2AS(real(fvc(ib)),IBUF,nch,7,2) ! converter freq

      if (km4rack.and.(vcband(ic,istn,icode).eq.1.0.or.
     >                        vcband(ic,istn,icode).eq.0.25)) then ! external
        NCH = ichmv_ch(ibuf,nch,',0.0(')
        NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
        NCH = ichmv_ch(ibuf,nch,')') 
      else if(kmracks) then 
        NCH = MCOMA(IBUF,NCH)
        if (kk42rec(irec)) then
          if(km3rack) then
            nch = ichmv_ch(ibuf,nch,'4.0') ! max for K42 rec
          else
            nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
          endif
        else
           NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
         endif
      endif
  
      if(kmracks) then
        ku=.false.
        kl=.false. 
        DO ichanx=ic,nchan(istn,icode) !remaining channels
           icx=invcx(ichanx,istn,icode) ! channel number
           if (ib.eq.ibbcx(icx,istn,icode)) then ! Same BBC?               
             if(itras(1,1,1,icx,1,istn,icode).ne.-99 .or. 
     >          itras(1,1,2,icx,1,istn,icode).ne.-99) ku=.true. 
             if(itras(2,1,1,icx,1,istn,icode).ne.-99 .or.
     >          itras(2,1,2,icx,1,istn,icode).ne.-99) kl=.true.                  
           endif
        enddo
        if(ku .and. kl) then 
           fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)
           fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
           nch=ichmv_ch(ibuf,nch,',ul')
        else if(ku) then
           nch=ichmv_ch(ibuf,nch,',u')       
           fvc_lo(ib)=fvc(ib)    
           fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
        else if(kl) then         
           fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)              
           fvc_hi(ib)=fvc(ib) 
           nch=ichmv_ch(ibuf,nch,',l')
        endif
      endif 
   
      call lowercase_and_write(lu_outfile,cbuf)
      if (kk41rack) then ! k4-1
        write(lu_outfile,'("vc=",i2.2)') ib
      else if(kk42rack) then    !Kk4-2
        write(lu_outfile,'("v", a1,"=",a1)')cvchan(ib),cvc2k42(ib)
      endif    
      return
      end 

