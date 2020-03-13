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
      integer function getdp(lsorna,ra,dec,epoch,iyr,idoy,ihr,im,is,
     + lant,slon,slat,adiam,lsaxis,imodel,fpver,fsver,
     + laxis,nrep,npts,step,intp,ldev,cal,freq,
     + haoff,decoff,azoff,eloff,xoff,yoff,
     + tsaz,tsel,tsys,
     + iayr,iadoy,iahr,iam,ias,iats,anlon,anlat,erlon,erlat,
     + prlon,prlat,praz,prel,
     + ltoff,ltwid,ltpk,ltbas,ltslp,ltfc,
     + ltsoff,ltswid,ltspk,ltsbas,ltsslp,ltrchi,
     + lnoff,lnwid,lnpk,lnbas,lnslp,lnfc,
     + lnsoff,lnswid,lnspk,lnsbas,lnsslp,lnrchi,
     + loncor,latcor,lonoff,latoff,iqlon,iqlat,
     + numlin,lintim,linpos,lintmp,nlin,ierlin,ndlin,
     + numlat,lattim,latpos,lattmp,nlat,ierlat,ndlat,
     + numlon,lontim,lonpos,lontmp,nlon,ierlon,ndlon,
     + lut,idcb,idcbz,jbuf,il,irrec,nrec,ierr,len,jerr)
C
C GETDP - GET Data Point from FIVPT's output
C
C This routine returns the data from upto one complete scan, with the
C the following restrictions:
C
C   1. An out of order record ends this scan, but will be used in the
C      next call.
C
C   2. The output lines from FIVPT and ANTCN are given record numbers
C      as follows:
C 
C      TYPE        ID                WRITER 
C 
C         1        SOURCE            FIVPT
C         2        SITE              FIVPT
C         3        FIVEPT            FIVPT
C         4        ORIGIN            FIVPT
C         5        TSYS              FIVPT
C         6        TR                ANTCN
C         7        PR                ANTCN
C         8        LATFIT            FIVPT
C         9        LATERR            FIVPT
C        10        LONFIT            FIVPT
C        11        LONERR            FIVPT
C        12        OFFSET            FIVPT
C                  LIN               FIVPT
C                  LAT               FIVPT
C                  LON               FIVPT
C 
C      The array IRREC is returned with the element corresponding to
C      each type set according to what was found: 
C      0 for not found before end of scan or first out of order record
C      1 for     found "                                             "
C     -n for an  found, but there was at least one error, the first was in
C                       field n 
C 
C      LIN, LAT, and LON types status is returned in IERLIN, IERLAT, AND
C      IERLON variables respectively, as the number of records with errors
C      NLIN, NLAT, and NLON hold the number of each type found with no error
C 
      integer iyr,idoy,ihr,im,is 
      integer nrep,npts,intp,ldev(2) 
      integer*2 laxis(1),lant(1),lsaxis(1),lsorna(1),jbuf(1) 
      integer imodel
      integer iayr,iadoy,iahr,iam,ias,iats
      integer ltfc
      integer lnfc
      integer iqlat,iqlon 
      integer nlin,ierlin,ndlin
      integer nlat,ierlat,ndlat
      integer nlon,ierlon,ndlon
      integer lut,idcb(1),idcbz,il,nrec,ierr,len,jerr 
C 
      integer numlin(1), numlat(1), numlon(1), irrec(1)
C
      real ra,dec,epoch 
      real step,cal,freq
      real slon,slat,adiam,fpver,fsver
      real haoff,decoff,azoff,eloff,xoff,yoff 
      real tsaz,tsel,tsys 
      real anlon,anlat,erlon,erlat
      real prlon,prlat,praz,prel
      real ltoff,ltwid,ltpk,ltbas,ltslp 
      real ltsoff,ltswid,ltspk,ltsbas,ltsslp,ltrchi 
      real lnoff,lnwid,lnpk,lnbas,lnslp 
      real lnsoff,lnswid,lnspk,lnsbas,lnsslp,lnrchi 
      real loncor,latcor,lonoff,latoff
C 
      real lintim(1),linpos(1),lintmp(1) 
      real lattim(1),latpos(1),lattmp(1) 
      real lontim(1),lonpos(1),lontmp(1) 
C
      logical kret
      save ifc,ilc
C
C  RECORD IDENTIFIERS, MUST INCLUDE 1 SPACE AT END TO GUARANTEE CORRECT MATCH
C
      integer*2 lsorce(5)
      integer*2 lsite(4)
      integer*2 lfivpt(5)
      integer*2 lorign(5)
      integer*2 ltsys(4)
      integer*2 ltrac(3)
      integer*2 lpred(3)
      integer*2 lltfit(5)
      integer*2 llterr(5)
      integer*2 llnfit(5)
      integer*2 llnerr(5)
      integer*2 lofset(5),lxofset(5)
      integer*2 llin(3)
      integer*2 llat(3)
      integer*2 llon(3)
C 
      data lsorce/7,2hso,2hur,2hce,2h  /        ! source
      data lsite/5,2hsi,2hte,2h  /              ! site
      data lfivpt/7,2hfi,2hve,2hpt,2h  /        ! fivept
      data lorign/7,2hor,2hig,2hin,2h  /        ! origin
      data ltsys/5,2hts,2hys,2h  /              ! tsys
      data ltrac/3,2htr,2h  /                   ! tr
      data lpred/3,2hpr,2h  /                   ! pr
      data lltfit/7,2hla,2htf,2hit,2h  /        ! latfit
      data llterr/7,2hla,2hte,2hrr,2h  /        ! laterr
      data llnfit/7,2hlo,2hnf,2hit,2h  /        ! lonfit
      data llnerr/7,2hlo,2hne,2hrr,2h  /        ! lonerr
      data lofset/7,2hof,2hfs,2het,2h  /        ! offset
      data lxofset/8,2hxo,2hof,2hse,2ht /        ! offset
      data llin/4,2hli,2hn /                    ! lin
      data llat/4,2hla,2ht /                    ! lat
      data llon/4,2hlo,2hn /                    ! lon
C
      data inm/0/,ir/0/ 
C
      getdp=0 
      jerr=0
      nlat=0
      nlon=0
      nlin=0
      ierlin=0
      ierlat=0
      ierlon=0
C 
      do i=1,nrec
        irrec(i)=0 
      enddo
C 
      if (ir.gt.0) goto 110 
C 
100   continue
      call gnext(lut,idcb,ierr,jbuf,il,len,ifc,ilc) 
      if (ierr.ne.0.or.len.lt.0) return
C 
110   continue
      ir=0
      ilen = lsorce(1)
      if (ichcm(jbuf,ifc,lsorce,3,ilen).eq.0) ir= 1 
      ilen = lsite(1)
      if (ichcm(jbuf,ifc,lsite ,3,ilen).eq.0) ir= 2 
      ilen = lfivpt(1) 
      if (ichcm(jbuf,ifc,lfivpt,3,ilen).eq.0) ir= 3 
      ilen = lorign(1) 
      if (ichcm(jbuf,ifc,lorign,3,ilen).eq.0) ir= 4 
      ilen = ltsys(1) 
      if (ichcm(jbuf,ifc,ltsys ,3,ilen).eq.0) ir= 5 
      ilen = ltrac(1) 
      if (ichcm(jbuf,ifc,ltrac ,3,ilen).eq.0) ir= 6 
      ilen = lpred(1) 
      if (ichcm(jbuf,ifc,lpred ,3,ilen).eq.0) ir= 7 
      ilen = lltfit(1) 
      if (ichcm(jbuf,ifc,lltfit,3,ilen).eq.0) ir= 8 
      ilen = llterr(1) 
      if (ichcm(jbuf,ifc,llterr,3,ilen).eq.0) ir= 9 
      ilen = llnfit(1) 
      if (ichcm(jbuf,ifc,llnfit,3,ilen).eq.0) ir= 10
      ilen = llnerr(1) 
      if (ichcm(jbuf,ifc,llnerr,3,ilen).eq.0) ir= 11
      ilen = lofset(1) 
      if (ichcm(jbuf,ifc,lofset,3,ilen).eq.0) ir= 12
      ilen = lxofset(1) 
      if (ichcm(jbuf,ifc,lxofset,3,ilen).eq.0) ir= 13
      ilen = llin(1) 
      if (ichcm(jbuf,ifc,llin  ,3,ilen).eq.0) ir= 30
      ilen = llat(1) 
      if (ichcm(jbuf,ifc,llat  ,3,ilen).eq.0) ir= 31
      ilen = llon(1) 
      if (ichcm(jbuf,ifc,llon  ,3,ilen).eq.0) ir= 32
C 
C NOT A KNOWN RECORD TYPE, GET ANOTHER
C 
      if (ir.eq.0) goto 100 
C 
C  SAVE PREVIOUS RECORD NUMBER
C 
       ipr=inm
       inm=0
C 
C CHECK FOR CORRECT RECORD ORDER, LOGIC IS: 
C 
C   IF   THE PREVIOUS RECORD WAS X AND THIS RECORD TYPE IS NOT ALLOWED TO 
C        FOLLOW RECORD X
C   THEN RETURN 
C 
C         PREVIOUS        CURRENT 
C 
      kret= 
     +   (ipr.eq. 1 .and. ir.ne. 2                              ) .or.
     +   (ipr.eq. 2 .and. ir.ne. 3                              ) .or.
     +   (ipr.eq. 3 .and. ir.ne. 4                              ) .or.
     +   (ipr.eq. 4 .and.(ir.ne. 5 .and. ir.ne. 6 .and. ir.ne.30 .and.
     +                    ir.ne.31)                              ).or.
     +   (ipr.eq. 5 .and.(ir.ne. 6 .and. ir.ne.30 .and. ir.ne.31)).or.
     +   (ipr.eq. 6 .and. ir.ne. 7                              ) .or.
     +   (ipr.eq. 7 .and.(ir.ne. 8 .and. ir.ne.30 .and. ir.ne.31)).or.
     +   (ipr.eq. 8 .and. ir.ne. 9                              ) .or.
     +   (ipr.eq. 9 .and.(ir.ne.10 .and. ir.ne.30 .and. ir.ne.32)).or.
     +   (ipr.eq.10 .and. ir.ne.11                              ) .or.
     +   (ipr.eq.11 .and. ir.ne.12                              ) .or.
     +   (ipr.eq.13 .and. ir.ne.1                               ) .or.
     +   (ipr.eq.30 .and.(ir.ne.31 .and. ir.ne.32 .and. ir.ne. 8
     +              .and. ir.ne.10)                             ) .or.
     +   (ipr.eq.31 .and.(ir.ne.30 .and. ir.ne.31 .and. ir.ne. 8)).or.
     +   (ipr.eq.32 .and.(ir.ne.30 .and. ir.ne.32 .and. ir.ne.10))
      if (ir.eq.6.or.ir.eq.7.and.kret) goto 100 
      if (kret) return 
C 
      inm=ir
      getdp=1 
C 
      if (ir.lt.30) goto (1000,2000,3000,4000,5000,6000,7000,8000,9000, 
     +   10000,11000,12000,13000),ir
      if (ir.ge.30) goto (30000,31000,32000),ir-29
C 
C  SHOULD BE IMPOSSIBLE 
C 
      jerr=1000 
      return
C 
C  SOURCE RECORD
C 
1000  continue
      ifc=ifc+lsorce(1) 
      call desor(jbuf,ifc,ilc,lsorna,ra,dec,epoch,iyr,idoy,ihr,im,is, 
     +           irrec(1))
      goto 100 
C 
C SITE   RECORD 
C 
2000  continue
      ifc=ifc+lsite(1)
      call desit(jbuf,ifc,ilc,lant,slon,slat,adiam,lsaxis,imodel,fpver, 
     +           fsver,irrec(2))
      goto 100 
C 
C FIVEPT RECORD 
C 
3000  continue
      ifc=ifc+lfivpt(1) 
      call defiv(jbuf,ifc,ilc,laxis,nrep,npts,step,intp,ldev,cal,freq,
     +           irrec(3))
      goto 100 
C 
C  ORIGIN RECORD
C 
4000  continue
      ifc=ifc+lorign(1) 
      call deorg(jbuf,ifc,ilc,haoff,decoff,azoff,eloff,xoff,yoff, 
     +           irrec(4))
      goto 100 
C 
C  TSYS   RECORD
C 
5000  continue
      ifc=ifc+ltsys(1)
      call detsy(jbuf,ifc,ilc,tsaz,tsel,tsys,irrec(5))
      goto 100 
C 
C  ANTCN  TR RECORD 
C 
6000  continue
      ifc=ifc+ltrac(1)
      call detr(jbuf,ifc,ilc,iayr,iadoy,iahr,iam,ias,iats,
     +           anlon,anlat,erlon,erlat,irrec(6))
      goto 100 
C 
C  ANTCN  PR RECORD 
C 
7000  continue
      ifc=ifc+lpred(1)
      call depr(jbuf,ifc,ilc,prlon,prlat,praz,prel,irrec(7))
      goto 100 
C 
C   LATFIT RECORD 
C 
8000  continue
      ifc=ifc+lltfit(1) 
      call defit(jbuf,ifc,ilc,ltoff,ltwid,ltpk,ltbas,ltslp,ltfc,
     +           irrec(8))
      goto 100 
C 
C   LATERR RECORD 
C 
9000  continue
      ifc=ifc+llterr(1) 
      call deerr(jbuf,ifc,ilc,ltsoff,ltswid,ltspk,ltsbas,ltsslp,ltrchi, 
     +           irrec(9))
      goto 100 
C 
C   LONFIT RECORD 
C 
10000 continue
      ifc=ifc+llnfit(1) 
      call defit(jbuf,ifc,ilc,lnoff,lnwid,lnpk,lnbas,lnslp,lnfc,
     +           irrec(10)) 
      goto 100 
C 
C   LONERR RECORD 
C 
11000 continue
      ifc=ifc+llnerr(1) 
      call deerr(jbuf,ifc,ilc,lnsoff,lnswid,lnspk,lnsbas,lnsslp,lnrchi, 
     +           irrec(11)) 
      goto 100 
C 
C   OFFSET RECORD 
C 
12000 continue
      ifc=ifc+lofset(1) 
      call deoff(jbuf,ifc,ilc,loncor,latcor,lonoff,latoff,iqlon,iqlat,
     +           irrec(12))
      inm=0
      ir=0
      return
C
C  XOFFSET RECORD - IGNORE
C
13000 continue
      goto 100
C 
C   LIN    RECORD 
C 
30000 continue
      ifc=ifc+llin(1) 
      call depnt(jbuf,ifc,ilc,numlin,lintim,linpos,lintmp,nlin,ierlin,
     +           ndlin) 
      goto 100 
C 
C   LAT    RECORD 
C 
31000 continue
      ifc=ifc+llat(1) 
      call depnt(jbuf,ifc,ilc,numlat,lattim,latpos,lattmp,nlat,ierlat,
     +           ndlat) 
      goto 100 
C 
C   LON    RECORD 
C 
32000 continue
      ifc=ifc+llon(1) 
      call depnt(jbuf,ifc,ilc,numlon,lontim,lonpos,lontmp,nlon,ierlon,
     +           ndlon) 
      goto 100 
C 
c     return
      end 
