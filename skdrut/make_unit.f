      subroutine make_unit(rlong,rlat,xyz)

! passed
      double precision rlong     !longitude (radians)
      double precision rlat      !latitude
! on output
      double precision xyz(3)  !contains unit vectors along minimum elevation.
! local
      double precision sin_long,cos_long,sin_lat,cos_lat

      sin_long=sin(rlong)
      cos_long=cos(rlong)
      sin_lat =sin(rlat)
      cos_lat =cos(rlat)

      xyz(1)=cos_lat*cos_long
      xyz(2)=-sin_long
      xyz(3)=-sin_lat*cos_long
      return
      end


