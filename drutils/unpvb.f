      SUBROUTINE unpvb(IBUF,ILEN,IERR,iv,ib,cs,sy,is,ls,li)
C
C     UNPVB unpacks the B lines of the $VLBA section of a schedule
C     file. 
C
      include 'skparm.ftni'

C  History:
C  WHEN    WHO  WHAT
C  900716  GAG  Created, copied from unplo
C  930225  nrv  implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer iv,ib ,ierr
      character*3 cs
      real*4 sy
      integer is
      integer*2 li,ls 

C     IERR - error, 0=OK, -100-n=error reading nth field in the record
C     iv - VC numbers
C     ib - BBC numbers
C     cs - switch set
C     sy - total LO synthesizer value
C     is - number assigned to synthesizer frequency
C     ls - hollerith SB
C     li - hollerith IF channel
C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C
C  LOCAL:
      real*4 ras2b
      integer ich,nch,ic1,ic2,idumy
      integer*2 l
      integer ichmv,jchar,iscnc,ias2b
C
C
C
C     1. Start decoding this record with the first character.
C
      IERR = 0
      ICH = 1
C
C
C     VC#, 1 or 2  characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      iv = ias2b(ibuf,ic1,nch)
      IF  ((iv.lt.1.or.iv.gt.14)) THEN  !
        IERR = -101
        RETURN
      END IF  !
C
C     BBC#, 1 or 2 characters
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      ib = ias2b(ibuf,ic1,nch)
      IF  ((ib.lt.1.or.ib.gt.14)) THEN  !
        IERR = -102
        RETURN
      END IF  !
C
C     Set number - 0 1 2 or 1,2
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      cs = '   '
      call hol2char(ibuf,ic1,ic2,cs)
      IF ((cs(1:1).ne.'1').and.(cs(1:1).ne.'2').and.
     .    (cs(1:1).ne.'0').and.(cs.ne.'1,2')) then
        IERR = -103
        RETURN
      END IF  !
C
C     synth - total LO synthesizer value
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      sy = RAS2B(ibuf,ic1,nch,ierr)
      IF  (ierr.lt.0) THEN  !
        IERR = -104
        RETURN
      END IF  !
C
C     Syn# - number assigned to synthesizer frequency
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      is = ias2b(ibuf,ic1,nch)
      IF  ((is.lt.1.or.is.gt.4)) THEN  !
        IERR = -105
        RETURN
      END IF  !
C
C     SB - Side Band for this BBC, either U or L
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = ic2-ic1+1
C     L = jchar(ibuf,ic1)
      idumy= ichmv(l,1,ibuf,ic1,1)
C     IF  ((nch.gt.1).OR.(L.NE.85.AND.L.NE.76)) THEN
      IF  ((nch.gt.1).OR.(
     .jchar(l,1).ne.85.and.jchar(l,1).ne.76)) then
C                   U                     L
        IERR = -106
        RETURN
        END IF  !
      call char2hol ('  ',LS,1,2)
      IDUMY = ICHMV(LS,1,L,1,1)
C
C     IFchan - IF channel designator
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      nch = ic2-ic1+1
C     L = jchar(ibuf,ic1)
      idumy= ichmv(l,1,ibuf,ic1,1)
C     IF  ((nch.gt.1).OR.(L.NE.65.AND.L.NE.66.and.l.ne.67.and.L.ne.68))
      IF  ((nch.gt.1).OR.(
     .jchar(l,1).ne.65.and.jchar(l,1).ne.66.and.jchar(l,1).ne.67
     ..and.jchar(l,1).ne.68.and.jchar(l,1).ne.69)) 
     .  then !                 (A through E) 
        IERR = -107
        RETURN
      END IF  !
      call char2hol ('  ',LI,1,2)
      IDUMY = ICHMV(LI,1,L,1,1)
C
      RETURN
      END
