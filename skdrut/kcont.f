      LOGICAL FUNCTION KCONT(MJD,UT,DUR,ISOR,IST,Cwrap,ierr)
C
C     This checks that an observation is continuous, i.e. that it
C     doesn't end on a different part of the cable from which it began.
C     KCONT is returned TRUE if the observation is continuous.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  Passed
      integer mjd             !MJD
      real*8  ut              !UT
      real*4 dur              !duration (seconds)
      integer isor           !source number
      integer ist            !station
      character*(*)  cwrap   !wrap
      integer*2 lcabl
! returns 
      integer ierr           !-1= goes below lower wrap at end.
                              !+1= goes above upper wrap at end. 
! Functions
      real*4 azwrap     


C  LOCAL:
      LOGICAL KUP                       !indicates if source is up at a station. 
      real*4 az1,el1,ha1,dec1,x1,y1     !holds resuts from cvpos for starting
      real*4 az2,el2,ha2,dec2,x2,y2     !Results from cvpos for ending
      real*4 delaz,az2c
    
C
C  COMMON:
      include '../skdrincl/statn.ftni'
C
C   PROGRAMMER: MAH  811125
C    MODIFICATIONS:
C    DATE   WHO    CHANGES
C    830524 WEH    ADD DEC TO CVPOS CALLS
C    880315 NRV    DE-COMPD'C
C    930225 nrv implicit none
C 001226 nrv Changed  comment on definition of DUR: it is the
C            duration not the stop time of the observation.
! 2005Mar14 JMGipson.  Changed comparison of 'HC' to 'C '
! 2008Jun20 JMG. Changed order of arguments
! 2014Apr08 JMG. Removed changing cablewrap. 
! 2014Apr23 JMG. Modified to use get_azwrap to compute azimuth of first position.
!                Changed lcblwrp to ASCII cwrap


!
C     First work out the source position at UT and the position at UT+DUR.
C     Find delta-az
C     Check that AZ1+delAZ is on the same cable wrap
C     Return KCONT = FALSE if the observation is not continuous
C     If you don't have an AZ-EL antenna return immediately with KCONT=TRUE
C
C
      kcont=.TRUE.
      ierr=0
      IF (IAXIS(IST).EQ.3.or.iaxis(ist).eq.7.or.iaxis(ist).eq.6) then
        CALL CVPOS(ISOR,IST,MJD,UT,    AZ1,EL1,HA1,DEC1,X1,Y1,X1,Y1,KUP)
        CALL CVPOS(ISOR,IST,MJD,UT+DUR,AZ2,EL2,HA2,DEC2,X2,Y2,X2,Y2,KUP)  
C
        DELAZ = AZ2-AZ1
        IF (DELAZ.GT.PI) then
          DELAZ = -(TWOPI-DELAZ)
        else IF (DELAZ.LT.-PI) then
          DELAZ = TWOPI+DELAZ
        endif 
!        write(*,'(a,1x, 2f8.2)') cstnna(ist), az1*rad2deg, az2*rad2deg

        Az1=azwrap(az1,cwrap,stnlim(1,1,ist))

C
        AZ2C = AZ1+DELAZ     
C  Check whether we cross into ambiguous section during observation
        IF (AZ2C.LE.STNLIM(2,1,IST).AND.AZ2C.GE.STNLIM(1,1,IST)+TWOPI
     >    .AND.(cwrap .eq. " " .or. cwrap .eq. "-")) THEN  !set end of observation cable wrap
!          IF (DELAZ.GT.0.) call char2hol('C ',LCABL,1,2)
!          IF (DELAZ.LT.0.) call char2hol('W ',LCABL,1,2)
        ENDIF
        IF (AZ2C.LT.STNLIM(1,1,IST)) then
           kcont = .FALSE.
           ierr=-1
        else if (AZ2C.GT.STNLIM(2,1,IST)) then
           kcont = .FALSE.
           ierr=1        
        endif 
 
       if(.false.) then     
!      if(ierr .ne. 0) then 
        write(*,*) "ist ", cstnna(ist), iaxis(ist) 
        write(*,*) ierr
        write(*,*) "min: ",rad2deg*stnlim(1,1,ist)
        write(*,*) "max: ", rad2deg*stnlim(2,1,ist)
        write(*,*) "az1: ",az1*rad2deg
        write(*,*) "az2: ",az2*rad2deg
        write(*,*) "delaz: ", delaz*rad2deg
        write(*,*) "az2c:  ",az2c*rad2deg
      endif
      endif
C
      RETURN
      END
