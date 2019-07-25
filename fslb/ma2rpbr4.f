      subroutine ma2rpbr4(ibuf,ibr)
C     convert mat buffer data to repro4's bitrate data to 
C     for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
C     IBR - bitrate selection
C 
      call ichmv(itemp,1,ibuf,9,1) 
      ibr = ia2hx(itemp,1)
C
      return
      end 
