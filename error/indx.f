      integer function indx(i,j)
      implicit none
      integer i,j
C
      if(i.ge.j) then
         indx=((i-1)*i)/2+j
      else
         indx=((j-1)*j)/2+i
      endif
C
      return
      end
