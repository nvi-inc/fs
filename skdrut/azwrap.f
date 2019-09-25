      real*4 FUNCTION azwrap(az,cwrap,azwrap_limits)
! Given input value, compute azimuth including wrap
      implicit none
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'

      real*4 az
      character*(*)  cwrap        ! one or two characters. 
                                   !"-" or " " = neutral
                                   !"W"        = counter
                                   !"C"        = clock 

      real*4 azwrap_limits(1:2)    !min, max values of wrap

! tolerance to see how close we are to azimuth wrap
      real*4 az_tol
      parameter(az_tol=5.d0*deg2rad)

      azwrap=az

! Find correct position of beginning AZ, including wrap.
      IF (azwrap.LT.azwrap_limits(1)) then
           azwrap=azwrap+TWOPI

      else if(azwrap - azwrap_limits(1) .lt. az_tol .and.
     >   (cwrap .eq. " " .or. cwrap .eq. "-")) then
! Slightly above boundary separating neutral and CCW.
! Wrap indicates neutral, but should probably be clockwise-- source wandered from N to C
         if(azwrap+twopi .lt. azwrap_limits(2)) azwrap=azwrap+twopi               
      endif

      if(cwrap .eq."C") then
         if(azwrap+twopi .lt. azwrap_limits(2)) azwrap=azwrap+twopi           
      endif
      return
      end 


