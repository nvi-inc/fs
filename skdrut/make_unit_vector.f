      subroutine make_unit_vector(phi,theta,vec)
! Make a unit vector
! input
      double precision phi, theta       !spherical  cooordiantes=long,lat
                                        !both in radians.
! ouptut
      double precision vec(3)
! History:
! 2007Oct05  JMGipson. First version.

! start of code
      vec(1)=cos(phi)*cos(theta)
      vec(2)=sin(phi)*cos(theta)
      vec(3)=sin(theta)
      return
      end
