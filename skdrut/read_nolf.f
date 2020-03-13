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
      subroutine read_nolf(lu,cbuf,kend)
      implicit none
! Input
      integer lu             !logical unit
      character*(*) cbuf     !character buffer
      logical kend           !Reached EOF.
! History
! 2015Dec01    JMGipson
!
! Read a line from the input file. Replace ^M (=linefeed) with space. 

! local
      integer ind           !index
   
! Default is reach EOF.       
      kend=.true.
      read(lu,'(a)',end=100) cbuf
      
! Hmmm. Did not reach EOF.   Set this to false. 
      kend=.false. 
! Replace ^M with space. 
      ind=index(cbuf(1:len(cbuf)),char(13)) 
      if(ind .ne. 0) cbuf(ind:ind) = " " 

100   continue
      return 

      end 

      

     
      


