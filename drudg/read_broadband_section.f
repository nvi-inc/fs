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
      subroutine read_broadband_section
! Read the broadband section from schedule file. 
      implicit none 
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/broadband.ftni' 

! 2020Jun08.  Added in ibb_off parameter.  Added in new broadband.ftni 

! function
      integer iwhere_in_string_list
      integer trimlen 

! local     
      integer istat   

      integer NumToken,MaxToken
      parameter(MaxToken=5)
      character*12 ltoken(MaxToken)  
      logical kend  
    
! rewinde the file.
      rewind(lu_infile)
     
      do istat=1,nstatn
         bb_bw(istat) =0.0       !set these all to 0. 
         idata_mbps(istat)=0
         isink_mbps(istat)=0
         ibb_off(istat)=0 
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
         if(NumToken .ge. 5) 
     >      read(ltoken(5),*,err=550)  ibb_off(istat)

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
