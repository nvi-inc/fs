      subroutine ma2vc(ibuf1,ibuf2,lfreq,ibw,itp,iatu,iatl,irem,ilok, 
     .     tpwr,ial)

C  convert mat buffer to vc data c#870407:12:40#
C 
C     This routine converts the buffers returned from the MAT 
C     into the video converter indices, frequency, and total power. 
C 
C  INPUT: 
C 
      integer*2 ibuf1(1),ibuf2(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
      integer*2 lfreq(3)
C      - frequency, ASCII characters in format fff.ff (MHz) 
C     IBW - bandwidth code
C     ITP - TPI selection code
C     IATU, IATL - upper, lower attenuator settings 
C     IREM - remote/local code
C     ILOK - lock/unlock code 
C     TPWR - total power, binary
C     IAL  - alarm
C 
C 
C     Buffers from MATCN look like: 
C     for ! data:   Vntabfffff
C     for % data:   Vn----pppp (total power word) 
C     Note we are only concerned with the last 8 characters 
C 
      call ichmv(lfreq,1,ibuf1,6,3) 
      call ichmv(lfreq,4,2H. ,1,1)
      call ichmv(lfreq,5,ibuf1,9,2) 
      ibw = ia2hx(ibuf1,5)
      itp = iand(ia2hx(ibuf1,3),7)
      ia = ia2hx(ibuf1,4) 
      iatu = 10*iand(ia,2)/2
      iatl = 10*iand(ia,1)
      irem = iand(ia2hx(ibuf1,3),8)/8 
      ilok = iand(ia,8)/8 
      tpwr = 0.0
      do i=1,4
        tpwr = tpwr + ia2hx(ibuf2,6+i)*(16.0**(4-i))
      enddo
      ial = iand(ia,4)/4
c
      return
      end 
