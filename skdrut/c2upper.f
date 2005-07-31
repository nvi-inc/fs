      subroutine c2upper(cbuf_in,cbuf_out)

C Convert a character string to upper case.
C The number of characters converted is the shorter
C of the two string lengths.

C 960201 nrv New.
C 040623  ZMM  changed min1 function to min
C              removed trailing RETURN


      character*(*) cbuf_in
      character*(*) cbuf_out

C Local
      integer iin,iout
      character*1 c

      iin=len(cbuf_in)
      iout=len(cbuf_out)
      do i=1,min(iin,iout)
        c=cbuf_in(i:i)
        if ((c.ge.'a').and.(c.le.'z')) then
           cbuf_out(i:i) = char(ichar(c) - (ichar('a') - ichar('A')))
        else
           cbuf_out(i:i) = c
        end if
      enddo
C     if (iiout.gt.iin) then
C       do i=iin+1,iiout
C         cbuf_out(i:i)=' '
C       enddo
C     endif

      end
