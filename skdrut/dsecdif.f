      double precision function dsecdif(mjd1,ut1,mjd2,ut2)

C  ISECDIF coputes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).

C 970317 nrv New utility for sked.
C 2003Jun20 JMGipson. Simplified. Version made for double precision.

C Input:
      integer mjd1,mjd2
      double precision ut1,ut2
C Local:
!     integer ihr1,min1,isc1,ihr2,min2,isc2
!     integer nd,nh,nm,ns,nsdif

      dsecdif=(mjd1-mjd2)*86400.+(ut1-ut2)
      return
      end
