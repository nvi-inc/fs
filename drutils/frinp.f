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
      integer ITRK(2,28),idum
C     integer*2 IP(14)
      integer*2 LNA(4)
      INTEGER J ! used for PCOUNT
      integer ivc,i,icode,istn,inum,ic,itype,ifc
      integer*2 lc,lsg,lm,lid,lin
      real*4 f1,f2,f,vb
      integer jchar,ichmv,igtfr,igtst ! functions
C
C  History
C     880310 NRV DE-COMPC'D
C     891116 NRV Cleaned up format, added fill-in of LBAND
C            nrv implicit none
C     930421 nrv Re-added: store track assignments
C
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
      ITYPE=0
      IF (JCHAR(IBUF,1).EQ.OCAPC) ITYPE=1 ! C
      IF (JCHAR(IBUF,1).EQ.OCAPL) ITYPE=2 ! L
      IF (JCHAR(IBUF,1).EQ.OCAPF) ITYPE=3 ! F
      IF (ITYPE.EQ.1) CALL UNPCO(IBUF(2),ILEN-1,IERR,
     .                LC,LSG,F1,F2,IVC,LM,VB,ITRK)
      IF (ITYPE.EQ.2) CALL UNPLO(IBUF(2),ILEN-1,IERR,
     .                LID,LC,LSG,IFC,LIN,F)
      IF (ITYPE.EQ.3) THEN
        J = 5
        CALL UNPFR(IBUF(2),ILEN-1,IERR,LNA,LC,NULL,NULL,NULL,
     .             NULL,NULL,NULL,NULL,NULL,J)
      END IF
C
C 1.5 If there are errors, handle them first.
C
      IF  (IERR.NE.0) THEN
        IERR = -(IERR+100)
        write(lu,9201) ierr,(ibuf(i),i=2,ilen/2)
9201    format('FRINP01 - Error in field ',I3,' of:'/40a2)
        RETURN
      END IF 
C
      IF  (IGTFR(LC,ICODE).EQ.0) THEN !"a new code"
        NCODES = NCODES + 1
        IF  (NCODES.GT.MAX_FRQ) THEN !"too many codes"
          IERR = MAX_FRQ
          ncodes=ncodes-1
          write(lu,9202) ierr
9202      format('FRINP02 - Too many frequency codes.  Max is ',I3,
     .    ' codes.')
          RETURN
        END IF  !"too many codes"
        ICODE = NCODES
      END IF  !"a new code"
C
C     2. Now decide what to do with this information.
C     First, handle code type entries.
C
      IF  (ITYPE.EQ.1) THEN  !"code entry"
        nvcs(icode)=nvcs(icode)+1
        invcx(nvcs(icode),icode)=ivc
        LSUBVC(IVC,ICODE) = LSG
        FREQRF(IVC,ICODE) = F1
        LCODE(ICODE) = LC
        LMODE(ICODE) = LM
        VCBAND(ICODE) = VB
        DO  I=1,28
          IF (ITRK(1,I).NE.-99) then
            CALL SBIT(LTRAKS(1,I,ICODE),ITRK(1,I),1)
            itras(1,i,ivc,icode) = itrk(1,i)
          endif
          IF (ITRK(2,I).NE.-99) then
            CALL SBIT(LTRAKS(1,I,ICODE),ITRK(2,I),1)
            itras(2,i,ivc,icode) = itrk(2,i)
          endif
        END DO  !
      END IF  !"code entry"
C
C
C     3. Next, LO type entries.
C
      IF  (ITYPE.EQ.2) THEN  !"LO entry"
        IF  (IGTST(LID,ISTN).EQ.0) THEN  !error
          write(lu,'("FRINP03 - Station ",a2," not selected.",
     .    " LO entry ignored.")') lid
          IERR = MAX_STN
          RETURN
        END IF  !error
C
        LSGINP(IFC,ICODE) = LSG
        LCODE(ICODE) = LC
        idum= ICHMV(LSGINP(IFC,ICODE),2,LIN,1,1)
        FREQLO(IFC,ISTN,ICODE) = F
C
C     NOTE: we make no use of the patching information at this time.
C       DO  I = 1,14
C         IF (IP(I).GT.0) CALL SBIT(LPATCH(IFC,ISTN,ICODE),I,1)
C       END DO
C
      END IF  !"LO entry"
C
C
C     4. This is the name type entry section.
C
      IF  (ITYPE.EQ.3) THEN  !"name entry"
        IF  (IGTFR(LC,IC).NE.0) THEN !duplicate
          write(lu,9400) lc
9400      format('FRINP04 - Duplicate frequency code ',A2,
     .    '.  Previous one ignored.')
          do i=1,2
            nfreq(i,icode)=0
          enddo
          nvcs(icode)=0
        endif !duplicate
        idum= ICHMV(LNAFRQ(1,ICODE),1,LNA,1,8)
        LCODE(ICODE) = LC
      END IF  !"name entry"
C
      IERR = 0
      INUM = 0
C
      RETURN
      END
