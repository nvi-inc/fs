C@LOWER

      character function lower(c)
C
C        if c is a character, return its lowercase value.  otherwise
C     return it unchanged.
C
C     891228 PMR created

      character c

      if ((c.ge.'A').and.(c.le.'Z')) then
         lower = char(ichar(c) + (ichar('a') - ichar('A')))
      else
         lower = c
      end if

      return
      end

