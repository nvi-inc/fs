      subroutine xyz2latlon(XYZ,rlat,rlon)
! convert from xyz to lat long
!
      include '../skdrincl/constants.ftni'

      double precision xyz(3)
      double precision rlat,rlon

      rlon = (-DATAN2(XYZ(2),XYZ(1)))*rad2deg
      IF (rlon.LT.0.D0) rlon=rlon+360.D0
C                   West longitude = ATAN(y/x)
      rlat=DATAN2(XYZ(3),DSQRT((XYZ(1)**2+XYZ(2)**2))*(1.D0-EFLAT)**2)
     >          * rad2deg
      return
      end



