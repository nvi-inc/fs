C@NULL_TERM

      subroutine null_term(cstr)

c
c   'null_term' will null-terminate a character string.  This
c   is necessary when string must be passed to C routines.
c

      character*(*) cstr
      integer     i,j,len

      j = len(cstr)

      i = j
      do while ((i.gt.0) .and. ((cstr(i:i).eq.' ').or.
     .         (cstr(i:i) .eq. char(0))))
        i = i - 1
      end do
      i = i + 1
C     if (i .le. j) then
        cstr(i:i) = char(0)
C     else
C no trailing blanks or nulls
C       print*, 'Warning from NULL_TERM'
C     end if

      return
      end

