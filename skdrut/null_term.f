      subroutine null_term(cstr)
c
c   'null_term' will null-terminate a character string.  This
c   is necessary when string must be passed to C routines.
c
C 990916 nrv Uncommented the warning message if the string is too short.

      character*(*) cstr
      integer     i,j,len

      j = len(cstr)

      i = j
      do while ((i.gt.0) .and. ((cstr(i:i).eq.' ').or.
     .         (cstr(i:i) .eq. char(0))))
        i = i - 1
      end do
      i = i + 1
      if (i .gt. j) then ! no trailing blanks or nulls
C       print *, 'NULL_TERM: string too short, last char replaced ',
C    .  'with NULL'//cstr
        i=i-1
      end if
      cstr(i:i) = char(0)

      return
      end

