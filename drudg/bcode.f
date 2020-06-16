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
C BCODE
	subroutine bcode(lu,jbuf,lbuf,clabtyp)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C  BCODE writes out the ASCII label and the bar code
C  label to the Epson printer.
C  It is assumed that the header lines have already
C  been written onto the label.

      include '../skdrincl/skparm.ftni'

C Input:
	integer lu ! printer unit number
	integer*2 jbuf(7) ! holds text for bar code
	integer*2 lbuf(6) ! holds text for ASCII label
	character*128 clabtyp ! EPSON or EPSON24

C Local:
	integer parms(4) ! parameters for bars
	integer i,j
	integer*2 lf(2,2)
	integer*2 ibuf(400)   ! holds graphics codes
        integer ilbuf,ibyte,ichmv,idum,ib,k
	integer*2 ZCR
	character*10 cprint

C Initialized:
	data parms/5,2,5,2/
C             <ESC>3  <1>     <ESC>3  <20>
c     DATA LF/015463B,000400B,015463B,012000B/   !Line feed control
	data lf/Z'331B',Z'0001', Z'331B',Z'0014'/
	data ZCR/Z'000D'/   !carriage return

C History:
C 901025 NRV Created

C 1. First call BAR1 to fill up IBUF.

	ilbuf=400
	ibyte = 1
	call bar1(jbuf,1,13,ibuf,ilbuf,ibyte,parms)

C 2. Write out the ASCII label just above the bars.

	cprint = char(27)//'A'//char(12)  ! line spacing 1/6"
c      write(lu,'(a)') cprint(1:3)
c      cprint = char(27)//'2'//char(9)  ! line feed?
c      write(lu,'(a)') cprint(1:3)
	write(lu,'(a3,5a2,a1)') cprint(1:3),(lbuf(i),i=1,5),char(13)

C 3. Write out the graphics buffer 5 times

	do i=1,5
	  do j=1,2
	    if (i.ne.5.or.j.ne.2) then
		idum = ichmv(ibuf,ibyte,lf(1,j),1,3)
		ib=ibyte+2
	    else
		idum = ichmv(ibuf,ibyte,ZCR,1,1)
		ib=ibyte
	    endif
	    write(lu,9300) (ibuf(k),k=1,(ib+1)/2),char(13)
9300      format(400a2,a1)
	  enddo
	enddo

	if (clabtyp.eq.'EPSON') then
	  cprint = char(27)//'3_'//char(13)
	else !EPSON24
	  cprint = char(27)//'3('//char(13)
	endif
	write(lu,'(a)') cprint(1:4)
	cprint = char(27)//'A'//char(12)//char(13)
	write(lu,'(a)') cprint(1:4)

	return
	end
