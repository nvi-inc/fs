!     Last change:  JMG  23 Sep 1999   11:19 am
!***********************************************************************
      subroutine capitalize(lstring)

      CHARACTER*(*) lstring
      idiff=ICHAR("a")-ICHAR("A")
      ilen=LEN(lstring)
      do i=1,ilen
         IF(lstring(i:i) .GE. "a" .AND. lstring(i:i) .LE. "z") then
                 lstring(i:i)=CHAR(ICHAR(lstring(i:i))-idiff)
          endif
      END do
      return
      end
