      subroutine read_broadband_section
! Read the broadband section from schedule file. 
      implicit none 
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'

! function
      integer iwhere_in_string_list
      integer trimlen 

! local     
      integer istat   

      integer NumToken,MaxToken
      parameter(MaxToken=4)
      character*12 ltoken(MaxToken)  
      logical kend  
    
! rewinde the file.
      rewind(lu_infile)
     
      do istat=1,nstatn
         bb_bw(istat) =0.0       !set these all to 0. 
      end do 
100   continue
      cbuf=" "
      do while(cbuf .ne. "$BROADBAND") 
        call read_nolf(lu_infile,cbuf,kend)
        if(kend) goto 500
!        read(lu_infile,'(a80)',end=500) cbuf
      end do 
      cbuf = " " 
      do while(cbuf(1:1) .ne. "$")
        call splitNtokens(cbuf,ltoken,Maxtoken,NumToken)           
        istat=iwhere_in_string_list(cstnna,nstatn,ltoken(1))
        if(istat .ne. 0) then
         if(NumToken .ge. 2) 
     >      read(ltoken(2), *,err=550) bb_bw(istat)
         if(NumToken .ge. 3) 
     >      read(ltoken(3),*, err=550) idata_mbps(istat)
         if(NumToken .ge. 4) 
     >      read(ltoken(4),*,err=550)  isink_mbps(istat)
        end if
!        read(lu_infile,'(a80)',end=500) cbuf 
        call read_nolf(lu_infile,cbuf,kend)
        if(kend) goto 500
      end do  
500   continue 
      return

550   continue
      write(*,*) "Error reading broadband section on line: "
      write(*,*) cbuf(1:trimlen(cbuf))


      return
      end 
