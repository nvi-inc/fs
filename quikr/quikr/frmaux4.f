      subroutine frmaux4(ibuf,posn)
      implicit none
      integer*2 ibuf(1)
      real*4 posn(2)
C
C FRMAUX: FORMAT AUX DATA INTO BUFFER
C
C INPUT:
C   IPOSN: position of write head in microns
C   IPAS: pass number of write head
C         odd, implies forward pass (-1 is odd)
C         even, implies reverse pass (-2 is even)
C         0, implies no calibration
C
C OUTPUT:
C   IBUF: output hollerith aux data field, 12 characters
C         <abcdwxyz>
C         abcd encodes the micron position head 1
C         wxyz encodes the micron position head 2
C           0000-3999 are positive positions
C           4000-7999 are negative positions as 4000+abs(position)
C
      integer iof1,iof2,idumm1,ib2as,iposn(2)
C
      iposn(1)=nint(posn(1))
      iposn(2)=nint(posn(2))
      iof1=min(abs(iposn(1)),3999)    !limit offset to 3999
      iof2=min(abs(iposn(2)),3999)    !limit offset to 3999
      if(iposn(1).lt.0) iof1=iof1+4000
      if(iposn(2).lt.0) iof2=iof2+4000
      idumm1 = ib2as(iof1,ibuf,1,o'40000'+o'400'*4+4)
      idumm1 = ib2as(iof2,ibuf,5,o'40000'+o'400'*4+4)
C
      return
      end
