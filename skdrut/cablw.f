      real*4 FUNCTION CABLW(ISTN,AZNOW,LWRCUR,AZNEW,LWRNEW)
C
C  CABLW returns the azimuth difference between the NOW and the
C              NEW source positions, taking into account cable wraps.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  INPUT VARIABLES:
      integer istn
      integer*2 lwrnew,lwrcur
      real*4 aznow,aznew
C        ISTN   - Index for stations in DB arrays
C        LWRNEW - User's specification for cable wrap.  <blank>=fastest,
C                 "C"=inner double-valued, "W"=outer double-valued.
C                 This is changed if necessary by this routine.
C        LWRCUR - current wrap indicator
C        AZNOW,AZNEW
C               - current, next az values, modified by cable wrap
C                 considerations if necessary
C
C  OUTPUT VARIABLES:
C        LWRNEW - new cable wrap indicator
C        CABLW - delta-azimuth required to be moved.
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
C
C     CALLING SUBROUTINES: SLEWT
C
C  LOCAL VARIABLES
      real daz1,daz2 ! DAZ1,DAZ2  - two choices of az moving
      real aznew1,aznew2 ! trial values for VLBA and Noto algorithms
      integer ichcm_ch
      real aznow_orig,aznew_orig ! non-wrapped values
      logical kq31,kq24 ! for Noto logic
C
C HISTORY
C    LAST MODIFIED: created 780424
C    880315 NRV DE-COMPC'D
C    930225 nrv implicit none
C    930702 nrv Put back in check for pseudo-azel axis types
C    940513 nrv Special section added for VLBA slewing algorithm
C               which says: don't go through south unless necessary.
C               Invoke this algorithm with a "V" in the cable wrap
C               variable LWRNEW.
C 961016 nrv Add special section for Noto slewing algorithm. 1) If
C            going from one quadrant to the opposite one, must go
C            through south. 2) If going to az=270 to 290, antenna
C            thinks it can get there in CCW, but this range is
C            "prohibited" and operator must catch it and send it the
C            right way. So allow extra time for antenna to slew to
C            the wrong limit and then go around 360 degrees to the
C            other wrap.
C 970114 nrv Change amin0,amax0 to amin1,amax1 (found by Simone Magri, ATNF)
C 970506 nrv Add special section for Matera slewing algorithm.
C            Stay on the same wrap if possible. UNDER CONSTRUCTION.
C
C
C     1. We skip out of this routine if the axis type is not az-el.
C        The first thing is to adjust the azimuths to put them into the
C        range as found in the data base.  Then if we are currently on
C        the outer overlapped portion, add another 2pi.
C
      IF (IAXIS(ISTN).EQ.3.or.iaxis(istn).eq.6.or.iaxis(istn).eq.7) 
     .GOTO 100
C     If we don't have an azel mount, delta-az=0 and return.
      CABLW = 0.D0
      call char2hol ('  ',LWRNEW,1,2)
      GOTO 990
C
100   continue
      aznow_orig = aznow
      aznew_orig = aznew
      IF (AZNOW.LT.STNLIM(1,1,ISTN)) AZNOW=AZNOW+2.0*PI
      IF (AZNEW.LT.STNLIM(1,1,ISTN)) AZNEW=AZNEW+2.0*PI
      IF (ichcm_ch(LWRCUR,1,'C ').eq.0) AZNOW=AZNOW+2.0*PI
C
      if (ichcm_ch(lwrnew,1,'V ').eq.0) goto 500 !special section for VLBA slewing 
      IF (ichcm_ch(LWRNEW,1,'C ').eq.0 .or.
     &    ichcm_ch(LWRNEW,1,'W ').eq.0 ) GOTO 300
C
C     2.  This is the minimum slewing time section.  Compute both
C     possible moves, and choose the smaller.  If we end up on the
C     overlapped part, set the wrap indicator.
C
      DAZ1 = ABS(AZNOW-AZNEW)
      DAZ2 = 9999.9
      IF ((AZNEW+2.0*PI).LT.STNLIM(2,1,ISTN))
     .    DAZ2 = DABS(AZNOW-(AZNEW+2.D0*PI))
      IF (DAZ1.LE.DAZ2) GOTO 110
      GOTO 120
C     We are in the first 360 degrees
110   CABLW = DAZ1
      call char2hol ('  ',LWRNEW,1,2)
      IF (AZNEW.LT.(STNLIM(2,1,ISTN)-2.0*PI))
     .  call char2hol ('W ',LWRNEW,1,2)
      GOTO 130
C     We are in the outer overlapped portion
120   CABLW = DAZ2
      call char2hol ('C ',LWRNEW,1,2)
      AZNEW = AZNEW+2.0*PI
C     Special for NOTO slewing
130   if(cstnna(istn).eq.'Noto' .or. cstnna(istn).eq.'NOTO') goto 600
      GOTO 990
C
C
C     3.  If the user specified "W" then we want to end up on the
C     counter-clockwise wrap, i.e. the inner overlapped portion.
C
300   IF (ichcm_ch(LWRNEW,1,'W ').ne.0) GOTO 400
      CABLW = ABS(AZNOW-AZNEW)
      call char2hol ('  ',LWRNEW,1,2)
      IF (AZNEW.LT.(STNLIM(2,1,ISTN)-2.0*PI))
     .  call char2hol ('W ',LWRNEW,1,2)
      GOTO 990
C
C
C     4.  If we got here, the user specified "C", or the clockwise
C     wrap.  This is the outer overlapped portion.
C
400   IF ((AZNEW+2.0*PI).LT.STNLIM(2,1,ISTN)) GOTO 410
      GOTO 420
C     We are actually on the overlapped portion.
410   AZNEW = AZNEW+2.0*PI
      CABLW = ABS(AZNEW-AZNOW)
      call char2hol ('C ',LWRNEW,1,2)
      GOTO 990
C     We are actually on the unique portion.
420   CABLW = ABS(AZNEW-AZNOW)
      call char2hol ('  ',LWRNEW,1,2)
      GOTO 990

C     5. VLBA slewing algorithm. "Don't go through south unless
C     necessary." This algorithm was in effect during Jan. 1994
C     and spring of 1994. 

500   aznew1 = aznew ! initial trial value
      aznew2 = -1.0
      if (aznew+2.0*pi .lt. stnlim(2,1,istn))
     .  aznew2 = aznew1+2.0*pi
      if (aznew-2.0*pi .gt. stnlim(1,1,istn)) 
     .  aznew2 = aznew1-2.0*pi
      if (aznew2 .gt. 0.0) then
        if (aznow .lt. 3.0*pi) then
          aznew = amin1(aznew1,aznew2)
        else
          aznew = amax1(aznew1,aznew2)
        endif
      endif
      cablw = abs(aznew-aznow)
      call char2hol ('  ',LWRNEW,1,2)
      if (aznew .gt. 3.5*pi)
     .  call char2hol ('C ',LWRNEW,1,2)
      if (aznew .lt. 2.5*pi)
     .  call char2hol ('W ',LWRNEW,1,2)
      goto 990

C 6. Special NOTO slewing logic. 

C     True if moving from quadrant 2 to 4
600   kq24 = aznow_orig.gt.0.5*pi.and.aznow_orig.le.    pi.and.
     .       aznew_orig.gt.1.5*pi.and.aznew_orig.le.2.0*pi
C     True if moving from quadrant 1 to 3
      kq31 = aznow_orig.gt.    pi.and.aznow_orig.le.1.5*pi.and.
     .       aznew_orig.gt.0.0   .and.aznew_orig.le.0.5*pi
      if (kq31.or.kq24) then
        aznew2 = -1.0
        aznew1 = aznew
        if (aznew+2.0*pi .lt. stnlim(2,1,istn))
     .    aznew2 = aznew1+2.0*pi
        if (aznew-2.0*pi .gt. stnlim(1,1,istn)) 
     .    aznew2 = aznew1-2.0*pi
        if (kq31) aznew=amin1(aznew1,aznew2)
        if (kq24) aznew=amax1(aznew1,aznew2)
        cablw = abs(aznew-aznow)
        call char2hol ('  ',LWRNEW,1,2)
        if (aznew .gt. 3.5*pi)
     .    call char2hol ('C ',LWRNEW,1,2)
        if (aznew .lt. 2.5*pi)
     .    call char2hol ('W ',LWRNEW,1,2)
      endif
      goto 990
C
990   RETURN
      END
