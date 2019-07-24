      subroutine ad2ma(ibuf,iosc,igain,ichan)
      implicit none
      integer iosc,igain,ichan
      integer*2 ibuf(1)
cxx      integer ibuf(1)
C
C  ad2ma: encode MAT buffer for A/D control
C
C  INPUT:
C     IOSC: oscillator control, 0 = on, 1 = off
C     IGAIN: gain control, 0 = high, 1 = low
C     ICHAN: channel select:
C            1 - head 0 position
C            2 - head 1 position
C            3 - head 0 temperature
C            4 - head 1 temperature
C            5 - vacuum sensor
C            6 -  odd reproduce power
C            7 - even reproduce power
C            8 - reference voltage (5.46 Volts)
C
C OUTPUT:
C    IBUF:  8 characters holding MAT buffer
  
      integer inext,ichmv,ihx2a
C
      inext=1
      inext=ichmv(ibuf,inext,4H0000,1,3)
      inext=ichmv(ibuf,inext,ihx2a(iosc),2,1)
      inext=ichmv(ibuf,inext,ihx2a(igain),2,1)
      inext=ichmv(ibuf,inext,2H00,1,2)
      inext=ichmv(ibuf,inext,ihx2a(ichan-1),2,1)
C
      return
      end
