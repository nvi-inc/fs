      subroutine bsplt(idata,ilog)
C 
C     BSPLT separates the data from the A and B channels, 
C     which is necessary to process split mode data.
C 
C  INPUT: 
      dimension idata(1)
C      - IDATA holds the data in the form 1 byte A, 1 byte B etc. 
C     ILOG - # of characters in IDATA 
C 
C  OUTPUT:
C     IDATA - reformatted to hold all channel B bytes and then
C     all channel A bytes.
C 
C  LOCAL: 
      dimension itemp(260)
C      - buffer to save IDATA whilst reformatting 
C 
C     MAH - 19820217
C 
      do i = 1,ilog/2 
        itemp(i) = idata(i) 
      enddo
C 
      do i = 1,ilog/2 
        call ichmv(idata,i,itemp,2*i,1) 
      enddo
C 
      do i=1,ilog/2 
        call ichmv(idata,ilog/2+i,itemp,2*i-1,1)
      enddo
C 
      return
      end 
