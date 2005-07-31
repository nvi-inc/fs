C@UPPER

! AEM 20041223 char -> char*1
      character*1 function upper(c)
C
C        if c is a character, return its uppercase value.  otherwise
C     return it unchanged.
C
C     891228 PMR created

! AEM 20041223 char -> char*1
      character*1 c

      if ((c.ge.'a').and.(c.le.'z')) then
         upper = char(ichar(c) - (ichar('a') - ichar('A')))
      else
         upper = c
      end if

      return
      end
