C@TRIMLEN

       integer function trimlen (cbuf)
C
C  Trimlen returns the length of a
C  character array.
C           -P. Ryan
C
       implicit none

       integer     j
C        - j    : variable for indexing
       character*(*) cbuf
C        - cbuf : character buffer

C get total length of string
       j = len(cbuf)
C
C Read backwards down array, stopping at first non-blank character
C
       do while ((j.gt.0).and.(cbuf(j:j).eq.' '.or.
     . cbuf(j:j).eq.char(0)))
         j = j - 1
       end do
       trimlen = j
       return
       end

