      double precision function sider2(it,DUT)
C
C CALCULATE APPARENT GREENWICH SIDERAL TIME
C
      double precision TJDH,TJDL,GST
      real dut
      integer it(6)
      include '../include/dpi.i'
C
      TJDH=julda(1,it(5),it(6)-1900) + 2440000.0D0-1.d0
      TJDL=(IT(1)*1d-2+it(2)+it(3)*6d1+it(4)*36d2+DUT)/86400d0+0.5d0
      IF(TJDL.GE.1.0d0) then
         TJDH=TJDH+1.d0
         TJDL=TJDL-1.0d0
      endif
      CALL SIDTIM (TJDH,TJDL,1,GST)
      SIDER2=GST*dpi/12.0d0
      return
      end
