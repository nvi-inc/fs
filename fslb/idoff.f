      subroutine idoff(idadd,iopt)
  
C  THIS ROUTINE OF,8 THE PROGRAM WHOSE IDSEG ADDRESS IS
C  GIVEN IN IDADD
C 
C  INPUT VARIABLES:
C 
C  IDADD   - THE ADDRESS OF THE IDSEG OF THE PROGRAM TO BE REMOVED 
C 
C  OUTPUT VARIABLES: 
C 
C  COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C  DATA BASE ACCESSES 
C 
C  EXTERNAL INPUT/OUTPUT
C 
C  SUBROUTINE INTERFACE:
C 
C  CALLING SUBROUTINES: SUB1, SUB2, ... (not required for utilities) 
C  CALLED SUBROUTINES: SUB1, SUB2, ... (includes segments scheduled) 
C 
C  LOCAL VARIABLES 
C 
        integer*2 ibuff(36)
C 
C 
C  CONSTANTS USED
C 
        data ibuff/2hof,2h, ,34*'  '/
C 
C  INITIALIZED VARIABLES 
C
C  PROGRAMMER: LEE N. FOSTER
C     LAST MODIFIED:
C# LAST COMPC'ED  870407:12:48urrent date) #
C
C  GET # OF PARMS
C
C       NP=IGNPS(NP)
c      np=pcount()
C
C  SET UP INTERNAL OPTION
C
      nopt=8
C
C  USE EXTERNAL IF PRESENT
C
C -ORO- np not set by code above: is following important? how to decide np?
      nopt=iopt
      if (nopt.le.0) return
C
C  RESET IBUFF
C
      idummy = ichmv(ibuff,1,3hof,,1,3)
C
C  IF IDADD LE o'40000' TREAT AS IDSEG ADDRESS ELSE ASCII NAME
C
      if (idadd.le.o'40000') goto 20000
C
C  TREAT  AS ASCII CHARACTERS
C 
      iloc=ichmv(ibuff,4,idadd,1,5) 
C 
C  GO TO BLANK TEST
C 
      goto 50000 
C 
20000 continue
C 
C  MOVE PROGRAM NAME TO BUFFER 
C 
      iloc=ichmv(ibuff,4,iget(idadd+12),1,2)
C 
      iloc=ichmv(ibuff,iloc,iget(idadd+13),1,2) 
C 
      iloc=ichmv(ibuff,iloc,iget(idadd+14),1,1) 
C 
50000 continue
C 
C  CHECK FOR A BLANK IN THE NAME 
C 
      iblnk=iscn_ch(ibuff,4,iloc,' ') 
C 
C  IF TRAILING BLANKS SHORTEN NAME 
C 
      if (iblnk.ne.0) iloc=iabs(iblnk)
C 
C  CHECK FOR MORE PARAMETERS 
C 
      if (nopt.ne.8) goto 70000
C 
C  MOVE IN COMMA 
C 
C  The following line was changed to be compatible with CI.
      iloc=ichmv(ibuff,iloc,4h,id ,1,3)
C 
C  MOVE IN OPTION
C 
c       ILOC=ICHMV(IBUFF,ILOC,NOPT+o'60',2,1)
C 
70000 continue
C 
C  SHORTEN TO MESSAGE LENGTH 
C 
      iloc=iloc-1 
C 
C  SEND TO SYSTEM FOR PURGING
C 
      ic = messs(ibuff,iloc)
C
C  RITE RESPONSE TO SCREEN
C
      call put_cons(ibuff,ic)
C 
      return
      end 
