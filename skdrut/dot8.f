!     Last change:  JG   27 May 2005    3:05 pm
      function dot8(a,b,num)
      DOUBLE precision a(*),b(*)
      INTEGER num,i
      DOUBLE PRECISION dot8

      dot8=0.
      do i=1,num
        dot8=dot8+a(i)*b(i)
      end do
      return
      end
