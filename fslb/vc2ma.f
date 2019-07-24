      subroutine vc2ma(ibuf,lfreq,ibw,itp,iatu,iatl)
C  convert vc data to mat buffer c#870407:12:38#
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      dimension lfreq(1)
C      - frequency, ASCII characters in form fff.ff (MHz) 
C     IBW - bandwidth code
C     ITP - total power integrator
C     IATU, IATL - upper, lower attenuator settings 
C 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   tabfffff
C     where each letter represents a character (half word). 
C                   t  = TPI code number
C                   a  = attenuator settings code number
C                   b  = bandwidth code 
C                   fffff = frequency, in 10s of kHz, i.e.
C                           an implied decimal point between the
C                           third and fourth characters for MHz.
C 
      iatn = 2*iatu/10 + iatl/10
      call ib2as(itp*100+iatn*10+ibw,ibuf,1,o'41400'+3) 
C                   Set the pre-fill bit and fill leading zeros 
      call ichmv(ibuf,4,lfreq,1,3)
      call ichmv(ibuf,7,lfreq,5,2)
C 
      return
      end 
