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
      subroutine opnpf(lprc,idcb,ibuf,iblen,lproc,maxpr,nproc,ierr,old)
C     !OPEN PROC FILE AND MAKE DIRECTORY C#870115:04:19#
C
C     OPNPF opens the named procedure file and reads through
C     it, making a directory of the entries.
C
C     DATE   WHO CHANGES
C     810906 NRV CREATED
C     890509 MWH Modified to use CI files
c
      include '../include/params.i'
C
C  INPUT:
C
C     LPRC - the file name
      character*(*) lprc
C     IDCB - DCB for opening the file
C     IBUF - a buffer to use for reading
C     IBLEN - the length of IBUF in words
C     MAXPR - maximum number of entries in LPROC
C     OLD - 'N' if new procedure library, 'O' if old
      integer idcb(1)
      character*(*) old
C
C  OUTPUT:
C
C     LPROC - the procedure directory information
C     NPROC - number of procedures in this file
      integer*4 lproc(4,1)
C
C  LOCAL:
C
C     IERR - error return from FMP routines
C     ICH - character counter
C     LNAMEF - full file name
      integer*4 irec,ioff
      integer fmpposition,fmpreadstr,fmpsetpos,fmpwritestr
      integer trimlen
      character*28 lnamef
      character*80 ibc
      integer*2 ib(40)
      equivalence (ib,ibc)
C
C
C     1. First try to open the file.
C     The file is opened non-exclusively and in update mode.
C
      nch = trimlen(lprc)
      lnamef = FS_ROOT//'/proc/' // lprc(1:nch) // '.prc'
      call fmpopen(idcb,lnamef,ierr,'r+',id)
      if (ierr.lt.0) return
C
C     2. The file is opened.  Read through all lines.
C     If we encounter DEFINE, then execute next section.
C
      nproc = 0
210   ilen = fmpreadstr(idcb,ierr,ibc)
      if (ilen.lt.0) goto 900
      if (ierr.lt.0) goto 990
      if (ibc(1:6).eq.'define') then
C
C     3. Fill up LPROC with the information on this file location.
C
        if (nproc+1.gt.maxpr) then
          call logit7ci(0,0,0,1,-126,'bo',maxpr)
          goto 990
        endif
        nproc = nproc + 1
        idum=ichmv(lproc (1,nproc),1,ib,9,12)
        id = fmpposition(idcb,ierr,irec,ioff)
        irectmp = irec - ilen - 1
        if(nproc.gt.1) then
           if(irectmp.lt.lproc(4,nproc-1)) then
              call logit7ci(0,0,0,1,-210,'bo',0)
              nproc=nproc-1
              goto 990
           endif
        endif
        lproc(4,nproc) = irectmp
c       lproc(5,nproc) = ioff
        if (old.eq.'n') then
          irec = irectmp
          idum = fmpsetpos(idcb,ierr,irec,-irec)
          ibc(23:34)='00000000000x'
          ilen = fmpwritestr(idcb,ierr,ibc(:ilen))
          irec= irec + ilen + 1
          idum = fmpsetpos(idcb,ierr,irec,-irec)
          if(ierr.lt.0) goto 900
        endif
      endif
      goto 210
C
C     9. Normal ending because EOF is reached.
C
900   ierr = 0
C
990   idum = fmpsetpos(idcb,ierr,0,id)
      return
      end
