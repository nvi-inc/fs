        subroutine ifill_ch(iout,ic,nc,ch)
        implicit none
        integer iout(1),ic,nc
        character ch
C
C IFILL: fill array IOUT with from character IC through IC+NC-1 inclusive
C        with the character in ch.
C
C Input:
C       IOUT: hollerith array to be filled
C       IC:   first character in IOUT to fill
C       NC:   number of characters in IOUT to fill
C       CH:   lower byte contains fill character
C
C Output:
C        IOUT: characters IC...IC+NC-1 filled with CH 
C              NC .eq. 0 then no-op
C
C Warning:
C         Negative and zero values of IC are not support
C         NCHAR must be non-negative
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
      do i=0,nc-1
        call char2hol(ch,iout,ic+i,ic+i)
      enddo
C
      return
      end
