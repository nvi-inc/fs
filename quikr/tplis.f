      subroutine tplis(ip,itpis)
C  parse tpi list c#870115:04:30# 
C 
C 1.1.   TPLIS parses the list of possible TPI detectors
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
      integer itpis(1)
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
C     LPRM   - 2-character mnemonic for module name 
      parameter (ibufln=40)
      integer*2 ibuf(ibufln), iprm(4), dtnam
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
C                   <null> - the default gets VC plus IF1 and IF2 
C                   ALL - same as default 
C                   VC - gets V1 to 14
C                   EVEN - even-numbered VCs
C                   ODD - odd-numbered VCs
C                   Vn - VC number n
C                   IFn - IF 1 or 2 or 3
C 
      do i=1,17
        itpis(i) = 0
      enddo
C                   Turn off all of the TPIs to start 
      ich = 1+ieq 
      do 290 i=1,20 
        call fdfld(ibuf,ich,nchar,ic1,ic2)
        if (ic1.eq.0) then
          if (i.eq.1) then        !  if no parameters, set all indicators on
            do ii=1,17
              itpis(ii) = 1
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
        do ii=1,17
          itpis(ii) = 1
        enddo
        goto 290
C 
220     if (ichcm_ch(lprm,1,'ev').ne.0) goto 230
        do ii=2,14,2
          itpis(ii) = 1
        enddo
        goto 290
C 
230     if (ichcm_ch(lprm,1,'od').ne.0) goto 240
        do ii=1,13,2
          itpis(ii) = 1
        enddo
        goto 290
C 
240     if (cjchar(lprm,1).ne.'v') goto 250
C                              V
        ii=jchar(lprm,2)-o'60'
        if (ii.gt.9) ii=ii-39
        if (ii.lt.1 .or. ii.gt.14) goto 285
        itpis(ii) = 1
        goto 290
C 
250     if (cjchar(lprm,1).ne.'i')goto 285
        ii = ias2b(lprm,2,1)
        if (ii.lt.1.or.ii.gt.3) goto 285
        itpis(ii+14) = 1
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
