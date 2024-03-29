*
* Copyright (c) 2020, 2022 NVI, Inc.
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
      program aquir
C
      logical kinit,kgetc,knup
C
      real cra(200),cdec(200),cepoch(200),azar(37),elar(36)
      integer*2 jbuf(120),lname(5,200),lcpre(6,200),lcpos(6,200)
      character*63 icbuf,stsrc
      integer iwpre(200),iwfiv(200),iwonof(200),iwpeak(200),iwpos(200)
      integer*2 lset(6),lter(6),lwho
      logical kbreak
      integer rn_take,ilen,trimlen
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      data il/120/,msorc/200/,mprc/6/,ierr/0/,mc/5/,lwho/2Haq/
      data imsmax/36/
c
      call setup_fscom
      call fmperror_standalone_set(0)
c
 1    continue
      call wait_prog('aquir',ip)
      if(0.ne.rn_take('aquir',1)) then
        call logit6(idum,idum,idum,-2,ierr,lwho)
        goto 1
      endif

      call read_fscom
C
C  GET RID OF ANY BREAKS THAT WERE HANGING AROUND
C
2     continue
      if (kbreak('aquir')) goto 2
C
      if (kinit(icbuf,stsrc)) goto 10020
C
      if (kgetc(icbuf,jbuf,il,lset,iwset,lter,iwter,azar,
     +  elar,imask,imsmax,elmax,lname,cra,cdec,cepoch,lcpre,iwpre,iwfiv,
     +  iwonof,iwpeak,lcpos,iwpos,nsorc,mc,msorc,mprc,isrcwt,isrcld))
     +  goto 10020
C
      call scmd(lset,iwset,mprc,ierr)
      if (ierr.ne.0) goto 10010
C
      if(stsrc.ne.'$'.and.stsrc.ne.' ') then
         ilen=trimlen(stsrc)
         if(ilen.lt.10) then
            ilen=ilen+1
         else
            ilen=10
         endif
          do j=1,nsorc
            if(0.eq.ichcm_ch(lname(1,j),1,stsrc(:ilen))) then
               i=j
               goto 11
            endif
         enddo
      endif
c            
10    continue
      i=1
 11   continue
      if(i.gt.nsorc) goto 100
C
      if(knup(lname(1,i),cra(i),cdec(i),cepoch(i),az,el,azar,elar,imask,
     +   elmax,mc,isrcld)) goto 90
C
      call ssrc(lname(1,i),cra(i),cdec(i),cepoch(i),jbuf,il,ierr)
      if (ierr.ne.0) goto 10010
C
      call onsor(isrcwt,ierr)
      if (ierr.eq.-20) goto 90
      if (ierr.ne.0) goto 10010
C
      call scmd(lcpre(1,i),iwpre(i),mprc,ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('fivept','fivpt',iwfiv(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('onoff','onoff',iwonof(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call sctl('peakf','peakf',iwpeak(i),ierr)
      if (ierr.ne.0) goto 10010
C
      call scmd(lcpos(1,i),iwpos(i),mprc,ierr)
      if (ierr.ne.0) goto 10010
C
90    continue
      i=i+1
      goto 11
C
100   continue
      call susp(2,2)
      if (kbreak('aquir')) goto 200
      goto 10
C
200   continue
      ierr=-1
      goto 10010
C
10010 continue
      if(ierr.eq.-2) goto 11000     !fs is gone
      if (ierr.gt.-2) goto 10015
      call logit6(idum,idum,idum,-1,ierr,lwho)
      goto 11000
C
10015 continue
      call scmd(lter,iwter,mprc,jerr)
      call logit6(idum,idum,idum,-1,ierr,lwho)
      goto 11000
C
10020 continue
      goto 11000
C
11000 continue
      call rn_put('aquir')
      goto 1
      end
