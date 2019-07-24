      subroutine fdfld(ias,ic1,ic2,ifc,iec) 

C     SCAN A STRING FOR A SERIES OF CHARACTERS SEPARATED BY COMMAS
C 
C     INPUT VARIABLES:
C 
      dimension ias(1)
C                   INPUT STRING WITH CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS 
C     NCH - NUMBER OF CHARACTERS IN IAS FOLLOWING IC1 
C 
C     OUTPUT VARIABLES: 
C 
C     IFC - FIRST NON-BLANK CHARACTER IN IAS
C     IEC - LAST NON-BLANK CHARACTER IN IAS 
C 
C     LOCAL VARIABLES:
      character cjchar
C 
C     IC1 - LAST CHARACTER IN IAS TO USE
C 
C 
C     FIRST INITIALIZE
C 
      ifc = 0 
      iec = 0 
      if (ic1.gt.ic2) return
C 
C     SCAN FOR THE FIRST NON-COMMA
C 
      do 100 i=ic1,ic2
        if (cjchar(ias,i).ne.',') goto 101 
100     continue
      return
C                   THERE ARE ONLY BLANKS 
101   ifc = i 
      iec = i 
      if (iec.lt.ic2) goto 190
      ic1 = ic2 + 1 
      return
C 
C     NOW SCAN FOR A COMMA
C 
190   do 200 i=ifc+1,ic2
        if (cjchar(ias,i).eq.',') goto 201 
200   continue
      iec = ic2 
C                   STRING ENDS WITH A COMMA
      ic1 = ic2 + 1 
      return
201   iec = i-1 
      ic1 = i 
C                   UPDATE FIRST CHARACTER NUMBER IN STRING 
      return
      end 
