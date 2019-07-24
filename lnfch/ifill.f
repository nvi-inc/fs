        SUBROUTINE IFILL(IOUT,IC,NC,JC)
        IMPLICIT NONE
        INTEGER IOUT(1),IC,NC,JC
C
C IFILL: fill array IOUT with from character IC through IC+NC-1 inclusive
C        with the character in th lower byte of JC
C
C Input:
C       IOUT: hollerith array to be filled
C       IC:   first character in IOUT to fill
C       NC:   number of characters in IOUT to fill
C       JC:   lower byte contains fill character
C
C Output:
C        IOUT: characters IC...IC+NC-1 filled with lower byte of JC
C              NC .eq. 0 then no-op
C
C Warning:
C         Negative and zero values of IC are not support
C         NCHAR must be non-negative
C         IC+NCHAR.LE.32767
C
      INTEGER I,IEND
C
      IF(IC.LE.0.OR.NC.LT.0) THEN
	  WRITE(6,*) ' IFILL: Illegal arguments',IC,NC
        STOP
      ENDIF
C
      IF(NC.EQ.0) RETURN
C
      IEND=32767-NC+1
C
      IF(IC.GT.IEND) THEN
	  WRITE(6,*) ' IFILL: Illegal combination',IC,NC
        STOP
      ENDIF
C
      DO I=0,NC-1
        CALL PCHAR(IOUT,IC+I,JC)
      ENDDO
C
      RETURN
      END
