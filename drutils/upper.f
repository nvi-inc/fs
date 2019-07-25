C@UPPER

      character function upper(c)
C
C        if c is a character, return its uppercase value.  otherwise
C     return it unchanged.
C
C     891228 PMR created

      character c

      if ((c.ge.'a').and.(c.le.'z')) then
         upper = char(ichar(c) - (ichar('a') - ichar('A')))
      else
         upper = c
      end if

      return
      end

