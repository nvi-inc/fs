      SUBROUTINE gnpas
C
C     GNPAS derives the number of passes allowed for each frequency code
C
       INCLUDE 'skparm.ftni'
       INCLUDE 'freqs.ftni'
C
C  LOCAL VARIABLES:
      LOGICAL KBIT
C     IT - number of tracks found in a code
C     NP - number of passes found in a code
      integer*2 LT(2),lt1,lt2
      integer it,np,j,k,i
      integer jchar ! function
      EQUIVALENCE (LT1,LT(1)),(LT2,LT(2))
C
C     880310 NRV DE-COMPC'D
C     930225 nrv implicit none
C
C
C     1. For each code, go through all possible passes and add
C     up the total number of tracks used.  If all 28 are used,
C     then this is a "complete" code.
C     If less than 28 are used, this is an "incomplete" code, and
C     the number of passes is ASSUMED to be the number required to
C     fill all tracks using similar codes.
C
      IF (NCODES.LE.0) RETURN
C
      DO  I=1,NCODES !     "loop on codes"
        IT = 0
        NP = 0
        DO  J=1,28 !     "all possible passes"
          LT1 = LTRAKS(1,J,I)
          LT2 = LTRAKS(2,J,I)
          IF  (LT1.NE.0.OR.LT2.NE.0) THEN  !"some tracks this pass"
            NP=NP+1
            DO  K=1,28
              IF (KBIT(LT1,K)) IT=IT+1
            END DO  !
          END IF  !"some tracks this pass"
C
        END DO  !"all possible passes"
C
        NPASSF(I) = 0
        IF (IT.EQ.28) NPASSF(I) = NP
        IF (IT.EQ.14) NPASSF(I) = -2*NP
        IF (IT.EQ. 7) NPASSF(I) = -4*NP
        IF (IT.EQ. 1) NPASSF(I) = -28*NP
        IF  (IT.EQ. 0.OR.NPASSF(I).EQ.0) THEN  !"use defaults"
          IF (JCHAR(LMODE(I),1).EQ.OCAPA) NPASSF(I) = 1
          IF (JCHAR(LMODE(I),1).EQ.OCAPB) NPASSF(I) = 2
          IF (JCHAR(LMODE(I),1).EQ.OCAPC) NPASSF(I) = 2
          IF (JCHAR(LMODE(I),1).EQ.OCAPD) NPASSF(I) = 28
          IF (JCHAR(LMODE(I),1).EQ.OCAPE) NPASSF(I) = 4
          IF (JCHAR(LMODE(I),1).EQ.OCAPP) NPASSF(I) = 4
        END IF  !"use defaults"
C
      END DO  !"loop on codes"
C
      RETURN
      END
