      INTEGER FUNCTION iscn_ch(LINPUT,IFC,ILC,CCH)
      IMPLICIT NONE
      INTEGER LINPUT(1),IFC,ILC
      CHARACTER*(*) CCH
C
C iscn_ch: scan for character string
C
C Input:
C       LINPUT: Hollerith array to scan in
C       IFC:    character in LINPUT at which to start scan
C       ILC:    character in LINPUT at which to stop scan
C       CCH:    contains character string to scan for
C
C Output:
C       iscn_ch: zero if CCH was not found in LINPUT
C              nonzero, the index at which the character was found
C              IFC <= iscn_ch <= ILC in this case
C              if IFC > ILC then no-op
C
C Warning:
C       Negative and zero values of IFC or ICL are not supported
C
      INTEGER I,j
      character ch
C
      IF(ILC.LE.0.OR.IFC.LE.0) THEN
        WRITE(6,*) ' ISCN_CH: Illegal arguments',IFC,ILC
        STOP
      ENDIF
C
      DO I=IFC,ILC-len(cch)+1
        call hol2char(LINPUT,i,i,ch) 
        IF(CCH(1:1).EQ.ch) THEN
           do j=2,len(cch)
              call hol2char(linput,i+j-1,i+j-1,ch)
              if(cch(j:j).ne.ch) goto 100
           enddo
           iscn_ch=I
           RETURN
        ENDIF
 100    continue
      ENDDO
C
      iscn_ch=0
C
      RETURN
      END
