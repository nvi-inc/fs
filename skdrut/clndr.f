C@CLNDR
C 980804 nrv Change check for IYEAR to use +1900 for years 50-99
C            and +2000 for years 0-49

      SUBROUTINE CLNDR ( IYEAR , MONTH , IDAY , IPMON , IPDAY ) 
C     Convert YMD to printable month, day-of-week TAC 760911 
C 
C-----CLNDR IS A CALENDAR CONVERSION PROGRAM WHICH CONVERTS YEAR- 
C     MONTH-DAY DATES INTO PRINTABLE MONTH AND DAY-OF-WEEK: 
C         IPMON = 'PRINTABLE' MONTH ( e.g. "JAN." ) 
C         IPDAY = 'PRINTABLE' DAY OF WEEK ( e.g. "MON." ) 
C              ( IPMON AND IPDAY BOTH IN <2A2>  OR <A2,A1> FORMATS) 
C 
C-----NOTE THAT IF MONTH = 0 ON ENTRY ( AND HENCE THE INPUT IS IN YEAR
C     AND DAY-OF-THE-YEAR FORMAT ), MONTH WILL BE CHANGED TO THE
C     CORRECT MONTH AND IDAY WILL BE CHANGED TO THE DAY-OF-THE-MONTH
C     PRIOR TO RETURN. IF THE IDAY IS 'INVALID' ( E.G.  33 DEC 1976 ),
C     IT WILL BE 'CORRECTED' ( E.G.  02 JAN 1977 ) PRIOR TO RETURN. 
C     YOU SHOULD THEREFORE BE VERY CAUTIOUS OF INSERTING INTEGERS 
C     (RATHER THAN VARIABLES) INTO YOUR CALL. 
C     E.G.      CALL CLNDR [ 1976 , 12 , 33 ... ]      MIGHT CAUSE
C                      DISASTROUS RESULTS ) !!!!!!!!!!!!!!!!!!! 
C 
C**************************************************************************** 
C********            ACHTUNG !!    WARNING !!    ATTENCIONE !!       ******** 
C********   REVISED 11 SEPT 76 BY TAC 'CUZ THE RETURNED DAY OF WEEK  ******** 
C********               FOR  IYEAR = 1977 WAS INCORRECT !            ******** 
C********                                                            ******** 
C**************************************************************************** 
C 
      implicit none ! added by NRV 930225
      integer iyear, month, iday
      integer*2 jpday(14),jpmon(24),ipmon(2),ipday(2)
      integer idayr,index,iday0
      CHARACTER*28 JPDAY_CHAR
      EQUIVALENCE (JPDAY,JPDAY_CHAR)
      CHARACTER*48 JPMON_CHAR
      EQUIVALENCE (JPMON,JPMON_CHAR)
C
      DATA JPDAY_CHAR /'SUMOTUWETHFRSAN.N.ESD.URI.T. '/
      DATA JPMON_CHAR /'JAFEMAAPMAJUJUAUSEOCNODEN.B.R.R.Y.N.L.G.P.T.V.C.
     .'/
C 
C-----IF IYEAR < 100 , ASSUME THAT 1900+IYEAR IS DESIRED: 
C*********** THIS FEATURE IS AN ADDITION AS OF 11 SEPT 76      TAC ******** 
C*NRV*If IYEAR is between 0 and 50, assume that 2000+IYEAR is desired.
      IF ( IYEAR .LE. 99 .and. IYEAR .GE. 50 ) IYEAR = IYEAR + 1900
      IF ( IYEAR .LE. 49 .and. IYEAR .GE. 0  ) IYEAR = IYEAR + 2000
C 
C-----WHICH FORMAT IS THE ENTRY IN? 
C     I.E. YEAR AND DAY-OF-YEAR OR YEAR-MONTH-DAY ? 
C 
      IDAYR = 0 
      IF ( MONTH ) 1 , 1 , 2
C 
C-----DAY-OF-YEAR FORMAT, SO DECODE THE MONTH AND CHANGE IDAY TO DAY- 
C     OF-THE-MONTH: 
C 
  1   IDAYR = IDAY
      CALL YMDAY ( IYEAR , IDAYR , MONTH , IDAY ) 
      GO TO 9 
C 
C-----ALREADY IN YEAR-MONTH-DAY FORMAT: 
C 
  2   IDAYR = IDAY + IDAY0 ( IYEAR , MONTH )
C 
C-----NOW FIGURE OUT THE DAY OF THE WEEK: 
C 
C************* THE FOLLOWING LINE WAS INCORRRECT & REVISED 11 SEPT 76 BY TAC
C 9   INDEX = MOD (IYEAR + IDAYR - ((IYEAR - 1)/ 4) + 4 , 7) + 1
C         NOTE                   ^ <----CHANGES-----> ^ 
  9   INDEX = MOD (IYEAR + IDAYR + ((IYEAR - 1)/ 4) + 5 , 7) + 1
      IPDAY (1) = JPDAY ( INDEX ) 
      IPDAY (2) = JPDAY ( INDEX +7 )
C 
C-----FILL IN THE MONTH AND RETURN: 
C 
      IPMON (1) = JPMON ( MONTH ) 
      IPMON (2) = JPMON ( MONTH + 12 )
      RETURN
      END

