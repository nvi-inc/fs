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
      logical function kgetp(lut,idcb,idcbs,ipbuf,jbuf,il,
     +   iedit,widmin,widmax,pkrlim,laxis,lant,iflags)
C
      integer idcb(1)
      integer*2 jbuf(1),laxis(2),lant(4)
      logical kfild,kreof,kopn
      character*(*) ipbuf
      integer fmpread, ichcm_ch
C
      data mrec/3/
C
      kgetp=.true.
      iedit=0
      iflags=0
C
C   OPEN THE DATA FILE
C
      call fmpopen(idcb,ipbuf,ierr,'r',id)
      if (kopn(lut,ierr,ipbuf,0)) goto 9100
C
      ierr=0
      irec=0
      iferr=0
C
50    continue
      if (kfild(lut,iferr,-iferr,irec,ipbuf)) goto 8050
      if (irec.ge.mrec) goto 8900
      len = fmpread(idcb,ierr,jbuf,il*2)
      if (len.gt.0) then
        if (mod(len,2).eq.1) then
          len=len+1
          idum=ichmv_ch(jbuf,len,' ')
        endif
      endif
      call lower(jbuf,len)
      if(kreof(lut,ierr,len,irec+1,ipbuf)) goto 8060
C
      ilc=len
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 50
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 50
      irec=irec+1
      ilc=len
      ifc=1
      ifield=0
C
C GET DATA
C
      goto (100,200,300), irec
C
C  1ST RECORD: SITE INFO
C
100   continue
C
C   ANTENNA NAME
C
      call gtchr(lant,1,8,jbuf,ifc,ilc,ifield,iferr)
C
C   AXIS TYPE
C
      call gtchr(laxis,1,4,jbuf,ifc,ilc,ifield,iferr)
      goto 50
C
C  2ND RECORD: MANUAL EDIT DATA
C
200   continue
C
C   USE ADDITONAL EDIT CRITERIA
C
       iedit=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C   HALF-WIDTH MINIMUM
C
      widmin=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
C   HALF-WIDTH MAXIMUM
C
      widmax=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
C   PEAK TEMPERATURE RATIO LIMIT
C
      pkrlim=gtrel(jbuf,ifc,ilc,ifield,iferr)
      goto 50
C
C  3rd RECORD: CONTROL FLAGS
C
 300  continue
C
C   control flag, 0=FEC in AZ, 1=FEC in XEL
C
       iflags=igthx(jbuf,ifc,ilc,ifield,iferr)
       goto 50
C
C FIELD ERROR
C
8050  continue
      ierr=-998
      goto 9000
C
C READ OR EOF ERROR
C
8060  continue
      if (ierr.eq.0) ierr=-999
      goto 9000
C
C DONE
C
8900  continue
      kgetp=.false.
      goto 9000
C
C CLOSE DCB
C
9000  continue
      call fmpclose(idcb,ierr)
C
C JUST EXIT
C
9100  continue
C
      return
      end
