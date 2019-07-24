       integer function trimlen(string)
       implicit none
       character*(*) string
c
c trimlen returns the index of the last nonblank character in string
c                 0 if all characters are blank
c
       trimlen=len(string)
c
c read backwards down array, stopping at first non-blank character
c
       do while (trimlen.gt.0)
         if(string(trimlen:trimlen).ne.' ') return
         trimlen = trimlen - 1
       enddo
c
       return
       end
