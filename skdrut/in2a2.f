C@IN2A2

      INTEGER*2 FUNCTION IN2A2 ( INP )

      implicit none
C     2-digit integer-to-ASCII with leading zeroes  TAC 760102 
C     THIS FUNCTION CONVERTS AN INPUT NUMBER IN I2 FORMAT INTO A
C     PRINTABLE NUMBER IN A2 FORMAT, WITH LEADING ZEROES FILLED IN. 
C     IN CASE THE NUMBER IS NEGATIVE, THE RETURNED VALUE = "--" 
C     IN CASE THE NUMBER EXCEEDS 99 , THE RETURNED VALUE = "++" 
C 
C     T.A.CLARK                                   02 JAN '76
C 
      integer inp,in10,in1
      IF ( INP .GT. 99 ) GO TO 99 
      IF ( INP .LT. 00 ) GO TO 100
C     MASK IFF THE DIGITS:
      IN10 = INP / 10 
      IN1  = INP - 10*IN10
C     CONVERT INTO ASCII
      IN2A2 = o'400' * ( IN10 + o'60' ) + ( IN1 + o'60' ) 
      RETURN
99    call char2hol('++',IN2A2,1,2)
C99    IN2A2 = 2H++
      RETURN
100   call char2hol('--',IN2A2,1,2)
C100   IN2A2 = 2H--
      RETURN
      END 

