      subroutine tplisv(ip,itpis_vlba)
C  parse tpi list c#870115:04:30# 
C 
C 1.1.   TPLISV parses the list of possible TPI detectors for
C        a VLBA rack.
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C               - parameters from SLOWP 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C 
C     OUTPUT VARIABLES: 
C 
      integer itpis_vlba(1)
C      - TPIs requested, 0=not wanted, 1=get it 
C        IP(3) - ERROR RETURN 
C        IP(4) - who we are 
C 
C     CALLED SUBROUTINES: FDFLD,JCHAR,DTNAM 
C 
C 3.  LOCAL VARIABLES 
C 
C        ICH    - character counter 
C     NCHAR  - character count
C     LPRM   - 2-character mnemonic for detector name 
      parameter (ibufln=40)
      integer*2 ibuf(ibufln), iprm(4), dtnam, lprm
C               - class buffer, holding command 
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf, ichcm_ch
C               - registers from EXEC calls 
      character cjchar
C 
      equivalence (reg,ireg(1))
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ilen/80/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  840308  MWH  added call to MDNAM for module mnemonic
C 
C     PROGRAM STRUCTURE 
C 
C     1. If class buffer contains command name with "=" then we have
C     parameters to get the TPIs.  If only the command name is present, 
C     then use the default. 
C 
      ierr = 0
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ibufln*2,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) ieq = nchar + 1 
C                   Set counter to end of command for default 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user looks like: 
C                   TPI=<list>
C     where <list> may contain the following key words: 
C                   <null> - the default gets BBC plus IFA IFB IFC IFD
C                   ALL - same as default 
C                   BBCU - gets B1 to 15 USB
C                   BBCL - gets B1 to 15 LSB
C                   EVENU - even-numbered BBCs USB
C                   EVENL - even-numbered BBCs LSB
C                   ODDU - odd-numbered BBCs USB
C                   ODDL - odd-numbered BBCs LSB
C                   IFn - IF a, b, c, or d 
C 
      do i=1,34 
        itpis_vlba(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,34 
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if (ic1.eq.0) then
          if (i.eq.1) then        !  if no parameters, set all indicators on
            do ii=1,34
              itpis_vlba(ii) = 1
            enddo
          endif
          goto 990
        endif
        inumb=ic2-ic1+1
        inumb=min(inumb,8)
        idum = ichmv(iprm,1,ibuf,ic1,inumb)
        ich=ic2+2 !! point beyond next comma
C                   Pick up each parameter as characters
        lprm=dtnam(iprm,1,inumb)
        if (cjchar(iprm,1).eq.'*') goto 280
C                           * 
C                   We haven't any stored values to pick up here
C 
        if (lprm.eq.0) goto 285
        if (ichcm_ch(lprm,1,'al').ne.0) goto 220
        do ii=1,34
          itpis_vlba(ii) = 1
        enddo
        goto 290
C 
220     if (ichcm_ch(lprm,1,'vu').ne.0) goto 225
        do ii=3,27,4
          itpis_vlba(ii) = 1
        enddo
        goto 290
C
225     if (ichcm_ch(lprm,1,'vl').ne.0) goto 230
        do ii=4,28,4
          itpis_vlba(ii) = 1
        enddo
        goto 290
C 
230     if (ichcm_ch(lprm,1,'ou').ne.0) goto 235
        do ii=1,29,4
          itpis_vlba(ii) = 1
        enddo
        goto 290
C
235     if (ichcm_ch(lprm,1,'ol').ne.0) goto 240
        do ii=2,30,4
          itpis_vlba(ii) = 1
        enddo
        goto 290
C 
240     continue 
        if (((cjchar(lprm,1).ge.'1').and.(cjchar(lprm,1).le.'9')).or.
     .      ((cjchar(lprm,1).ge.'a').and.(cjchar(lprm,1).le.'f'))) then
          ii=jchar(lprm,1) - 48  !! turns hollerith into integer
          if (ii.gt.9) ii=ii-39  !! if a thru f subtract to get correct
C                              !! integer
          if (ii.lt.1 .or. ii.gt.15) goto 285
          if (cjchar(lprm,2).eq.'u') then
            itpis_vlba(ii*2-1) = 1
          else if (cjchar(lprm,2).eq.'l') then
            itpis_vlba(ii) = 1
          else
            goto 285
          endif
          goto 290
        endif
C 
250     if (ichcm_ch(lprm,1,'i').ne.0) goto 285
          if (ichcm_ch(lprm,2,'a').eq.0) then
            itpis_vlba(31) = 1
          else if (ichcm_ch(lprm,2,'b').eq.0) then
            itpis_vlba(32) = 1
          else if (ichcm_ch(lprm,2,'c').eq.0) then
            itpis_vlba(33) = 1
          else if (ichcm_ch(lprm,2,'d').eq.0) then
            itpis_vlba(34) = 1
          else
            goto 285
          endif
        goto 290
C 
280     ierr = -100-i
        goto 990
285     ierr = -200-i
        goto 990
C 
290     continue
C 
C 
C     3. We are finished with our job.
C 
990   ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end 
