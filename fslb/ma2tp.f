      subroutine ma2tp(ibuf,ilow,lft,ifas,icap,istp,itac,irdy)

C  convert mat buffer to tp data c#870407:12:42#
C
C     This routine converts the buffers returned from the MAT
C     into the tape drive status information.
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910114  Changed LFT from 4 to 5 characters and started at 6 instead
C               of 7.
C
C  INPUT:
C
      integer*2 ibuf(1)
      integer*2 lft(1)
C      - buffers of length 5 words, as returned from MATCN
C
C  OUTPUT:
C
C     ILOW - low tape sensor
C     LFT - footage counter
C     IFAS - fast speed button
C     ICAP - capstan status
C     ISTP - stop command
C     ITAC - tach lock
C     IRDY - ready status 
C 
C 
C        TPbdrsvvvv 
C     where each letter is a character with the following bits
C                   b = bits for low tape, fast speed, capstan, 
C                        and stop command 
C                   d = bits for tape lock, tach lock, and front panel (2)
C                   r = bits for ready, reset footage, and value type (2) 
C                   s = bits for decimal point 1, decimal point 2,
C                       sign, and MSB of value
C                   vvvv = four digits of value, hex.
C     Note we are only concerned with the last 8 characters
C
      ia = ia2hx(ibuf,3)
      ilow = iand(ia,8)/8
      ifas = iand(ia,4)/4
      icap = iand(ia,2)/2
      istp = iand(ia,1)
      call ichmv(lft,1,ibuf,6,5)
      itac = iand(ia2hx(ibuf,4),4)/4
      irdy = iand(ia2hx(ibuf,5),8)/8
C
      return
      end
