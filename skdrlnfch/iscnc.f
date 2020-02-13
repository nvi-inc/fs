      INTEGER FUNCTION ISCNC (LINPUT,IFC,ILC,LCH)
      IMPLICIT NONE
      INTEGER*2 LINPUT(*)
      integer IFC,ILC,LCH
C
C ISCNC: scan for character
C
C Input:
C       LINPUT: Hollerith array to scan in
C       IFC:    character in LINPUT at which to start scan
C       ILC:    character in LINPUT at which to stop scan
C       LCH:    second byte contains character to scan for
C
C Output:
C       ISCNC: zero if LCH was not found in LINPUT
C              nonzero, the index at which the character was found
C              IFC <= ISCNC <= ILC in this case
C              if IFC > ILC then no-op
C
C Warning:
C       Negative and zero values of IFC or ICL are not supported
C
      INTEGER I
! AEM 20050111 char->char*1
      character*1 clch,cret,cjchar
C
      IF(ILC.LE.0.OR.IFC.LE.0) THEN
	  WRITE(6,*) ' ISCNC: Illegal arguments',IFC,ILC
        STOP
      ENDIF
C
      clch = char(LCH)
      DO I=IFC,ILC
        cret = cjchar(linput,i)
        if ( clch .eq. cret) then
          ISCNC=I
	  RETURN
	ENDIF
      ENDDO
C
      ISCNC=0
C
! AEM 20050111 cimmented return
!      RETURN
      END
