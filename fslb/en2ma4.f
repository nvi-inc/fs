      subroutine en2ma4(ibuf,iena,kena)
C     convert en data to mat buffer for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      logical kena(2) 
C      - true for head stacks enabled index 1 = stack 0
C                                     index 2 = stack 1
C     IENA - record-enable bit
C 
C  LOCAL: 
C
      integer ia,ib
C 
C     Format the buffer for the controller. 
C 
      call ichmv_ch(ibuf,1,'%') 
C                   The strobe character for this control word
      call ichmv_ch(ibuf,2,'00000000') 
C                   Fill buffer with zeros to start 
      ia = iena*8
      call ichmv(ibuf,2,ihx2a(ia),2,1)
      ia = 0
      ib = 0
      if (kena(1)) call ichmv(ibuf,9,ihx2a(z'01'),2,1)
      if (kena(2)) call ichmv(ibuf,7,ihx2a(z'01'),2,1)
C
      return
      end 
