      subroutine move2(it,rain,decin,epin,raout,decout)
      implicit none
C
C calculate apparent geocentric coordinates
C
      INTEGER IT(6)
      DOUBLE PRECISION wlon,glat,ht,RAIN,DECIN,RAOUT,DECOUT
      REAL EPIN
C
      include '../include/dpi.i'
C
      DOUBLE PRECISION RAH,DECD,RADH,DECDD,TJD,r,d
      INTEGER JULDA,IYR
      LOGICAL KTOPO
c
      ktopo=.false.
      goto 10
C
      ENTRY move2t(it,wlon,glat,ht,rain,decin,epin,raout,decout)
C
C calculate apparent topocentric coordinates
C
      ktopo=.TRUE.
C
 10   continue
      if(abs(epin-2000.0).gt.0.01) then
         if(abs(epin-1950.0).lt.0.01) then
C
C convert using prefr because that is what DRUDG uses to make 1950
C         coordinates for SNAP schedules. This will bring the coordinates
C         back to the original 2000 coordinates that DRUDG got
C
            call prefr(rain,decin,1950,r,d)
            RAH=R*12.0D0/DPI
            DECD=D*180.D0/DPI
          ELSE
C
C full reduction back to J2000
C  use 366 day so that Dec 31 is accessible in leap years
C
            iyr=epin+1e-6
            tjd=julda(1,1,iyr-1900)+2440000.d0-0.5d0+(epin-iyr)*366.0
            radh = rain*12.d0/dpi
            decdd = DECIN*180.d0/dpi
            call mpstar(tjd,3,radh,decdd,rah,decd)
          END IF
       else 
C
C we are J2000
C
          rah=rain*12.D0/DPI
          decd=decin*180.D0/DPI
       endif
C
       TJD = JULDA(1,IT(5),IT(6)-1900) + 2440000.0D0 - 0.5d0
       TJD = TJD + (IT(1)*1d-2+it(2)+it(3)*6d1+it(4)*36d2)/86400d0
C
       CALL APSTAR(TJD,3,RAH,DECD,0.D0,0.D0,0.D0,0.D0,RADH,DECDD)
       IF (ktopo) then
         CALL TPSTAR(TJD,-wlon*180.d0/DPI,glat*180.d0/DPI,ht,RADH,DECDD)
       endif
C
       RAOUT = RADH*DPI/12.D0
       DECOUT = DECDD*DPI/180.D0
       return
C
       END
