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
	SUBROUTINE GTSNP(ICH,NCHAR,IC1,IC2,kcomment)
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  Input:
      integer ich,nchar,ic1,ic2
      logical kcomment
C
C  Local:
	integer*4 ierr,ilen
	integer Z22
        integer iscnc ! functions

C Initialized:
	DATA     Z22/Z'22'/
C
C History:
C nrv 930407 implicit none
C 020606 nrv Add kcomment to indicate a comment was found

100   CALL GTFLD(IBUF,ICH,NCHAR,IC1,IC2)
      kcomment=.false.
      IF (IC1.EQ.0) THEN !end of this record
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	  IF (IERR.LT.0.OR.ILEN.LT.0) THEN
	    RETURN
	  ENDIF
          if(cbuf(1:1) .ne. "-") then
C Back up to just before the record
	    RETURN
	  ELSE ! continuation record
	    ICH = 2
	    NCHAR = ILEN
	    GOTO 100
	  ENDIF
	ENDIF
C
	IF (cbuf(ic1:ic1) .eq. '"') then
          kcomment = .true.
	  IC2 = ISCNC(IBUF,IC1+1,NCHAR,Z22)
C Find the next quote
	  IF (IC2.EQ.0) THEN ! no closing quote
	    IC2 = NCHAR
	    ICH = NCHAR+1
	  ELSE
	    ICH=IC2+1
	  ENDIF
	ENDIF
C
      RETURN
      END
