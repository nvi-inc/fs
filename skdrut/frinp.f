      SUBROUTINE FRINP(IBUF,ILEN,LU,IERR)

C     This routine reads and decodes one line in the $CODES section.
C     Call in a loop to get all values in freqs.ftni filled in,
C     then call SETBA to figure out which frequency bands are there.
C
       INCLUDE 'skparm.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in WORDS
C     LU - unit for error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number
C
       INCLUDE 'freqs.ftni'
       INCLUDE 'statn.ftni'
C
C  LOCAL:
      integer ITRK(4,max_pass),idum
C     integer*2 IP(14)
      integer*2 LNA(4)
      integer ii,ivc,i,icode,istn,inum,itype,is,ns,ibad,j
      integer*2 lc,lsg,lm(4),lid,lin,ls,lsub(4)
      integer*2 lst(4,max_stn)
      logical kvlba,kmk3
      character*3 cs
      real*4 f1,f2,f,vb,rbbc
      integer ichcm_ch,jchar,ichmv,igtfr,igtst ! functions
      logical knaeq
C
C  History
C     880310 NRV DE-COMPC'D
C     891116 NRV Cleaned up format, added fill-in of LBAND
C            nrv implicit none
C     930421 nrv Re-added: store track assignments
C 951019 nrv Add extension of LO lines to include per channel
C 951116 nrv Change to frequency sequencey per station
C
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
      ITYPE=0
      IF (JCHAR(IBUF,1).EQ.OCAPF) ITYPE=3 ! F frequency name, code and stations
      IF (JCHAR(IBUF,1).EQ.OCAPC) ITYPE=1 ! C frequency sequence lines
      IF (JCHAR(IBUF,1).EQ.OCAPL) ITYPE=2 ! L LO lines
      IF (ITYPE.EQ.1) CALL UNPCO(IBUF(2),ILEN-1,IERR,
     .                LC,LSG,F1,F2,IVC,LM,VB,ITRK)
      IF (ITYPE.EQ.2) CALL UNPLO(IBUF(2),ILEN-1,IERR,
     .                LID,LC,LSG,LIN,F,ivc,cs)
      IF (ITYPE.EQ.3) CALL UNPFSK(IBUF(2),ILEN-1,IERR,LNA,LC,lsub,lst,
     .                ns)
C
C 1.5 If there are errors, handle them first.
C
      IF  (IERR.NE.0) THEN
        IERR = -(IERR+100)
        write(lu,9201) ierr,(ibuf(i),i=2,ilen/2)
9201    format('FRINP01 - Error in field ',I3,' of this line:'/40a2)
        RETURN
      END IF 
C  Lines need not be in order, so we may encounter a new code
C  on any line. But this is a bad practice.
      IF  (IGTFR(LC,ICODE).EQ.0) THEN !a new code
        NCODES = NCODES + 1
        IF  (NCODES.GT.MAX_FRQ) THEN !too many codes
          IERR = MAX_FRQ
          ncodes=ncodes-1
          write(lu,9202) ierr
9202      format('FRINP02 - Too many frequency codes.  Max is ',I3,
     .    ' codes.')
          RETURN
        END IF  !too many codes
        ICODE = NCODES
      END IF  !a new code
C
C     2. Now decide what to do with this information.
C     First, handle code type entries, "C" with frequencies.
C
      IF  (ITYPE.EQ.1) THEN  !code entry
        do j=1,nstsav ! apply to each station on the preceding "F" line
          is=istsav(j)
          nvcs(is,icode)=nvcs(is,icode)+1 ! count them
          invcx(nvcs(is,icode),is,icode)=ivc ! index number from "C" line
          LSUBVC(IVC,is,ICODE) = LSG ! sub-group, i.e. S or X
          FREQRF(IVC,is,ICODE) = F1
          VCBAND(ivc,is,ICODE) = VB
          LCODE(ICODE) = LC ! 2-letter code for the sequence
          idum = ichmv(LMODE(1,is,ICODE),1,LM,1,8) ! recording mode
          DO  I=1,max_pass
            IF (ITRK(1,I).NE.-99) itras(1,1,ivc,i,is,icode) = itrk(1,i)
            IF (ITRK(2,I).NE.-99) itras(2,1,ivc,i,is,icode) = itrk(2,i)
            IF (ITRK(3,I).NE.-99) itras(1,2,ivc,i,is,icode) = itrk(3,i)
            IF (ITRK(4,I).NE.-99) itras(2,2,ivc,i,is,icode) = itrk(4,i)
          END DO 
        enddo ! each station on "F" line
      END IF  !code entry
C
C
C     3. Next, LO type entries, from the "L" lines.
C
      IF  (ITYPE.EQ.2) THEN  !LO entry
        IF  (IGTST(LID,ISTN).EQ.0) THEN  !error
          write(lu,'("FRINP03 - Station ",a2," not selected.",
     .    " LO entry on the following line ignored:"/40a2)') lid,
     .    (ibuf(i),i=2,ilen/2)
          IERR = MAX_STN
          RETURN
        END IF  !error
C
        if (ivc.ne.0) then ! per-channel info present
          if (lsg.ne.lsubvc(ivc,istn,icode)) 
     .      write(lu,'("FRINP04 - Subgroup ",a2," inconsistent with ",
     .      a2," for channel ",i3,", station ",4a2)') lsg,
     .      lsubvc(ivc,istn,icode),ivc,(lstnna(i,istn),i=1,4)
          if (lc.ne.lcode(icode)) 
     .      write(lu,'("FRINP05 - Code ",a2," inconsistent with ",
     .      a2," for channel ",i3,", station ",4a2)') lc,lcode(icode),
     .      ivc,(lstnna(i,istn),i=1,4)
          LIFINP(ivc,istn,ICODE) = LIN ! IF input channel
          FREQLO(ivc,ISTN,ICODE) = F
          ivix(ivc,istn,icode) = ivc
          losb(ivc,istn,icode) = ls
          cset(ivc,istn,icode) = cs
        else ! fill in per-channel with certain assumptions
          do i=1,nvcs(istn,icode)
            if (lsg.eq.lsubvc(i,istn,icode)) then ! match sub-group
              if (ivix(i,istn,icode).eq.0) then ! first time
                LIFINP(i,istn,ICODE) = LIN 
                FREQLO(i,ISTN,ICODE) = F
                ivix(i,istn,icode) = i
                call char2hol('U ',losb(i,istn,icode),1,2)
                cset(i,istn,icode) = '   '
              else ! had a previous LO already
                rbbc=abs(freqlo(i,istn,icode)-freqrf(i,istn,icode))
                kmk3 =ichcm_ch(lifinp(i,istn,icode),1,'1N').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'2N').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'3N').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'1A').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'2A').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'3A').eq.0
                kvlba=ichcm_ch(lifinp(i,istn,icode),1,'A').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'B').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'C').eq.0.or.
     .                ichcm_ch(lifinp(i,istn,icode),1,'D').eq.0
                if ((rbbc.gt.1000.0.and.kvlba).or.
     .              (rbbc.gt.500.0.and.kmk3)) then
                  LIFINP(i,istn,ICODE) = LIN 
                  FREQLO(i,ISTN,ICODE) = F
                endif
              endif ! previous LO/first time
            endif ! match sub-group
          enddo
        endif
      END IF  !LO entry
C
C
C     4. This is the name type entry section.
C        Index for icode has already been found above.
C
      IF (ITYPE.EQ.3) THEN  !name entry
C       Check the list of station names.
        ibad=0
        if (ns.gt.0) then ! station names on "F" line
          do is=1,ns ! for each station name found on the line
            i=1
            do while (i.le.nstatn.and..not.knaeq(lst(1,is),
     .               lstnna(1,i),4))
              i=i+1
            enddo
            if (i.gt.nstatn) then ! no match
              write(lu,9400) (lst(ii,is),ii=1,4)
9400          format('FRINP04 - Station ',a4,' not selected. ',
     .        'Frequency sequence for this station ignored.')
              ibad=ibad+1
            else
             istsav(is)=i ! save the station index 
             idum= ICHMV(LNAFRsub(1,i,ICODE),1,lsub,1,8)
            endif
          enddo
          nstsav=ns-ibad ! save the number of good stations
        else ! no stations listed, assume all
          nstsav=nstatn
          do i=1,nstatn
            istsav(i)=i ! save the station index 
          enddo
        endif
        idum= ICHMV(LNAFRQ(1,ICODE),1,LNA,1,8)
        LCODE(ICODE) = LC
      END IF  !name entry
C
      IERR = 0
      INUM = 0
C
      RETURN
      END
