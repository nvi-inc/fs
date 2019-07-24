      subroutine frmaux4(ibuf,posn,ipas,koffset)
      implicit none
      integer*2 ibuf(1)
      real posn(1)
      integer ipas(1)
      logical koffset
C
C FRMAUX4: FORMAT AUX DATA INTO BUFFER FOR MARK IV FORMATTER
C
C INPUT:
C   POSN: position of write head in microns
C   IPAS: pass number of write head
C         odd, implies forward pass (-1 is odd)
C         even, implies reverse pass (-2 is even)
C   KOFFSET: false implies no calibration, not dependent on ipas.
C
C OUTPUT:
C   IBUF: output hollerith aux data field, 8 characters
C         <abdcwxyz>
C         abcd head stack 0 position in microns
C         wxyz head stack 1 position in microns
C         a & w have the following bit structure:
C           bit 0  thousands digit for the micron position, usually 0
C           bit 1  0 for forward calibration (odd passes), 1 for uncalibrated 
C           bit 2  0 for reverse calibration (even passes), 1 for uncalibrated 
C           bit 3  sign of the position, 0 for positive, 1 for negative
C
      integer ipos1, ipos, ihunds, itens, iones, itemp
      integer ibit0,ibit1,ibit2,ibit3,ibits
      integer index, iloop, ichmv, idum, ihx2a, iposn
C
      call ichmv(ibuf,1,8H00000000,1,8)
      do iloop = 1,2
        ibit0=z'00'
        ibit1=z'00'
        ibit2=z'00'
        ibit3=z'00'
        ibits=z'00'
        iposn = JNINT(posn(iloop))
        ipos1 = ABS(iposn)
        if (ipos1.ge.1000) then
          ibit0=z'01' 
          ipos = MOD(ipos1,1000)
          ihunds = ipos/100
          itemp = MOD(ipos,100)
        else
          ihunds = ipos1/100
          itemp = MOD(ipos1,100)
        endif
        itens = itemp/10
        iones = MOD(itemp,10)
        if ((MOD(ipas(iloop),2).ne.0).and.(.not.koffset)) ibit1=z'02'
        if ((MOD(ipas(iloop),2).eq.0).and.(.not.koffset)) ibit2=z'04'
        if (iposn.lt.0) ibit3=z'08'
        ibits = ibit0 + ibit1 + ibit2 + ibit3

        index=iloop*2-1

        if (ipas(iloop).ne.0) then
          idum = ichmv(ibuf(index),1,ihx2a(ibits),2,1)
          idum = ichmv(ibuf(index),2,ihx2a(ihunds),2,1)
          idum = ichmv(ibuf(index+1),1,ihx2a(itens),2,1)
          idum = ichmv(ibuf(index+1),2,ihx2a(iones),2,1)
        endif

      enddo
C
      return
      end
