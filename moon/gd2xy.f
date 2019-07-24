      subroutine gd2xy(gdlon,gdlat,height,x,y,z)
C
C  CONVERTS GEODETIC LONGITUDE AND LATITUDE (THE KIND YOU READ FROM
C  A MAP) AND HEIGHT ABOVE SEA LEVEL TO GEOCENTRIC X,Y,Z IN METERS
C
      implicit double precision (a-h,o-z)
C
      include '../include/dpi.i'
C
      a = 6378160d0
C
C  CORRECT FOR STANDARD ELLIPSOID (1964 I.A.U. SYSTEM - SEE A.E.N.A.)
C
      delphi = -692.743d0 * dsin(2d0*gdlat) + 1.1633d0 * dsin(4d0*gdlat)
     +  - 0.0026d0 * dsin(6d0*gdlat)
      phigc = gdlat + ( delphi * dtwopi / 1296000d0 )
      radius = a * ( 0.998327073d0 + 0.001676438d0 * dcos(2d0*gdlat)
     +                             - 0.000003519d0 * dcos(4d0*gdlat)
     +                             + 0.000000008d0 * dcos(6d0*gdlat))
      radius = radius + height
C 
C  CONVERT TO X Y Z 
C 
      cosphi = dcos(phigc)
      x = radius * cosphi * dcos(gdlon) 
      y = radius * cosphi * dsin(gdlon) 
      z = radius * dsin(phigc)
C
      return
      end 
