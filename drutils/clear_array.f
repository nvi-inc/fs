C@CLEAR_ARRAY

        subroutine clear_array(cbuf)

C  This routine simply loads a character buffer with blanks
C
C  -P. Ryan

        character*(*) cbuf
        integer     i,j,len

        cbuf = ' '
C       j = len(cbuf)
C       do i=1,j
C         cbuf(i:i) = ' '
C       end do

        return
        end

