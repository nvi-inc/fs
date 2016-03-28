      subroutine proc_dbbc_bbc(icode,ic,ib,ichan)
! Write out the BBC commands for channel ic for the DBBC racks
  
! Note: Also calculate and store in common BBC freqs, lo freqs. 
! History
!  2012Sep12  JMGipson. First version. Modeled proc_vracks_bbc.
!
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
      integer nch           
      integer max_if_valid
      parameter (max_if_valid=20)     
      character*2 cif_valid(max_if_valid)
      integer iwhere
          
      logical kvalid_if
      logical kdbbc
      character*2 cif    
      character*1 lq
    
      data cif_valid/"A ","A1","A2","A3","A4","B ","B1","B2","B3","B4",
     >               "C ","C1","C2","C3","C4","D ","D1","D2","D3","D4"/
      
      lq="'"     
! Start of code. 
      flo(ib) = FREQLO(ic,ISTN,ICODE)
      if (flo(ib).lt.0.d0) then ! missing LO 
         fvc(ib)=-1.0           !set to invalid number.
      else
         fvc(ib) = abs(dble(freqrf(ic,istn,icode))-flo(ib))   ! BBCfreq = RFfreq - LOfreq                
      endif

      write(cbbc,'("bbc",i2.2)') ib 
  
      if(cstrack_orig(istn) .eq. "DBBC" .or. 
     >   cstrack_orig(istn) .eq. "NONE") then
         kdbbc=.true.
!        Check to see if the IF is valid. Should be of the form:
!        A1,A2...A4,  B1,B2...B4, .... D1...D4 
        cif=cifinp(ic,istn,icode)  
        call capitalize(cif)   !capitalize for the check. 
        iwhere= iwhere_in_string_list(cif_valid,max_if_valid,cif)
        if(iwhere .eq. 0) then    
          call write_return_if_needed(luscn,kwrite_return)           
          write(luscn,'(a,i3,a,a,a)') 
     >   "proc_dbbc_bbc: Warning! For BBC ",ib, " IF '", cif,
     >         "' is not valid! "
        else if(cif(2:2) .eq. " ") then       
          call write_return_if_needed(luscn,kwrite_return)
          write(luscn,'(a,i3,a,a,a)') 
     >   "proc_dbbc_bbc: Warning! For BBC ",ib, " IF '", cif,
     >       "' has blank as second character!"         
        endif         
      else
       kdbbc=.false.
       iwhere=0
      endif   


      if(iwhere .ne. 0) then 
        kvalid_if=.true.       
      else
        kvalid_if=.false. 
!        call invalid_if(cbbc,cifinp(ic,istn,icode), cstrack(istn))  
        if(     ib .ge. 1 .and. ib .le. 4) then
          cif="a"//ldbbc_if_inputs(1)
        else if(ib .ge. 5 .and. ib .le. 8) then
          cif="b"//ldbbc_if_inputs(2)
        else if(ib .ge. 9 .and. ib .le. 12) then
          cif="c"//ldbbc_if_inputs(3)   
        else if(ib .ge. 13 .and. ib .le. 16) then          
          cif="d"//ldbbc_if_inputs(4)         
        endif 
        call write_return_if_needed(luscn,kwrite_return)
        if(kdbbc) then 
           write(luscn,'(a,a,a)') lq,cif,lq
        else
          write(luscn,'("For BBC ",i3, " Converted IF ", a, " to ", a)')
     >    ib,  cifinp(ic,istn,icode), cif  
        endif
          cifinp(ic,istn,icode)=cif
      endif    

      rfmin=10.0
      rfmax=2200.0
      if(fvc(ib) .lt. rfmin .or. fvc(ib) .gt. rfmax) then     
        call invalid_bbc_freq(cbbc,fvc(ib),rfmin,rfmax)
      endif       

      cbbc_pol(ib)=cpol(ic,istn,icode) 
      if(fvc(ib) .ge. 512.d0 .and. fvc(ib) .le. 1024.d0) then
         ibbc_filter(ib) =1
      else if(fvc(ib) .ge. 10.d0 .and. fvc(ib) .le. 512.d0) then
         ibbc_filter(ib)=2
      else if(fvc(ib) .ge. 1536.d0 .and. fvc(ib) .le. 2048.d0) then
         ibbc_filter(ib)=3
      else if(fvc(ib) .ge. 1024.d0 .and. fvc(ib) .le. 1536.d0) then
         ibbc_filter(ib)=4
      else
         ibbc_filter(ib)=0
      endif 
!      write(*,*) fvc(ib), ibbc_filter(ib)          
  
! Make a string that looks like:
! bbc01=612.99,a,8.000
      write(cbuf,'("bbc",i2.2,"=",f7.2,",",a1,",", f6.2)') 
     >    ib,fvc(ib),cifinp(ic,istn,icode), vcband(ic,istn,icode)
      call squeezeleft(cbuf,nch)
      call lowercase_and_write(lu_outfile,cbuf)
      return
      end 



