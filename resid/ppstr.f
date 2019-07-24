      subroutine ppstr(ibuf,ix,iy,istr,ich) 
C
      integer*2 ibuf(1),istr(1) 
      integer ix,iy,ich
C 
C  Put STRING AT PLOTTER Coordinates
C 
      do i=1,ich 
        call pppnt(ibuf,ix+i-1,iy,jchar(istr,i))
      enddo
C
      return
      end 
