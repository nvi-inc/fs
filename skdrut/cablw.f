      real*4 FUNCTION CABLW(ISTN,azbeg,cwrap_beg,azend,cwrap_end)
C
C  CABLW returns the azimuth difference between the NOW and the
C              NEW source positions, taking into account cable wraps.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
C
C  INPUT VARIABLES:
      integer istn              !station
      real*4 azbeg              !beginning az
      real*4 azend              !ending az
      character*2 cwrap_beg    !beginning wrap. 
      character*2 cwrap_end    !ending wrap.   
                                ! C=Clockwise, W=CCW, " " or "-" go fastest. May be changed by routine. 

C  OUTPUT VARIABLES:
C        lwrend - new cable wrap indicator
C        CABLW - delta-azimuth required to be moved.
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'

! Function
      real azwrap
C
C     CALLING SUBROUTINES: SLEWT
C
C  LOCAL VARIABLES
      real daz1,daz2 ! DAZ1,DAZ2  - two choices of az moving
      real azend1,azend2 ! trial values for VLBA and Noto algorithms
    
      real azbeg_orig,azend_orig ! non-wrapped values
      logical kq31,kq24 ! for Noto logic

      real az_min, az_max           !minimum & maximum values of Az taking into account rwap. 
      real az_tol                   !used to see if near one of the borders

C
C HISTORY
C    LAST MODIFIED: created 780424
C    880315 NRV DE-COMPC'D
C    930225 nrv implicit none
C    930702 nrv Put back in check for pseudo-azel axis types
C    940513 nrv Special section added for VLBA slewing algorithm
C               which says: don't go through south unless necessary.
C               Invoke this algorithm with a "V" in the cable wrap
C               variable lwrend.
C 961016 nrv Add special section for Noto slewing algorithm. 1) If
C            going from one quadrant to the opposite one, must go
C            through south. 2) If going to az=270 to 290, antenna
C            thinks it can get there in CCW, but this range is
C            "prohibited" and operator must catch it and send it the
C            right way. So allow extra time for antenna to slew to
C            the wrong limit and then go around 360 degrees to the
C            other wrap.
C 970114 nrv Change amin0,amax0 to amin1,amax1 (found by Simone Magri, ATNF)
! 2014Apr18.  Re-structured and some code modified. JMGipson. 

! Let
!  Az_min = minimum value with wrap
!  Az_max = maximum value
!  W-region = Az_min     <----> Az_max-360
!  C-region = Az_min+360 <----> Az_max
!  N-region = Az_max-360  <----> Az_min+360.

! Example:  Az_min=280, Az_max=800,   
!  W  = 280 - 540
!  N  = 540 - 640
!  C  = 640 - 800



! Check to see if AZEL
      IF (IAXIS(ISTN).EQ.3.or.iaxis(istn).eq.6.or.iaxis(istn).eq.7) 
     >        GOTO 100
! Not AZEL. ===> delta-az=0 and return.
      CABLW = 0.D0
      cwrap_end="-"
      return 
  
100   continue
      azbeg_orig = azbeg
      azend_orig = azend

      az_tol=3.0*deg2rad            
      az_min=stnlim(1,1,istn)
      az_max=stnlim(2,1,istn) 
! Find correct position of beginning AZ, including wrap.
      azbeg=azwrap(azbeg,cwrap_beg,stnlim(1,1,istn))
   

! Find correct position of ending AZ. Default is on first wrap. 
      IF (azend.LT.az_min) azend=azend+TWOPI
    

! The user specified a "W". Wants W-portion if possible, otherwise get neutral.
      IF (cwrap_end .eq. "W") then
        CABLW = ABS(azbeg-azend)
! azend is not in W region, but in neutral region. 
        if(azend .gt. (az_max-twopi)) cwrap_end="-"      ! Above upper limit of W region. Must be netural. 
        return
      else  IF (cwrap_end .eq. "C")  then 
! User specified "C". Want C if possible, otherwise get neutral.
! See if we can put int the "C" region.  
        IF ((azend+TWOPI).LT.az_max) then
           azend=azend+TWOPI 
        else
! Can't put it in the "C" region. Must be neutral. 
           cwrap_end="- " 
         endif 
         CABLW = ABS(azend-azbeg)
         return
      else if (cwrap_end .eq. "V") then
! VLBA slewing algorithm. "Don't go through south unless necessary." 
!  This algorithm was in effect during Jan. 1994  and spring of 1994. 
        azend1 = azend ! initial trial value
        azend2 = -1.0
        if (azend+TWOPI .lt. az_max) azend2 = azend1+TWOPI
        if (azend-TWOPI .gt. az_min) azend2 = azend1-TWOPI
        if (azend2 .gt. 0.0) then
          if (azbeg .lt. 3.0*pi) then
            azend = amin1(azend1,azend2)
          else
            azend = amax1(azend1,azend2)
          endif
        endif
        cablw = abs(azend-azbeg)
!        call char2hol ('  ',lwrend,1,2)
        cwrap_end="-" 
        if (azend .gt. 3.5*pi)  cwrap_end="C" 
        if (azend .lt. 2.5*pi)  cwrap_end="W"
      endif    
    
C
C     2.  This is the minimum slewing time section.  Compute both
C     possible moves, and choose the smaller.  If we end up on the
C     overlapped part, set the wrap indicator.
C
       
      DAZ1 = ABS(azbeg-azend)
     
      IF ((azend+TWOPI).LT.az_max) then
         DAZ2 = DABS(azbeg-(azend+twopi))
      else
         DAZ2 = 9999.9
      endif
!     write(*,*) "DAZ", rad2deg*Daz1, rad2deg*Daz2
      
      if(Daz1 .le. daz2) then
         cablw=daz1
         cwrap_end="-"
         if(azend .lt. (az_max-twopi)) cwrap_end="W"
      else
         cablw=daz2
         cwrap_end="C"
         azend=azend+twopi
      endif 

130   if(cstnna(istn).ne.'Noto' .and. cstnna(istn).eq.'NOTO') goto 600
      return


C 6. Special NOTO slewing logic. 

C     True if moving from quadrant 2 to 4
600   kq24 = azbeg_orig.gt.0.5*pi.and.azbeg_orig.le.    pi.and.
     .       azend_orig.gt.1.5*pi.and.azend_orig.le.TWOPI
C     True if moving from quadrant 1 to 3
      kq31 = azbeg_orig.gt.    pi.and.azbeg_orig.le.1.5*pi.and.
     .       azend_orig.gt.0.0   .and.azend_orig.le.0.5*pi
      if (kq31.or.kq24) then
        azend2 = -1.0
        azend1 = azend
        if (azend+TWOPI .lt. az_max)
     .    azend2 = azend1+TWOPI
        if (azend-TWOPI .gt. az_min) 
     .    azend2 = azend1-TWOPI
        if (kq31) azend=amin1(azend1,azend2)
        if (kq24) azend=amax1(azend1,azend2)
        cablw = abs(azend-azbeg)      
    
        if (azend .gt. 3.5*pi) then
          cwrap_end="C"
        else if (azend .lt. 2.5*pi) then
          cwrap_end="W"
        else
          cwrap_end="-"
         endif 
      endif
     
      RETURN
      END
