*
* Copyright (c) 2020-2021 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE SLEWo(NSNOW,MJD,UT,NSNEW,ISTN,cwrap_cur,cwrap_new,
     >  TSLEW,lookah,trise)
      implicit none
C
C   SLEWT calculates the slew time and the cable wrap
C   ***NOTE*** This is the version as of 10/93 before the pre-calculated
C              rise/set times were available. Use this version with
C              drudg. Use the new version with sked.
C
C 040623  ZMM  removed trailing RETURN

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C     INPUT VARIABLES:
         integer nsnow,mjd,nsnew,istn,lookah
         character*2 cwrap_cur
        
         real*8 ut
C        NSNOW  - current source index into DB arrays
C        NSNEW  - new source index, i.e. the one to slew to
C        MJD    - date of observation
C               - UT of observation
C        ISTN   - station index
C        cwrap_cur - current wrap of telescope
C        cwrap_new - The wrap requested by the user for the new observation.
C                 " "=fastest, "W"=clockwise part of overlap, "C"=counter
C                 clockwise part of overlap.  Modified as necessary by
C                 this program.
C        lookah - number of seconds of lookahead time for checking rising
C
C     OUTPUT VARIABLES:
         real*4 tslew
         character*2 cwrap_new      
C        TSLEW  - time for ISTN to slew from NSNOW to NSNEW, seconds
C                 -1 = not up
C                 -2 = slew does not converge
C    DISABLED:    -3 = not up now, rising within an hour
C                 -nnn = time until rise
C        trise  =  time until the source rises, seconds
C          (it this is > 0 then TSLEW includes this time)
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
C
C     CALLING SUBROUTINES: OBSCM,CHCMD, and others
C     CALLED SUBROUTINES: CVPOS,CABLW
C
! function
      LOGICAL kcont
      real slew_time
! Local variables       
      REAL tslewp,tslewc
      real delaz,delel
      real aznow,aznew,elnow,elnew
      real hanow,hanew,decnow,decnew,x30now,x30new,y30now,y30new
      real x85now,x85new,y85now,y85new
      real x1,x2,y1,y2
      real tslew1,tslew2   
      integer itemp    
  
      real*4 az1,az2,trise
      integer nloops,il
      character*2 cwrap1,cwarp2,cwarp2p
      LOGICAL KUP ! Returned from CVPOS, TRUE if source within limits
      integer ierr 
C        TSLEWP,TSLEWC - previous, current slew times.  For iterating.
C        DELAZ,DELEL,DELDC,DELHA,DELX30,DELY30,DELX85,DELY85
C        AZNOW,AZNEW,ELNOW,ELNEW,HANOW,HANEW,DECNOW,DECNEW
C        X30NOW,X30NEW,Y30NOW,Y30NEW,X85NOW,X85NEW,Y85NOW,Y85NEW
C               - Increments, current, next values of az,el,ha,x,y
C        CABLW  - Function to compute required az move.
C        NLOOPS - Number of iterations on slewing time
C        AZ1,AZ2,cwrap1,cwarp2
C               - current,new values of az,wrap
      real*4 cablw ! function
      
C
C  History
C      DATE   WHO    CHANGES
! 2021-12-03  JMG. Changed case statement to else if for f77. Uggh. got rid of unused variables.
! 2021-11-10  JMG. Substantial change in the logic to make simpler and use new slew model. 
! 2021-04-02  JMG Renamed STNRAT-->slew_rate, istcon-->slew_off.  Made slew_off real
C
C     811125  MAH    CHECK THAT SLEWING DOES CONVERGE FOR AZ-EL ANTENNAS
C     830423  NRV    ADD X,Y CALCULATIONS
C     830523  WEH    SATELLITES ADDED, DEC ADDED TO CVPOS CALL, SLEWING
C                    NOW USES RETURNED DECs NOT VALUES FROM COMMOM
C     880315  NRV    DE-COMPC'D
C     900425  NRV    Added check for axis type 6 (SEST)
C     900511  NRV         "       "      "     7 (ALGO)
C     930308  nrv    implicit none
C     931012  nrv    Add in the constants when calculating slew times for
C                    type 7 (ALGO)
!   2008Jun20 JMG. Changed arg list for kcont
!   2020Oct28 JMg. Changed to using kcont (with character arguments) 

C
C     1. First we find the position of the telescope at the end of
C        the current observation and the position of the new source
C        at that time also. Then we go into
C        a loop which calculates the required telescope move, the
C        time to get there, and the source position at the end of
C        the move.  The loop is terminated when the slewing time
C        does not change by more than 30sec, or when 5 tries have
C        been made.
C
      CALL CVPOS(NSNOW,ISTN,MJD,UT,AZNOW,ELNOW,HANOW,DECNOW,
     .X30NOW,Y30NOW,X85NOW,Y85NOW,KUP)
C                    this calculates the current telescope position
      trise=-1.0
      TSLEWC = 0.0
      NLOOPS = 0
100   NLOOPS = NLOOPS + 1
      TSLEWP = TSLEWC
      cwarp2P = cwarp2
C     This calculates the new source location:
      CALL CVPOS(NSNEW,ISTN,MJD,UT+TSLEWC,
     .AZNEW,ELNEW,HANEW,DECNEW,X30NEW,Y30NEW,X85NEW,Y85NEW,KUP)
      if (aznew.gt.100.or.aznew.lt.-100.d0) then
        write(7,*) 'SLEWT: bad aznew ',aznew
        stop
      endif
C
      if (.not.kup) then !Check for source being up within lookahead
        CALL CVPOS(NSNEW,ISTN,MJD,UT+lookah,
     .  AZNEW,ELNEW,HANEW,DECNEW,X30NEW,Y30NEW,X85NEW,Y85NEW,KUP)
C       Check for the minute it rises
        if (kup) then !rising within lookahead
          kup=.false.
          il=0

C 040623  ZMM  changed, was
C         do while ( kup.eq..false. .and. il.le.lookah/60 )

          do while ( .not.kup .and. il.le.lookah/60 )
            il=il+1
            CALL CVPOS(NSNEW,ISTN,MJD,UT+il*60.,
     .      AZNEW,ELNEW,HANEW,DECNEW,X30NEW,Y30NEW,X85NEW,Y85NEW,KUP)
          enddo
        trise = il*60.0
C       Now we have the time to rising and position at rise.
C       Compute slewing time to this position.
        endif !rising within lookahead
      endif !check within an hour
      IF (.NOT.KUP) GOTO 980
C
      AZ1=AZNOW
      cwrap1=cwrap_cur
      AZ2=AZNEW
      cwarp2=cwrap_new
      DELAZ = CABLW(ISTN,AZ1,cwrap1,AZ2,cwarp2)
C                   Function to compute az move including cable wrap
       itemp=iaxis(istn)
!       select case (iaxis(istn))
!        case(1,5)     
       if(itemp .eq. 1 .or. itemp .eq. 5) then 
          x1=HaNew
          X2=HaNow
          Y1=DecNew
          Y2=DecNow
       else if(itemp .eq. 2) then 
!        case(2)     
          X1=X30new
          X2=X30Now
          Y1=DecNew
          Y2=Decnow
      else if(itemp .eq. 3 .or. itemp .eq. 6) then
!        case(3,6)
          X1=Az1
          X2=Az2
          Y1=ElNew
          Y2=ElNow
!        case(4)
      else if(itemp .eq. 4) then 
          X1=x85New
          X2=X85Now
          Y1=Y85New
          Y2=Y85Now
!        case default  
      else 
! This is algonquin.  Should never hit
          write(*,*) "Slewt:  unknown axis offset ", iaxis(istn)
          stop
!       end select
      endif 
      tslew1=slew_time(x1,X2,
     &             slew_off(1,istn),slew_vel(1,istn),slew_acc(1,istn))
      tslew2=slew_time(Y1,y2,
     &             slew_off(2,istn),slew_vel(2,istn),slew_acc(2,istn))
    
      tslewc=max(tslew1,tslew2) 
  
C
      IF ((ABS(TSLEWC-TSLEWP).LT.10).OR.(NLOOPS.GE.5)) GOTO 110
      
      
      GOTO 100
C     We get here if the slew has converged OR we iterated 5 times.
110   IF  (kcont(mjd,UT+TSLEWC,TSLEWP-TSLEWC,NSNEW,ISTN,cwrap_cur,ierr))
     .  THEN  !continuity OK
        TSLEW = TSLEWC    
        IF(TSLEW.LE.(AMAX1(slew_off(1,istn),slew_off(2,istn)))) tslew=0.
        cwrap_new = cwarp2
C       Final slewing time is the larger of
C       "time to rise" (trise) and "slew to risen position" (tslew
C       calculated using az,el at UT+trise).
        if (trise.gt.0..and.tslew.gt.0.) tslew = amax1(tslew,trise)
        RETURN
      ELSE  !
        TSLEW = -2.0
        trise=-1.0
        RETURN
      END IF  !
980   TSLEW = -1.0
      trise=-1.0

      END
