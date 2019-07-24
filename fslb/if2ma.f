      subroutine if2ma(ibuf,iat1,iat2,inp1,inp2)
C 
C     IF2MA converts data for the IF distributor to an MAT buffer.
C 
C  INPUT: 
C 
C     IBUF - buffer to use
C     INP1,2 - the IFD's input type 
C     IAT1,2 - attenuator settings
      integer*2 ibuf(1) 
cxx      integer ibuf(1) 
C 
C     The buffer is set up as follows:
C                       00ija2a1
C     where each letter represents a character (half word). 
C                   00 = these bits unused
C                   i  = input for IF 2 (0=NOR,8=ALT) 
C                   j  = input for IF 1  (0=NOR,8=ALT)
C                   a2 = atten. setting for IF 2
C                   a1 = atten. setting for IF 1
C 
      call ifill_ch(ibuf,1,2,'0') 
C  Fill unused fields with zeros 
      call ib2as(inp2*8,ibuf,3,1) 
      call ib2as(inp1*8,ibuf,4,1) 
C  Put inputs into chars 3,4 
C 
      call ichmv(ibuf,7,ihx2a(iand(iat1,o'60')/16),2,1) 
C  Put upper two bits (of six) into char 7 
      call ichmv(ibuf,8,ihx2a(iand(iat1,o'17')),2,1)
C  Put lower four bits into next character.
      call ichmv(ibuf,5,ihx2a(iand(iat2,o'60')/16),2,1) 
      call ichmv(ibuf,6,ihx2a(iand(iat2,o'17')),2,1)
C  Do the same for channel 2 
C 
      return
      end 
