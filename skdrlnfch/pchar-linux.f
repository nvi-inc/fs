      SUBROUTINE PCHAR(IAR,I,ICH)
      IMPLICIT NONE
      INTEGER*2 IAR(1)
      integer ich,i
C
C PCHAR: puts the character in the lower byte (DOS) of ICH into the
C        Ith position in array IAR
C 900807 MODIFIED WITH 'JCHAR' TO DOS BIT STORAGE (LOWER/UPPER) AS
C OPPOSED TO UNIX EQUIV. (UPPER/LOWER)
C storage: odd position on right bit, even position on left bit

! AEM 20050112 int->int*2,add 'very_temp'
      integer*2 iword,nword,very_temp

C ADDED 900625
! AEM 20041123 int->int*2, remove jishft
      integer*2 f2,foof

      DATA F2/Z'00FF'/, FOOF/Z'FF00'/
c
! AEM 20050112 replace ich
      very_temp = ich
      
      IWORD=IAR((I+1)/2)
c assumes ich placed in DOS upper (right) bit
      IF(MOD(I,2).EQ.1) THEN
! AEM 20041125 and -> iand
        IWORD=IAND(IWORD,FOOF)
        NWORD=IAND(very_temp,F2)
      ELSE
        IWORD=IAND(IWORD,F2)
! AEM 20041123 jishft->ishft
        NWORD=ishft(very_temp,8)
!
c original coding
C       IF(MOD(I,2).EQ.1) THEN
C         IWORD=IAND(IWORD,F2)
C         NWORD=ISHFT(ICH,8)
C       ELSE
C         IWORD=IAND(IWORD,FOOF)
C         NWORD=IAND(ICH,F2)
C
      ENDIF
! AEM 20041125 or->ior
      IAR((I+1)/2)=IOR(IWORD,NWORD)
C
! AEM 20050114 commenetd return
!      RETURN
      END
