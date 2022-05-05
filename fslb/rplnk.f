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
      subroutine rplnk(nseg,namseg,nsub,narg,n1,n2,n3,n4,n5,n6, 
     .n7,n8,n9,na,nb,nc,nd,ne,nf)
C 
C  This routine RP's the segment if different from last entry. 
C 
        dimension lseg(3),namseg(3) 
C 
C  LSEG    - LAST SEGMENT NAME 
C 
      data lseg/0,0,0/
C 
C  CHECK FOR A NAME CHANGE FROM LAST CALL
C 
      if (ichcm(namseg,1,lseg,1,5).eq.0.and.lseg(1).ne.0) goto 50000
C 
C  CHECK FOR A SEGMENT RP'ED 
C 
c      IF (ICHCM(LSEG,1,LSEG,2,5) .NE. 0)CALL IOF(LSEG,IERR,1)
C 
C  SAVE NEW NAME 
C 
      call ichmv(lseg,1,namseg,1,5) 
C 
C  CHECK FOR ONLY SEGMENT REMOVAL
C 
      if (ichcm(namseg,1,namseg,2,5).eq.0) goto 99000
C 
C  GET CURRENT IDSEG ADDR
C 
cxx      idseg=igid(namseg)
C 
C  RP THE CURRENT SEGMENT
C 
c      IF (IDSEG .EQ. 0)CALL IRP(NAMSEG,0,IERR,0)
C 
50000 continue
C 
C  LINK TO THE ROUTINE 
C 
      call linqa(nseg,namseg,nsub,narg,n1,n2,n3,n4,n5,n6, 
     . n7,n8,n9,na,nb,nc,nd,ne,nf)
C 
99000 continue
C 
C  RETURN TO CALLER
C 
      return
      end 
