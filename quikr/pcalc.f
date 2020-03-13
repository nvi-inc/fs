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
      subroutine pcalc(ip)
C  phase cal setup control c#870115:04:50#
C 
C     PCALC sets up the common variables necessary for
C      the proper execution of program PCALR
C 
C     INPUT VARIABLES:
C 
      integer*4 ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: GTPRM
C         IVC2T - gets track with phase cal given VC# 
C         IPHCK - check for phase cal in given track
C 
C   LOCAL VARIABLES 
C 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
C        ITN    - number of tracks typed in 
      dimension itrk(28)
C               - temporary holder for track codes
      dimension it(28)
C               - holder for tracks individually typed in 
      dimension icn1(4),icn2(4) 
C               - hold first and second indices for each LO 
C        ILO    - number of LO's
      dimension i1dex(14),i2dex(14) 
C               - LO indices for all 14 VC's
      dimension imin(4),imax(4) 
C               - VC's having min & max values for each LO
      integer*2 ibuf(40)
C               - class buffer
C        ILEN   - length of IBUF, chars 
      dimension iparm(2)
C               - parameters returned from GTPRM
      dimension ireg(2) 
      integer get_buf,ichcm_ch
C               - registers from EXEC calls 
      logical rn_test
C 
c     double precision pcal 
C               - phase cal frequency 
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C  INITIALIZED VARIABLES
C 
      data ilen/80/ 
C 
C  PROGRAMMER: NRV & MAH
C     LAST MODIFIED: 820305 
C 
C 
C     1. If we have a class buffer, then we are to set the
C     variables in common for PCALR to use. 
C 
      ichold = -99
      iclcm = ip(1) 
      if (iclcm.ne.0) goto 110
      ierr = -1 
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C                   If no parameters, schedule PCALR
      if (cjchar(ibuf,ieq+1).ne.'?') goto 210
      ip(1) = 0 
      ip(4) = o'77' 
      call pcdis(ip,iclcm)
      return
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C        PCAL=<#cycles>,<pause>,<repro>,<#blocks>,<debug>,<track>,<track>,... 
C     Choices are <#cycles>: >=0, default 0 (runs continuosly), NCYCPC
C                 <pause>  : >=0, default 60 seconds, IPAUPC
C                 <repro>  : FS,BY,RW,AB, default FS, IREPPC
C                 <#blocks>: >=1, default 25, NBLKPC
C                 <debug>  : -2 to +2, default 0, IBUGPC
C                 <track>  : can be tracks or VC#s, VC's preceeded with 
C                            V, can also be ALL,EVEN,ODD,VEVEN,VODD,VALL
C                            sets array ITRKPC. 
C 
C     2.1 FIRST PARM, # OF CYCLES 
C 
210   continue
      ich = 1+ieq 
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.',') icyc = 0
C                 The default is 0
      if (cjchar(parm,1).eq.'*') icyc = ncycpc 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') 
     .   icyc=iparm(1)
      if (icyc.ge.0) goto 220 
      ierr = -200-1 
C                 Number of cycles thru' PCALR must be GE.0 
      goto 990
C 
C     2.2 PARM #2, PAUSE BETWEEN CYCLES THRU' PCALR 
C 
220   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') ipau=iparm(1) 
      if (cjchar(parm,1).eq.',') ipau = 60 
C                      Default is 60 seconds
      if (cjchar(parm,1).eq.'*') ipau = ipaupc 
      if (ipau.ge.0.and.ipau.le.1800) goto 230
      ierr = -200-2 
      goto 990
C 
C     2.3 THIRD PARM, REPRODUCE MODE
C 
230   continue
      irep = -1 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (ichcm_ch(parm,1,'fs').eq.0) then
        irep = 0 
      else if (ichcm_ch(parm,1,'by').eq.0) then 
        irep = 1 
      else if (ichcm_ch(parm,1,'rw').eq.0) then 
        irep = 2 
      else if (ichcm_ch(parm,1,'ab').eq.0) then 
        irep = 3 
      else if (cjchar(parm,1).eq.',') then 
        irep = 0                     ! Default is FS mode
      else if (cjchar(parm,1).eq.'*') then 
        irep = ireppc 
      endif
      iby = 1 
      if (irep.eq.2) iby = 0
      if (irep.eq.0) iby = ibyppc 
      if (irep.ne.-1) goto 240
      ierr = -200-3 
      goto 990
C 
C     2.4 4TH PARM, NUMBER OF BLOCKS TO PROCESS 
C 
240   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.',') nblk = 25 
C                 Default is 25 blocks
      if (cjchar(parm,1).eq.'*') nblk = nblkpc 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') nblk=iparm(1) 
      if (nblk.gt.0.and.nblk.le.256) goto 250 
      ierr = -200-4 
      goto 990
C 
C     2.5 5TH PARM, DEBUG CONTROL 
C 
250   continue
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).eq.',') ibug = 0
C                 Default is 0 debug
      if (cjchar(parm,1).eq.'*') ibug = ibugpc 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') ibug=iparm(1) 
      if (ibug.gt.-3.and.ibug.le.2) goto 260
      ierr = -200-5 
      goto 990
C 
C     2.6 6TH AND FURTHER PARMS, TRACKS AND VC#'S 
C     First check for ALL, EVEN, ODD
C     and then check for VALL, VEVEN, VODD. 
C 
260   continue
      do i=1,28 
        itrk(i) = -1
      enddo
      ic1 = ich 
C 
C         set ITRK for default and ALL
C 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.',') goto 263
C                    - first do default 
      goto 264
263   if (ichcm_ch(parm,1,'all').ne.0) goto 267 
264   if (irep.ne.3) goto 265 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
265   do i=1,28 
        if (iphck(i).ne.0) itrk(i) = 100
      enddo
      goto 304
C 
C         set ITRK for EVEN tracks
C 
267   if (ichcm_ch(parm,1,'even').ne.0) goto 270 
      if (irep.ne.3) goto 268 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
268   do i= 2,28,2 
        if (iphck(i).ne.0) itrk(i) = 100
      enddo
      goto 304
C 
C         set ITRK for ODD tracks 
C 
270   if (ichcm_ch(parm,1,'odd').ne.0) goto 273 
      if (irep.ne.3) goto 271 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
271   do i=1,28,2 
        if (iphck(i).ne.0) itrk(i) = 100
      enddo
      goto 304
C 
C         set ITRK for ALL video converters 
C 
273   if (ichcm_ch(parm,1,'vall').ne.0) goto 276 
      if (irep.ne.3) goto 274 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
274   do 275 i = 1,14 
          idumm1 = ivcat(i,itrk,1,-1) 
275       continue
          goto 304
C 
C         set ITRK for EVEN video converters
C 
276   if (ichcm_ch(ibuf,ic1,'veven').ne.0) goto 279
      if (irep.ne.3) goto 277 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
277   do 278 i = 2,14,2 
          idumm1 = ivcat(i,itrk,1,-1) 
278       continue
          goto 304
C 
C         set ITRK for ODD video converters 
C 
279   if (ichcm_ch(parm,1,'vodd').ne.0) goto 290 
      if (irep.ne.3) goto 280 
C                   error if split mode (AB)
      ierr = -206 
      goto 990
280   do 281 i = 1,14,2 
          idumm1 = ivcat(i,itrk,1,-1) 
281       continue
          goto 304
C 
C     If not default or ALL etc., decode each subsequent
C     entry as either Vnn or nn.
C 
290   continue
      itn = 1 
291   if (cjchar(parm,1).ne.'v') goto 295 
      nch = 2 
      if (cjchar(parm,3).eq.' ') nch = 1 
      iiv = ias2b(parm,2,nch) 
      if (iiv.ge.1.and.iiv.le.14) goto 292
      ierr = -200-7 
      goto 990
292   if (ivcat(iiv,it,itn,irep).eq.1) goto 297 
      ierr = -200-8 
      goto 990
295   continue
      nch = 2 
      if (cjchar(parm,2).eq.' ') nch = 1 
      it(itn) = ias2b(parm,1,nch) 
      if (iphck(it(itn)).ne.0) goto 296 
      itn = itn-1 
      goto 297
296   if (it(itn).gt.0.and.it(itn).le.28) goto 297
      ierr = -200-7 
      goto 990
297   continue
      itn = itn+1 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.',') goto 291
      if (itn.gt.1) goto 300
      ierr = -200-9 
      goto 990
C 
300   if (irep.eq.3) goto 301 
      if (irep.eq.0) goto 312 
      do 302 i = 1,itn-1
302       itrk(it(i)) = 100 
      goto 400
301   if (itn.eq.3) goto 303
      ierr = -200-6 
      goto 990
303   itrk(it(1)) = it(2) 
      goto 400
C 
C     Set up LO indices for each VC 
C 
304   continue
      if (irep.ne.0) goto 400 
      itn = 1 
      do 308 i = 1,28 
          if (itrk(i).le.0) goto 308
          it(itn) = i 
          itn = itn+1 
308       continue
312   continue
      call fs_get_inp1if(inp1if)
      call fs_get_inp2if(inp2if)
      call fs_get_ifp2vc(ifp2vc)
      do 305 i = 1,14 
          i1dex(i) = iabs(ifp2vc(i))
          if (i1dex(i).eq.1) i2dex(i) = inp1if+1
          if (i1dex(i).eq.2) i2dex(i) = inp2if+1
305       continue
C 
C     Now find the outer and inner tracks for split mode
C 
      icn1(1) = i1dex(1)
      icn2(1) = i2dex(1)
      ilo = 1 
C 
      do 310 i = 1,14 
          if (i.eq.1) goto 306
C                Check if we have already done this LO
          do 309 ix = 1,ilo-1 
              if(i1dex(i).eq.icn1(ix).and.i2dex(i).eq.icn2(ix)) goto 310
309           continue
          icn1(ilo) = i1dex(i)
          icn2(ilo) = i2dex(i)
C                 Remember this LO if it is new 
306       ivcmin = i
          ivcmax = i
          call fs_get_freqvc(freqvc)
          do 307 ij = i+1,14
              if (i1dex(i).ne.i1dex(ij).or.i2dex(i).ne.i2dex(ij)) 
     .              goto 307
              if (freqvc(ij).lt.freqvc(i)) ivcmin = ij
              if (freqvc(ij).gt.freqvc(i)) ivcmax = ij
307           continue
          imin(ilo) = ivcmin
          imax(ilo) = ivcmax
          ilo = ilo+1 
310       continue
C 
C     Now set up the selected split mode tracks 
C 
      do 322 i = 1,ilo-1
          itmin = ivc2t(imin(i),0)
          itmax = ivc2t(imax(i),0)
          do 315 ij = 1,itn-1 
              if (it(ij).eq.itmin) goto 313 
              goto 315
313           do 316 ik = 1,itn-1 
                  if (it(ik).eq.itmax) goto 317 
                  goto 316
317               itrk(itmin) = itmax 
                  itrk(itmax) = itmin 
316               continue
315           continue
322       continue
C 
C     Finally set the common variables to their new values
C 
400   continue
      ncycpc = icyc 
      ipaupc = ipau 
      ireppc = irep 
      ibyppc = iby
      nblkpc = nblk 
      ibugpc = ibug 
      do i=1,28 
        itrkpc(i) = itrk(i) 
      enddo
      goto 990
C 
C      5.  Schedule Pcalr to start working. 
C          If it's not dormant, then error. 
C 
500   continue
      if(.not.rn_test('pcalr')) goto 510
      ierr = -301 
      goto 990
510   continue
C      Schedule PCALR 
      call run_prog('pcalr','n',ip(1),ip(2),ip(3),ip(4),ip(5))
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qp',ip(4),1,2)
      return
      end 
